<?php

namespace App\Http\Resources\Api;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * Serializador de un jugador. Cuando se carga la relación `team`, la incluye
 * embebida. Solo expone campos públicos — datos sensibles (cédula completa,
 * blood_type, etc.) se filtran a un endpoint con auth en el futuro.
 */
class PlayerResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'unique_code' => $this->unique_code,
            'first_name' => $this->first_name,
            'last_name' => $this->last_name,
            'full_name' => trim("{$this->first_name} {$this->last_name}"),
            'photo_url' => $this->photo
                ? asset('storage/'.$this->photo)
                : null,
            'jersey_number' => $this->jersey_number,
            'position' => $this->position,
            'goalkeeper_type' => $this->goalkeeper_type,
            'is_captain' => (bool) $this->is_captain,
            'church' => $this->church,
            'approval_status' => $this->approval_status,
            'team' => new TeamResource($this->whenLoaded('team')),
        ];
    }
}
