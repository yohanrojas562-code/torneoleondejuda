<?php

namespace App\Http\Requests\Api;

use App\Models\Player;
use App\Models\Team;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

/**
 * Validación para editar un jugador existente desde la app móvil (líder).
 *
 * Espeja los locks del Filament:
 *  - Si el jugador YA está aprobado, no se puede cambiar first_name,
 *    last_name, jersey_number ni jersey_name (genera PQRS para eso).
 *  - team_id solo lo cambia admin.
 *  - approval_status / is_active / rejection_reason solo admin.
 *  - Stats (total_goals, etc.) nunca via API — se calculan por planilla.
 */
class UpdateMyPlayerRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->hasAnyRole(['admin', 'lider_equipo']) ?? false;
    }

    public function rules(): array
    {
        $isAdmin = $this->user()->hasRole('admin');
        $player = $this->route('player');
        $isApproved = $player instanceof Player
            && $player->approval_status === 'approved';

        // Si está aprobado y NO es admin, ciertos campos quedan bloqueados.
        $lockedRule = ($isApproved && ! $isAdmin)
            ? ['prohibited']
            : ['nullable'];

        return [
            // Personales (lock-when-approved aplica)
            'first_name' => array_merge($lockedRule, ['string', 'max:255']),
            'last_name' => array_merge($lockedRule, ['string', 'max:255']),
            'jersey_number' => array_merge(
                $lockedRule,
                ['integer', 'min:1', 'max:99'],
            ),
            'jersey_name' => array_merge($lockedRule, ['string', 'max:50']),

            // Personales editables siempre
            'document_type' => ['nullable', Rule::in(['CC', 'TI', 'CE', 'PA', 'RC'])],
            'document_number' => ['nullable', 'string', 'max:20'],
            'blood_type' => ['nullable', Rule::in([
                'O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-',
            ])],
            'birth_date' => ['nullable', 'date', 'before_or_equal:today'],
            'church' => ['nullable', 'string', 'max:255'],

            // Equipo + posición
            'team_id' => ['nullable', 'integer', $this->teamIdRule($isAdmin)],
            'position' => ['nullable', Rule::in([
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

            // Admin-only
            'is_active' => $isAdmin
                ? ['nullable', 'boolean']
                : ['prohibited'],
            'approval_status' => $isAdmin
                ? ['nullable', Rule::in(['pending', 'approved', 'rejected'])]
                : ['prohibited'],
            'rejection_reason' => $isAdmin
                ? ['nullable', 'string', 'max:1000']
                : ['prohibited'],
        ];
    }

    public function messages(): array
    {
        return [
            'first_name.prohibited' => 'No puedes cambiar el nombre de un jugador aprobado. Genera una PQRS.',
            'last_name.prohibited' => 'No puedes cambiar el apellido de un jugador aprobado. Genera una PQRS.',
            'jersey_number.prohibited' => 'No puedes cambiar el dorsal de un jugador aprobado. Genera una PQRS.',
            'jersey_name.prohibited' => 'No puedes cambiar el nombre del dorsal de un jugador aprobado. Genera una PQRS.',
            'approval_status.prohibited' => 'Solo el admin aprueba o rechaza jugadores.',
            'is_active.prohibited' => 'Solo el admin puede activar o desactivar jugadores.',
            'rejection_reason.prohibited' => 'Solo el admin puede registrar motivos de rechazo.',
        ];
    }

    private function teamIdRule(bool $isAdmin)
    {
        return function (string $attribute, $value, $fail) use ($isAdmin) {
            if (! $value) return;
            if (! $isAdmin) {
                $fail('Solo el admin puede cambiar el equipo del jugador.');
                return;
            }
            if (! Team::where('id', $value)->exists()) {
                $fail('El equipo no existe.');
            }
        };
    }
}
