<?php

namespace App\Http\Resources\Api;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * Portero titular para la tabla de Valla Menos Vencida. Combina los datos
 * del Player con stats de la tabla `standings` (goals_against, played) y un
 * conteo derivado de vallas invictas (clean_sheets) calculado en el
 * controller.
 */
class GoalkeeperResource extends JsonResource
{
    public function __construct(
        $resource,
        public int $rank,
        public int $goalsAgainst,
        public int $matchesPlayed,
        public int $cleanSheets,
    ) {
        parent::__construct($resource);
    }

    public function toArray(Request $request): array
    {
        return [
            'rank' => $this->rank,
            'goalkeeper' => new PlayerResource($this->resource),
            'stats' => [
                'goals_against' => $this->goalsAgainst,
                'matches_played' => $this->matchesPlayed,
                'clean_sheets' => $this->cleanSheets,
                'yellow_cards' => (int) ($this->yellow_cards ?? 0),
                'blue_cards' => (int) ($this->blue_cards ?? 0),
                'red_cards' => (int) ($this->red_cards ?? 0),
            ],
        ];
    }
}
