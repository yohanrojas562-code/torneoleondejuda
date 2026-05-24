<?php

namespace App\Http\Resources\Api;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * Detalle completo de un jugador para el dashboard del líder de equipo.
 * Expone todos los campos del modelo (datos personales, documentos,
 * consentimientos, posición y stats) — espeja exactamente lo que el líder
 * ve en el panel admin Filament.
 *
 * NO se usa para endpoints públicos — solo `/api/v1/my/players/{id}`.
 */
class MyPlayerDetailResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'unique_code' => $this->unique_code,

            // Datos personales
            'first_name' => $this->first_name,
            'last_name' => $this->last_name,
            'full_name' => trim("{$this->first_name} {$this->last_name}"),
            'document_type' => $this->document_type,
            'document_number' => $this->document_number,
            'blood_type' => $this->blood_type,
            'birth_date' => optional($this->birth_date)->format('Y-m-d'),
            'age' => $this->age,
            'is_minor' => $this->is_minor,
            'church' => $this->church,

            // Equipo + posición
            'team' => new TeamResource($this->whenLoaded('team')),
            'jersey_number' => $this->jersey_number,
            'jersey_name' => $this->jersey_name,
            'position' => $this->position,
            'goalkeeper_type' => $this->goalkeeper_type,
            'height' => $this->height ? (float) $this->height : null,
            'weight' => $this->weight ? (float) $this->weight : null,
            'is_captain' => (bool) $this->is_captain,
            'is_active' => (bool) $this->is_active,

            // Archivos (URLs públicas via storage symlink)
            'photo_url' => $this->fileUrl($this->photo),
            'document_file_url' => $this->fileUrl($this->document_file),
            'eps_certificate_url' => $this->fileUrl($this->eps_certificate),
            'no_eps_consent_url' => $this->fileUrl($this->no_eps_consent),
            'parental_consent_url' => $this->fileUrl($this->parental_consent),
            'has_eps' => (bool) $this->has_eps,

            // Solicitud especial (jugador 13+)
            'special_request' => (bool) $this->special_request,
            'special_request_reason' => $this->special_request_reason,

            // Consentimientos
            'image_consent' => (bool) $this->image_consent,
            'habeas_data' => (bool) $this->habeas_data,

            // Aprobación (read-only para el líder)
            'approval_status' => $this->approval_status,
            'rejection_reason' => $this->rejection_reason,

            // Stats (calculadas por planillas, read-only)
            'stats' => [
                'total_matches' => (int) ($this->total_matches ?? 0),
                'total_goals' => (int) ($this->total_goals ?? 0),
                'yellow_cards' => (int) ($this->yellow_cards ?? 0),
                'blue_cards' => (int) ($this->blue_cards ?? 0),
                'red_cards' => (int) ($this->red_cards ?? 0),
                'total_fouls' => (int) ($this->total_fouls ?? 0),
            ],

            // Reglas espejadas del Filament — la UI las usa para deshabilitar
            // campos sin tener que duplicar la lógica.
            'permissions' => [
                'locked_when_approved' => $this->approval_status === 'approved',
                'lock_message' => $this->approval_status === 'approved'
                    ? 'Bloqueado: jugador aprobado. Genera una PQRS si necesitas cambiar este dato.'
                    : null,
            ],
        ];
    }

    private function fileUrl(?string $path): ?string
    {
        return $path ? asset('storage/'.$path) : null;
    }
}
