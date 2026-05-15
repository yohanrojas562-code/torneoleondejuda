<?php

namespace App\Http\Resources\Api;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * Goleador (ranking de máximos artilleros). El `rank` se asigna desde el
 * controller en función del orden de la query — no es campo de DB.
 */
class ScorerResource extends JsonResource
{
    /** Constructor especial para inyectar el rank externamente. */
    public function __construct($resource, public ?int $rank = null)
    {
        parent::__construct($resource);
    }

    public function toArray(Request $request): array
    {
        return [
            'rank' => $this->rank,
            'player' => new PlayerResource($this->resource),
            'stats' => [
                'goals' => (int) ($this->total_goals ?? 0),
                'matches_played' => (int) ($this->total_matches ?? 0),
                'yellow_cards' => (int) ($this->yellow_cards ?? 0),
                'blue_cards' => (int) ($this->blue_cards ?? 0),
                'red_cards' => (int) ($this->red_cards ?? 0),
            ],
        ];
    }
}
