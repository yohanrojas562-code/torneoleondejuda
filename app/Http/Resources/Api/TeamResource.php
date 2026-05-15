<?php

namespace App\Http\Resources\Api;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * Serializador "ligero" de un equipo. Usado dentro de Standing/Match/Scorer
 * cuando solo necesitamos identidad visual del equipo (logo, color, nombre).
 */
class TeamResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'short_name' => $this->short_name,
            'slug' => $this->slug,
            'logo_url' => $this->logo
                ? asset('storage/'.$this->logo)
                : null,
            'primary_color' => $this->primary_color,
            'secondary_color' => $this->secondary_color,
        ];
    }
}
