<?php

namespace App\Http\Resources\Api;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * Serializador de un partido. Incluye equipos, sede, scores y (si vienen
 * eager-loaded) los eventos del partido para la vista de finalizados.
 *
 * El campo `is_live` se computa con el helper isLive() del modelo para que la
 * app pueda mostrar el badge "EN VIVO" sin replicar la lógica del estado.
 */
class MatchResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'status' => $this->status,
            'is_live' => $this->isLive(),
            'scheduled_at' => optional($this->scheduled_at)->toIso8601String(),
            'home_score' => $this->home_score,
            'away_score' => $this->away_score,
            'home_penalty_score' => $this->home_penalty_score,
            'away_penalty_score' => $this->away_penalty_score,
            'home_yellow_cards' => $this->home_yellow_cards,
            'home_blue_cards' => $this->home_blue_cards,
            'home_red_cards' => $this->home_red_cards,
            'away_yellow_cards' => $this->away_yellow_cards,
            'away_blue_cards' => $this->away_blue_cards,
            'away_red_cards' => $this->away_red_cards,
            'observations' => $this->observations,
            'home_team' => new TeamResource($this->whenLoaded('homeTeam')),
            'away_team' => new TeamResource($this->whenLoaded('awayTeam')),
            'venue' => $this->whenLoaded('venue', fn () => [
                'id' => $this->venue->id,
                'name' => $this->venue->name,
            ]),
            'match_day' => $this->whenLoaded('matchDay', fn () => [
                'id' => $this->matchDay->id,
                'name' => $this->matchDay->name,
            ]),
            'events' => MatchEventResource::collection(
                $this->whenLoaded('events')
            ),
        ];
    }
}
