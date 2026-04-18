<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MatchEvent extends Model
{
    protected $fillable = [
        'match_id', 'team_id', 'player_id', 'secondary_player_id',
        'type', 'minute', 'half', 'notes',
    ];

    public function match(): BelongsTo
    {
        return $this->belongsTo(GameMatch::class, 'match_id');
    }

    public function team(): BelongsTo
    {
        return $this->belongsTo(Team::class);
    }

    public function player(): BelongsTo
    {
        return $this->belongsTo(Player::class);
    }

    public function secondaryPlayer(): BelongsTo
    {
        return $this->belongsTo(Player::class, 'secondary_player_id');
    }
}
