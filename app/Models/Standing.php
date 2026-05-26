<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Standing extends Model
{
    protected $fillable = [
        'season_id', 'group_id', 'team_id',
        'played', 'won', 'drawn', 'lost',
        'goals_for', 'goals_against', 'goal_difference',
        'points', 'position', 'form',
        'yellow_cards', 'blue_cards', 'red_cards', 'fair_play_points',
        // Offsets manuales: preservan ajustes del admin entre recálculos.
        // Ver migracion add_manual_offsets_to_standings_table.
        'manual_played', 'manual_won', 'manual_drawn', 'manual_lost',
        'manual_goals_for', 'manual_goals_against', 'manual_points',
        'manual_yellow_cards', 'manual_blue_cards', 'manual_red_cards',
    ];

    protected function casts(): array
    {
        return ['form' => 'json'];
    }

    public function season(): BelongsTo
    {
        return $this->belongsTo(Season::class);
    }

    public function group(): BelongsTo
    {
        return $this->belongsTo(Group::class);
    }

    public function team(): BelongsTo
    {
        return $this->belongsTo(Team::class);
    }
}
