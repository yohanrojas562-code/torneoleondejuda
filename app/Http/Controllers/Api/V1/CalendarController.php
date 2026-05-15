<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Api\V1\Concerns\ResolvesActiveSeason;
use App\Http\Controllers\Controller;
use App\Http\Resources\Api\MatchResource;
use App\Models\GameMatch;

class CalendarController extends Controller
{
    use ResolvesActiveSeason;

    public function __invoke()
    {
        $season = $this->activeSeason();
        $seasonId = $season?->id;

        $baseRelations = ['homeTeam', 'awayTeam', 'venue', 'matchDay'];

        $upcoming = $seasonId
            ? GameMatch::with($baseRelations)
                ->where('season_id', $seasonId)
                ->whereIn('status', [
                    'scheduled', 'warmup', 'first_half', 'halftime',
                    'second_half', 'extra_time', 'penalties',
                ])
                ->orderBy('scheduled_at')
                ->get()
            : collect();

        $finished = $seasonId
            ? GameMatch::with(array_merge($baseRelations, [
                'events' => fn ($q) => $q
                    ->whereIn('type', [
                        'goal', 'own_goal', 'penalty_goal',
                        'yellow_card', 'red_card', 'second_yellow', 'blue_card',
                    ])
                    ->orderBy('minute'),
                'events.player',
            ]))
                ->where('season_id', $seasonId)
                ->where('status', 'finished')
                ->orderByDesc('scheduled_at')
                ->get()
            : collect();

        $postponed = $seasonId
            ? GameMatch::with($baseRelations)
                ->where('season_id', $seasonId)
                ->whereIn('status', ['suspended', 'cancelled', 'postponed'])
                ->orderByDesc('scheduled_at')
                ->get()
            : collect();

        return response()->json([
            'active_season' => $season ? [
                'id' => $season->id,
                'name' => $season->name,
            ] : null,
            'upcoming_matches' => MatchResource::collection($upcoming),
            'finished_matches' => MatchResource::collection($finished),
            'postponed_matches' => MatchResource::collection($postponed),
        ]);
    }
}
