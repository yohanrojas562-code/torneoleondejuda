<?php

namespace App\Http\Resources\Api;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * Resultado del Validador (escaneo de QR / búsqueda por documento).
 *
 * El `status` aquí es un derivado del estado del jugador en BD (approval +
 * is_active) que la app móvil interpreta. Mapeo:
 *  - 'approved'      → is_active = true  AND approval_status = approved
 *  - 'unregistered'  → no encontrado / no aprobado
 *  - 'suspended'     → suspendido manualmente (campo extendido si existe)
 *  - 'expired'       → carnet vencido (TBD - hoy no existe expiración)
 */
class VerifyResultResource extends JsonResource
{
    public function __construct(
        $resource,
        public string $status,
        public ?string $reason = null,
    ) {
        parent::__construct($resource);
    }

    public function toArray(Request $request): array
    {
        return [
            'status' => $this->status,
            'reason' => $this->reason,
            'player' => [
                'id' => $this->id,
                'unique_code' => $this->unique_code,
                'first_name' => $this->first_name,
                'last_name' => $this->last_name,
                'document' => $this->document_number,
                'photo_url' => $this->photo
                    ? asset('storage/'.$this->photo)
                    : null,
                'jersey_number' => $this->jersey_number,
                'position' => $this->position,
                'church' => $this->church,
                'team' => $this->relationLoaded('team') && $this->team
                    ? new TeamResource($this->team)
                    : null,
            ],
        ];
    }
}
