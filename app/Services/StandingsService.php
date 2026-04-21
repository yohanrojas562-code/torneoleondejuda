<?php

namespace App\Services;

use App\Models\GameMatch;
use App\Models\MatchEvent;
use App\Models\Player;
use App\Models\Season;
use App\Models\Standing;
use Illuminate\Support\Facades\DB;

class StandingsService
{
    /**
     * Recalculate standings for the given season from finished matches.
     * Also updates player stats (goals, cards, fouls) from match events.
     */
    public function recalculateForSeason(int $seasonId): void
    {
        $season = Season::with('teams')->find($seasonId);
        if (!$season) {
            return;
        }

        // All teams registered to this season
        $teamIds = $season->teams->pluck('id')->toArray();
        if (empty($teamIds)) {
            return;
        }

        // All finished matches for this season
        $matches = GameMatch::where('season_id', $seasonId)
            ->where('status', 'finished')
            ->get();

        // Initialize per-team stats
        $stats = [];
        foreach ($teamIds as $teamId) {
            $stats[$teamId] = [
                'team_id'          => $teamId,
                'season_id'        => $seasonId,
                'group_id'         => $this->resolveGroupId($seasonId, $teamId),
                'played'           => 0,
                'won'              => 0,
                'drawn'            => 0,
                'lost'             => 0,
                'goals_for'        => 0,
                'goals_against'    => 0,
                'goal_difference'  => 0,
                'points'           => 0,
                'yellow_cards'     => 0,
                'blue_cards'       => 0,
                'red_cards'        => 0,
                'fair_play_points' => 0,
                'form'             => [],
            ];
        }

        // Process each finished match
        foreach ($matches as $match) {
            $homeId    = $match->home_team_id;
            $awayId    = $match->away_team_id;
            $homeScore = $match->home_score ?? 0;
            $awayScore = $match->away_score ?? 0;

            if (!isset($stats[$homeId], $stats[$awayId])) {
                continue;
            }

            $stats[$homeId]['played']++;
            $stats[$homeId]['goals_for']     += $homeScore;
            $stats[$homeId]['goals_against'] += $awayScore;

            $stats[$awayId]['played']++;
            $stats[$awayId]['goals_for']     += $awayScore;
            $stats[$awayId]['goals_against'] += $homeScore;

            if ($homeScore > $awayScore) {
                $stats[$homeId]['won']++;
                $stats[$homeId]['points'] += 3;
                $stats[$homeId]['form'][]  = 'W';
                $stats[$awayId]['lost']++;
                $stats[$awayId]['form'][] = 'L';
            } elseif ($awayScore > $homeScore) {
                $stats[$awayId]['won']++;
                $stats[$awayId]['points'] += 3;
                $stats[$awayId]['form'][]  = 'W';
                $stats[$homeId]['lost']++;
                $stats[$homeId]['form'][] = 'L';
            } else {
                $stats[$homeId]['drawn']++;
                $stats[$homeId]['points'] += 1;
                $stats[$homeId]['form'][]  = 'D';
                $stats[$awayId]['drawn']++;
                $stats[$awayId]['points'] += 1;
                $stats[$awayId]['form'][]  = 'D';
            }
        }

        // Compute goal difference and trim form history
        foreach ($stats as &$teamStats) {
            $teamStats['goal_difference'] = $teamStats['goals_for'] - $teamStats['goals_against'];
            $teamStats['form']            = array_slice($teamStats['form'], -5);
        }
        unset($teamStats);

        // Aggregate card totals from match direct fields
        foreach ($matches as $match) {
            $homeId = $match->home_team_id;
            $awayId = $match->away_team_id;
            if (isset($stats[$homeId])) {
                $stats[$homeId]['yellow_cards'] += $match->home_yellow_cards ?? 0;
                $stats[$homeId]['blue_cards']   += $match->home_blue_cards   ?? 0;
                $stats[$homeId]['red_cards']    += $match->home_red_cards    ?? 0;
            }
            if (isset($stats[$awayId])) {
                $stats[$awayId]['yellow_cards'] += $match->away_yellow_cards ?? 0;
                $stats[$awayId]['blue_cards']   += $match->away_blue_cards   ?? 0;
                $stats[$awayId]['red_cards']    += $match->away_red_cards    ?? 0;
            }
        }

        // Calculate fair play points: yellow=-1, blue=-3, red=-5
        foreach ($stats as &$teamStats) {
            $teamStats['fair_play_points'] =
                ($teamStats['yellow_cards'] * -1) +
                ($teamStats['blue_cards']   * -3) +
                ($teamStats['red_cards']    * -5);
        }
        unset($teamStats);

        $matchIds = $matches->pluck('id')->toArray();

        // Sort by: 1.Points 2.Goal diff 3.Goals for 4.Goals against 5.Total cards (fair play)
        uasort($stats, static function (array $a, array $b): int {
            if ($b['points'] !== $a['points']) {
                return $b['points'] - $a['points'];
            }
            if ($b['goal_difference'] !== $a['goal_difference']) {
                return $b['goal_difference'] - $a['goal_difference'];
            }
            if ($b['goals_for'] !== $a['goals_for']) {
                return $b['goals_for'] - $a['goals_for'];
            }
            if ($a['goals_against'] !== $b['goals_against']) {
                return $a['goals_against'] - $b['goals_against'];
            }
            // Higher fair_play_points (closer to 0) = better position
            return $b['fair_play_points'] - $a['fair_play_points'];
        });

        // Assign positions and persist
        $position = 1;
        foreach ($stats as $teamStats) {
            $teamStats['position'] = $position++;
            Standing::updateOrCreate(
                [
                    'season_id' => $seasonId,
                    'team_id'   => $teamStats['team_id'],
                    'group_id'  => $teamStats['group_id'],
                ],
                $teamStats
            );
        }

        // Update individual player stats for all processed matches
        if (!empty($matchIds)) {
            $this->updatePlayerStats($matchIds);
        }
    }

    /**
     * Resolve the group_id for a team within a season via group_team pivot.
     */
    protected function resolveGroupId(int $seasonId, int $teamId): ?int
    {
        try {
            return DB::table('group_team')
                ->join('groups', 'groups.id', '=', 'group_team.group_id')
                ->where('group_team.team_id', $teamId)
                ->where('groups.season_id', $seasonId)
                ->value('group_team.group_id');
        } catch (\Throwable) {
            return null;
        }
    }

    /**
     * Update player stat counters from events in the given matches.
     * Counts are absolute totals (recalculated, not incremented).
     */
    protected function updatePlayerStats(array $matchIds): void
    {
        $playerIds = MatchEvent::whereIn('match_id', $matchIds)
            ->whereNotNull('player_id')
            ->distinct()
            ->pluck('player_id')
            ->toArray();

        foreach ($playerIds as $playerId) {
            $events = MatchEvent::whereIn('match_id', $matchIds)
                ->where('player_id', $playerId)
                ->get();

            Player::where('id', $playerId)->update([
                'total_goals'  => $events->whereIn('type', ['goal', 'penalty_goal'])->count(),
                'yellow_cards' => $events->whereIn('type', ['yellow_card', 'second_yellow'])->count(),
                'blue_cards'   => $events->where('type', 'blue_card')->count(),
                'red_cards'    => $events->where('type', 'red_card')->count(),
                'total_fouls'  => $events->where('type', 'foul')->count(),
            ]);
        }
    }
}
