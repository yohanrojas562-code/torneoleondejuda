<?php

namespace App\Http\Resources\Api;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * Fila de la tabla de posiciones. Incluye stats acumuladas + el array `form`
 * con los últimos 5 resultados (W/D/L) para mostrar el indicador en la app.
 */
class StandingResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $form = $this->form;
        if (is_string($form)) {
            $decoded = json_decode($form, true);
            $form = is_array($decoded) ? $decoded : [];
        }
        if (! is_array($form)) {
            $form = [];
        }

        return [
            'id' => $this->id,
            'position' => $this->position,
            'played' => $this->played,
            'won' => $this->won,
            'drawn' => $this->drawn,
            'lost' => $this->lost,
            'goals_for' => $this->goals_for,
            'goals_against' => $this->goals_against,
            'goal_difference' => $this->goal_difference,
            'points' => $this->points,
            'form' => array_values($form),
            'yellow_cards' => $this->yellow_cards,
            'blue_cards' => $this->blue_cards,
            'red_cards' => $this->red_cards,
            'fair_play_points' => $this->fair_play_points,
            'team' => new TeamResource($this->whenLoaded('team')),
            'group' => $this->whenLoaded('group', fn () => [
                'id' => $this->group->id,
                'name' => $this->group->name,
            ]),
        ];
    }
}
