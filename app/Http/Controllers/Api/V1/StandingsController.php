<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Api\V1\Concerns\ResolvesActiveSeason;
use App\Http\Controllers\Controller;
use App\Http\Resources\Api\StandingResource;
use App\Models\Standing;

class StandingsController extends Controller
{
    use ResolvesActiveSeason;

    public function __invoke()
    {
        $season = $this->activeSeason();

        $standings = $season
            ? Standing::with(['team', 'group'])
                ->where('season_id', $season->id)
                ->orderBy('group_id')
                ->orderBy('position')
                ->get()
            : collect();

        return response()->json([
            'active_season' => $season ? [
                'id' => $season->id,
                'name' => $season->name,
                'status' => $season->status,
                'tournament' => $season->tournament ? [
                    'id' => $season->tournament->id,
                    'name' => $season->tournament->name,
                ] : null,
            ] : null,
            'standings' => StandingResource::collection($standings),
        ]);
    }
}
