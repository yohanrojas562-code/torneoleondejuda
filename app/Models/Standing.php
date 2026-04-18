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
