<?php

namespace App\Http\Requests\Api;

use App\Models\Team;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

/**
 * Validación para crear un jugador desde la app móvil (líder de equipo).
 * Las reglas espejan las del PlayerResource Filament.
 *
 * Reglas clave:
 *  - team_id: el líder NO lo envía; se asigna automáticamente al equipo del
 *    usuario autenticado. Si el líder tiene >1 equipo, debe enviar team_id
 *    explícito y validamos que sea uno de sus equipos.
 *  - approval_status: NO se acepta del cliente (siempre se crea 'pending').
 *  - is_active: NO se acepta (siempre true al crear).
 *  - Solicitud especial: si el equipo ya tiene 12+ jugadores, special_request
 *    es requerido + reason.
 *  - Consentimientos image_consent y habeas_data son obligatorios (accepted).
 */
class StoreMyPlayerRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->hasAnyRole(['admin', 'lider_equipo']) ?? false;
    }

    public function rules(): array
    {
        return [
            // Personales
            'first_name' => ['required', 'string', 'max:255'],
            'last_name' => ['required', 'string', 'max:255'],
            'document_type' => ['required', Rule::in(['CC', 'TI', 'CE', 'PA', 'RC'])],
            'document_number' => ['required', 'string', 'max:20'],
            'blood_type' => ['required', Rule::in([
                'O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-',
            ])],
            'birth_date' => ['required', 'date', 'before_or_equal:today'],
            'church' => ['nullable', 'string', 'max:255'],

            // Equipo + posición
            'team_id' => ['nullable', 'integer', $this->teamIdRule()],
            'jersey_number' => ['required', 'integer', 'min:1', 'max:99'],
            'jersey_name' => ['nullable', 'string', 'max:50'],
            'position' => ['required', Rule::in([
                'portero', 'defensa', 'mediocampista', 'delantero',
            ])],
            'goalkeeper_type' => ['nullable', Rule::in(['titular', 'suplente'])],
            'height' => ['nullable', 'numeric', 'min:100', 'max:250'],
            'weight' => ['nullable', 'numeric', 'min:30', 'max:200'],
            'is_captain' => ['nullable', 'boolean'],

            // EPS
            'has_eps' => ['nullable', 'boolean'],

            // Solicitud especial
            'special_request' => ['nullable', 'boolean'],
            'special_request_reason' => ['nullable', 'string', 'max:2000'],

            // Consentimientos (obligatorios)
            'image_consent' => ['required', 'accepted'],
            'habeas_data' => ['required', 'accepted'],
        ];
    }

    public function messages(): array
    {
        return [
            'first_name.required' => 'El nombre es obligatorio.',
            'last_name.required' => 'El apellido es obligatorio.',
            'document_type.in' => 'Tipo de documento inválido.',
            'birth_date.before_or_equal' => 'La fecha de nacimiento no puede ser futura.',
            'jersey_number.min' => 'El dorsal debe estar entre 1 y 99.',
            'jersey_number.max' => 'El dorsal debe estar entre 1 y 99.',
            'position.in' => 'Posición inválida.',
            'image_consent.accepted' => 'Debes aceptar la autorización de uso de imagen.',
            'habeas_data.accepted' => 'Debes aceptar el tratamiento de datos personales.',
        ];
    }

    /**
     * Devuelve la regla closure que valida que team_id pertenezca al
     * líder. Si es admin, cualquier team es válido.
     */
    private function teamIdRule()
    {
        return function (string $attribute, $value, $fail) {
            if (! $value) return;
            $user = $this->user();
            if ($user->hasRole('admin')) {
                if (! Team::where('id', $value)->exists()) {
                    $fail('El equipo no existe.');
                }
                return;
            }
            // Líder: solo equipos donde es leader
            $allowed = Team::where('leader_id', $user->id)
                ->where('id', $value)
                ->exists();
            if (! $allowed) {
                $fail('No tienes permiso sobre ese equipo.');
            }
        };
    }
}
