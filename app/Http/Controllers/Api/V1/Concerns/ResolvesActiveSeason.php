<?php

namespace App\Http\Controllers\Api\V1\Concerns;

use App\Models\Season;

/**
 * Trait compartido entre todos los controllers API que dependen de la
 * temporada activa. La lógica espeja a la del web (StandingsController,
 * GoleadoresController, etc.) para mantener una única "fuente de verdad" del
 * concepto "temporada activa" en toda la app.
 */
trait ResolvesActiveSeason
{
    protected function activeSeason(): ?Season
    {
        $season = Season::with(['tournament'])
            ->whereIn('status', ['registration', 'group_stage', 'knockout'])
            ->orderByRaw(
                "CASE WHEN status = 'group_stage' THEN 0 ".
                "WHEN status = 'knockout' THEN 1 ELSE 2 END"
            )
            ->first();

        if ($season) {
            return $season;
        }

        return Season::with(['tournament'])
            ->where('status', '!=', 'draft')
            ->latest('id')
            ->first();
    }
}
