<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\Api\AuthUserResource;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

/**
 * Endpoints de autenticación para la app móvil. Emite tokens Sanctum
 * de larga duración (sin expiración explícita — el usuario hace logout
 * cuando quiere). Espeja el guard 'web' del sitio (mismas credenciales).
 */
class AuthController extends Controller
{
    /**
     * POST /api/v1/auth/login
     * Body: { email, password, device_name? }
     * Response: { token, user: AuthUserResource }
     */
    public function login(Request $request)
    {
        $data = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
            'device_name' => ['nullable', 'string', 'max:120'],
        ]);

        $user = User::where('email', $data['email'])->first();

        if (! $user || ! Hash::check($data['password'], $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['Credenciales inválidas. Verifica tu correo y contraseña.'],
            ]);
        }

        // Si la cuenta no tiene ningún rol con acceso, la app rechaza el
        // login (espeja el guard de FilamentUser::canAccessPanel).
        $allowedRoles = ['admin', 'arbitro', 'lider_equipo', 'capitan'];
        if (! $user->hasAnyRole($allowedRoles)) {
            throw ValidationException::withMessages([
                'email' => ['Tu cuenta no tiene permisos para usar la app.'],
            ]);
        }

        $deviceName = $data['device_name'] ?? 'mobile-app';
        $token = $user->createToken($deviceName)->plainTextToken;

        return response()->json([
            'token' => $token,
            'user' => new AuthUserResource($user),
        ]);
    }

    /**
     * GET /api/v1/auth/me
     * Header: Authorization: Bearer <token>
     * Response: { user: AuthUserResource }
     */
    public function me(Request $request)
    {
        return response()->json([
            'user' => new AuthUserResource($request->user()),
        ]);
    }

    /**
     * POST /api/v1/auth/logout
     * Revoca solo el token usado (otros dispositivos del usuario quedan
     * con sesión activa).
     */
    public function logout(Request $request)
    {
        /** @var \Laravel\Sanctum\PersonalAccessToken $token */
        $token = $request->user()->currentAccessToken();
        $token->delete();

        return response()->json(['ok' => true]);
    }
}
