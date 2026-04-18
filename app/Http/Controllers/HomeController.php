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

        // Approved teams in active season (or all approved if no season pivot yet)
        $teams = $seasonId
            ? Team::where(function ($q) use ($seasonId) {
                    $q->whereHas('seasons', fn ($sq) => $sq->where('seasons.id', $seasonId))
                      ->orWhereDoesntHave('seasons');
                })
                ->where('approval_status', 'approved')
                ->withCount(['players' => fn ($q) => $q->where('approval_status', 'approved')])
                ->orderBy('name')
                ->get(['id', 'name', 'short_name', 'logo', 'primary_color', 'secondary_color'])
            : Team::where('approval_status', 'approved')
                ->withCount(['players' => fn ($q) => $q->where('approval_status', 'approved')])
                ->orderBy('name')
                ->get(['id', 'name', 'short_name', 'logo', 'primary_color', 'secondary_color']);

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
