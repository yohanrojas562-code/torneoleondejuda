<?php

namespace App\Http\Resources\Api;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * Evento dentro de un partido (gol, tarjeta, autogol). Compacto: solo lo que
 * la app necesita para listar minuto a minuto.
 */
class MatchEventResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'type' => $this->type,
            'minute' => $this->minute,
            'half' => $this->half,
            'team_id' => $this->team_id,
            'player' => $this->whenLoaded('player', fn () => [
                'id' => $this->player->id,
                'first_name' => $this->player->first_name,
                'last_name' => $this->player->last_name,
                'jersey_number' => $this->player->jersey_number,
            ]),
        ];
    }
}
