<?php

namespace App\Http\Controllers;

use App\Models\GameMatch;
use App\Models\Season;
use App\Models\SiteSetting;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

class CalendarioController extends Controller
{
    public function __invoke()
    {
        $activeSeason = Season::with(['tournament'])
            ->whereIn('status', ['registration', 'group_stage', 'knockout'])
            ->orderByRaw("CASE WHEN status = 'group_stage' THEN 0 WHEN status = 'knockout' THEN 1 ELSE 2 END")
            ->first();

        if (!$activeSeason) {
            $activeSeason = Season::with(['tournament'])
                ->where('status', '!=', 'draft')
                ->latest('id')
                ->first();
        }

        $seasonId = $activeSeason?->id;

        $baseRelations = [
            'homeTeam:id,name,short_name,logo,primary_color',
            'awayTeam:id,name,short_name,logo,primary_color',
            'venue:id,name',
            'matchDay:id,name',
        ];

        $upcomingMatches = $seasonId
            ? GameMatch::with($baseRelations)
                ->where('season_id', $seasonId)
                ->whereIn('status', ['scheduled', 'warmup', 'first_half', 'halftime', 'second_half', 'extra_time', 'penalties'])
                ->orderBy('scheduled_at')
                ->get()
            : collect();

        $finishedMatches = $seasonId
            ? GameMatch::with(array_merge($baseRelations, [
                    'events' => fn ($q) => $q
                        ->whereIn('type', ['goal', 'own_goal', 'penalty_goal', 'yellow_card', 'red_card', 'second_yellow', 'blue_card'])
                        ->orderBy('minute'),
                    'events.player:id,first_name,last_name,jersey_number',
                ]))
                ->where('season_id', $seasonId)
                ->where('status', 'finished')
                ->orderByDesc('scheduled_at')
                ->get()
            : collect();

        $postponedMatches = $seasonId
            ? GameMatch::with($baseRelations)
                ->where('season_id', $seasonId)
                ->whereIn('status', ['suspended', 'cancelled', 'postponed'])
                ->orderByDesc('scheduled_at')
                ->get()
            : collect();

        $settings = SiteSetting::pluck('value', 'key');

        return Inertia::render('Calendario', [
            'canLogin' => Route::has('login'),
            'canRegister' => Route::has('register'),
            'activeSeason' => $activeSeason,
            'upcomingMatches' => $upcomingMatches->toArray(),
            'finishedMatches' => $finishedMatches->toArray(),
            'postponedMatches' => $postponedMatches->toArray(),
            'settings' => $settings->toArray(),
        ]);
    }
}
