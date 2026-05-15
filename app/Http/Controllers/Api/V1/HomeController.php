<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Api\V1\Concerns\ResolvesActiveSeason;
use App\Http\Controllers\Controller;
use App\Http\Resources\Api\MatchResource;
use App\Models\GameMatch;

class HomeController extends Controller
{
    use ResolvesActiveSeason;

    public function __invoke()
    {
        $season = $this->activeSeason();
        $seasonId = $season?->id;

        $upcoming = $seasonId
            ? GameMatch::with(['homeTeam', 'awayTeam', 'venue'])
                ->where('season_id', $seasonId)
                ->whereIn('status', ['scheduled', 'warmup'])
                ->where('scheduled_at', '>=', now())
                ->orderBy('scheduled_at')
                ->limit(3)
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
                    'logo' => $season->tournament->logo
                        ? asset('storage/'.$season->tournament->logo)
                        : null,
                ] : null,
            ] : null,
            'upcoming_matches' => MatchResource::collection($upcoming),
        ]);
    }
}
