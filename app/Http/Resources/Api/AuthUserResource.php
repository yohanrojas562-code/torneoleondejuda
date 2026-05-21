<?php

namespace App\Http\Resources\Api;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * Usuario autenticado para la app móvil. Expone solo roles (no permisos
 * granulares) — la app rutea su dashboard según el primer rol con
 * privilegio. NO expone password, email_verified_at ni otros campos
 * sensibles.
 */
class AuthUserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'phone' => $this->phone,
            'avatar_url' => $this->avatar
                ? asset('storage/'.$this->avatar)
                : null,
            'roles' => $this->getRoleNames()->values()->all(),
        ];
    }
}
