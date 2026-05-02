<?php

namespace App\Http\Controllers;

use App\Models\Season;
use App\Models\SiteSetting;
use App\Models\Standing;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

class StandingsController extends Controller
{
    public function __invoke()
    {
        // Active season with tournament
        $activeSeason = Season::with(['tournament'])
            ->whereIn('status', ['registration', 'group_stage', 'knockout'])
            ->orderByRaw("CASE WHEN status = 'group_stage' THEN 0 WHEN status = 'knockout' THEN 1 ELSE 2 END")
            ->first();

        // Fallback: if no active season, try getting latest non-draft season
        if (!$activeSeason) {
            $activeSeason = Season::with(['tournament'])
                ->where('status', '!=', 'draft')
                ->latest('id')
                ->first();
        }

        $seasonId = $activeSeason?->id;

        // Standings
        $standings = $seasonId
            ? Standing::with(['team:id,name,short_name,logo', 'group:id,name'])
                ->where('season_id', $seasonId)
                ->orderBy('group_id')
                ->orderBy('position')
                ->get()
            : collect();

        // Site settings
        $settings = SiteSetting::pluck('value', 'key');

        return Inertia::render('Standings', [
            'canLogin' => Route::has('login'),
            'canRegister' => Route::has('register'),
            'activeSeason' => $activeSeason,
            'standings' => $standings,
            'settings' => $settings,
        ]);
    }
}
