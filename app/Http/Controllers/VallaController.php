<?php

namespace App\Http\Controllers;

use App\Models\Player;
use App\Models\Season;
use App\Models\SiteSetting;
use App\Models\Standing;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

class VallaController extends Controller
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

        $rows = collect();

        if ($seasonId) {
            $standings = Standing::with(['team:id,name,short_name,logo,primary_color'])
                ->where('season_id', $seasonId)
                ->where('played', '>', 0)
                ->orderBy('goals_against', 'asc')
                ->orderByDesc('goals_for')
                ->get();

            $teamIds = $standings->pluck('team_id')->unique()->all();

            $goalkeepers = Player::query()
                ->whereIn('team_id', $teamIds)
                ->where('approval_status', 'approved')
                ->whereRaw('LOWER(position) = ?', ['portero'])
                ->orderBy('jersey_number')
                ->orderBy('last_name')
                ->get(['id', 'team_id', 'first_name', 'last_name', 'photo', 'jersey_number', 'church'])
                ->groupBy('team_id')
                ->map(fn ($group) => $group->first());

            $rows = $standings->map(function ($s) use ($goalkeepers) {
                $gk = $goalkeepers->get($s->team_id);
                return [
                    'id' => $s->id,
                    'team' => $s->team ? [
                        'id' => $s->team->id,
                        'name' => $s->team->name,
                        'short_name' => $s->team->short_name,
                        'logo' => $s->team->logo,
                        'primary_color' => $s->team->primary_color,
                    ] : null,
                    'goalkeeper' => $gk ? [
                        'id' => $gk->id,
                        'first_name' => $gk->first_name,
                        'last_name' => $gk->last_name,
                        'photo' => $gk->photo,
                        'jersey_number' => $gk->jersey_number,
                        'church' => $gk->church,
                    ] : null,
                    'played' => (int) $s->played,
                    'goals_against' => (int) $s->goals_against,
                    'goals_for' => (int) $s->goals_for,
                ];
            });
        }

        $settings = SiteSetting::pluck('value', 'key');

        return Inertia::render('Valla', [
            'canLogin' => Route::has('login'),
            'canRegister' => Route::has('register'),
            'activeSeason' => $activeSeason,
            'rows' => $rows->toArray(),
            'settings' => $settings->toArray(),
        ]);
    }
}
