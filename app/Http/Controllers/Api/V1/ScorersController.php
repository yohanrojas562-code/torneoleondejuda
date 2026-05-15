<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Api\V1\Concerns\ResolvesActiveSeason;
use App\Http\Controllers\Controller;
use App\Http\Resources\Api\ScorerResource;
use App\Models\Player;

class ScorersController extends Controller
{
    use ResolvesActiveSeason;

    public function __invoke()
    {
        $season = $this->activeSeason();
        $seasonId = $season?->id;

        $scorers = collect();

        if ($seasonId) {
            $goalsFilter = function ($q) use ($seasonId) {
                $q->whereIn('type', ['goal', 'penalty_goal'])
                    ->whereHas('match', function ($mq) use ($seasonId) {
                        $mq->where('season_id', $seasonId)
                            ->where('status', 'finished');
                    });
            };

            $scorers = Player::query()
                ->where('approval_status', 'approved')
                ->whereHas('matchEvents', $goalsFilter)
                ->withCount(['matchEvents as total_goals' => $goalsFilter])
                ->orderByDesc('total_goals')
                ->orderBy('last_name')
                ->orderBy('first_name')
                ->with('team')
                ->get();
        }

        $items = $scorers
            ->values()
            ->map(fn ($player, $i) => new ScorerResource($player, rank: $i + 1));

        return response()->json([
            'active_season' => $season ? [
                'id' => $season->id,
                'name' => $season->name,
            ] : null,
            'scorers' => $items,
        ]);
    }
}
