<?php

namespace App\Http\Controllers;

use App\Models\Player;
use App\Models\Season;
use App\Models\SiteSetting;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

class GoleadoresController extends Controller
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

        $topScorers = collect();

        if ($seasonId) {
            $goalEventsFilter = function ($q) use ($seasonId) {
                $q->whereIn('type', ['goal', 'penalty_goal'])
                    ->whereHas('match', function ($mq) use ($seasonId) {
                        $mq->where('season_id', $seasonId)
                            ->where('status', 'finished');
                    });
            };

            $topScorers = Player::query()
                ->where('approval_status', 'approved')
                ->whereHas('matchEvents', $goalEventsFilter)
                ->withCount(['matchEvents as goals' => $goalEventsFilter])
                ->orderByDesc('goals')
                ->orderBy('last_name')
                ->orderBy('first_name')
                ->with(['team:id,name,short_name,logo,primary_color'])
                ->get();
        }

        $settings = SiteSetting::pluck('value', 'key');

        return Inertia::render('Goleadores', [
            'canLogin' => Route::has('login'),
            'canRegister' => Route::has('register'),
            'activeSeason' => $activeSeason,
            'topScorers' => $topScorers->map(fn ($p) => [
                'id' => $p->id,
                'first_name' => $p->first_name,
                'last_name' => $p->last_name,
                'photo' => $p->photo,
                'jersey_number' => $p->jersey_number,
                'goals' => (int) $p->goals,
                'team' => $p->team ? [
                    'id' => $p->team->id,
                    'name' => $p->team->name,
                    'short_name' => $p->team->short_name,
                    'logo' => $p->team->logo,
                    'primary_color' => $p->team->primary_color,
                ] : null,
            ])->toArray(),
            'settings' => $settings->toArray(),
        ]);
    }
}
