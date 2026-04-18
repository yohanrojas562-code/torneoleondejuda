<?php

namespace App\Http\Controllers;

use App\Models\GameMatch;
use App\Models\Season;
use App\Models\SiteSetting;
use App\Models\Standing;
use App\Models\Team;
use App\Models\Venue;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

class HomeController extends Controller
{
    public function __invoke()
    {
        // Active season with tournament
        $activeSeason = Season::with(['tournament'])
            ->where('status', 'in_progress')
            ->orWhere('status', 'upcoming')
            ->orderByRaw("CASE WHEN status = 'in_progress' THEN 0 ELSE 1 END")
            ->first();

        $seasonId = $activeSeason?->id;

        // Approved teams in active season with approved player count
        $teams = $seasonId
            ? Team::whereHas('seasons', fn ($q) => $q->where('seasons.id', $seasonId))
                ->where('approval_status', 'approved')
                ->withCount(['players' => fn ($q) => $q->where('approval_status', 'approved')])
                ->orderBy('name')
                ->get(['id', 'name', 'short_name', 'logo', 'primary_color', 'secondary_color'])
            : collect();

        // Standings
        $standings = $seasonId
            ? Standing::with(['team:id,name,short_name,logo', 'group:id,name'])
                ->where('season_id', $seasonId)
                ->orderBy('group_id')
                ->orderBy('position')
                ->get()
            : collect();

        // Upcoming & recent matches
        $upcomingMatches = $seasonId
            ? GameMatch::with(['homeTeam:id,name,short_name,logo', 'awayTeam:id,name,short_name,logo', 'venue:id,name', 'matchDay:id,name'])
                ->where('season_id', $seasonId)
                ->whereIn('status', ['scheduled', 'in_progress'])
                ->orderBy('scheduled_at')
                ->limit(6)
                ->get()
            : collect();

        $recentMatches = $seasonId
            ? GameMatch::with(['homeTeam:id,name,short_name,logo', 'awayTeam:id,name,short_name,logo', 'venue:id,name', 'matchDay:id,name'])
                ->where('season_id', $seasonId)
                ->where('status', 'completed')
                ->orderByDesc('scheduled_at')
                ->limit(6)
                ->get()
            : collect();

        // Active venues
        $venues = Venue::where('is_active', true)->orderBy('name')->get(['id', 'name', 'address', 'city', 'image', 'surface_type', 'capacity']);

        // Site settings
        $settings = SiteSetting::pluck('value', 'key');

        return Inertia::render('Home', [
            'canLogin' => Route::has('login'),
            'canRegister' => Route::has('register'),
            'activeSeason' => $activeSeason,
            'teams' => $teams,
            'standings' => $standings,
            'upcomingMatches' => $upcomingMatches,
            'recentMatches' => $recentMatches,
            'venues' => $venues,
            'settings' => $settings,
        ]);
    }
}
