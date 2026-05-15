<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Api\V1\Concerns\ResolvesActiveSeason;
use App\Http\Controllers\Controller;
use App\Http\Resources\Api\GoalkeeperResource;
use App\Models\Player;
use App\Models\Standing;

class DefenseController extends Controller
{
    use ResolvesActiveSeason;

    public function __invoke()
    {
        $season = $this->activeSeason();
        $seasonId = $season?->id;

        $items = collect();

        if ($seasonId) {
            $standings = Standing::with('team')
                ->where('season_id', $seasonId)
                ->where('played', '>', 0)
                ->orderBy('goals_against', 'asc')
                ->orderByDesc('goals_for')
                ->get();

            $teamIds = $standings->pluck('team_id')->unique()->all();

            // Espeja la lógica del web: prioridad titular > suplente > sin tipo
            $goalkeepers = Player::query()
                ->whereIn('team_id', $teamIds)
                ->where('approval_status', 'approved')
                ->whereRaw('LOWER(position) = ?', ['portero'])
                ->orderByRaw(
                    "CASE WHEN LOWER(goalkeeper_type) = 'titular' THEN 0 ".
                    "WHEN LOWER(goalkeeper_type) = 'suplente' THEN 1 ELSE 2 END"
                )
                ->orderBy('jersey_number')
                ->orderBy('last_name')
                ->with('team')
                ->get()
                ->groupBy('team_id')
                ->map(fn ($group) => $group->first());

            $rank = 0;
            $items = $standings
                ->filter(fn ($s) => $goalkeepers->has($s->team_id))
                ->map(function ($s) use ($goalkeepers, &$rank) {
                    $gk = $goalkeepers->get($s->team_id);
                    $rank++;

                    // Clean sheets = partidos finalizados de este equipo donde
                    // recibió 0 goles. La lógica completa requiere mirar GameMatch.
                    // Como aproximación mientras se computa el campo real,
                    // dejamos en 0 si no hay forma de saber sin extra query.
                    $cleanSheets = $this->computeCleanSheets(
                        teamId: $s->team_id,
                        seasonId: $s->season_id,
                    );

                    return new GoalkeeperResource(
                        $gk,
                        rank: $rank,
                        goalsAgainst: (int) $s->goals_against,
                        matchesPlayed: (int) $s->played,
                        cleanSheets: $cleanSheets,
                    );
                })
                ->values();
        }

        return response()->json([
            'active_season' => $season ? [
                'id' => $season->id,
                'name' => $season->name,
            ] : null,
            'defenses' => $items,
        ]);
    }

    /**
     * Cuenta partidos finalizados donde el equipo no recibió goles.
     * Se hace por equipo (no por portero individual) — coincide con cómo se
     * computa la "valla invicta" del web.
     */
    private function computeCleanSheets(int $teamId, int $seasonId): int
    {
        return \App\Models\GameMatch::query()
            ->where('season_id', $seasonId)
            ->where('status', 'finished')
            ->where(function ($q) use ($teamId) {
                $q->where(function ($home) use ($teamId) {
                    $home->where('home_team_id', $teamId)
                        ->where('away_score', 0);
                })->orWhere(function ($away) use ($teamId) {
                    $away->where('away_team_id', $teamId)
                        ->where('home_score', 0);
                });
            })
            ->count();
    }
}
