<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class GameMatch extends Model
{
    protected $table = 'matches';

    protected $fillable = [
        'season_id', 'match_day_id', 'home_team_id', 'away_team_id',
        'referee_id', 'scheduled_at', 'venue', 'venue_id',
        'home_score', 'away_score', 'home_penalty_score', 'away_penalty_score',
        'home_yellow_cards', 'home_blue_cards', 'home_red_cards',
        'away_yellow_cards', 'away_blue_cards', 'away_red_cards',
        'status', 'observations',
    ];

    protected function casts(): array
    {
        return ['scheduled_at' => 'datetime'];
    }

    public function season(): BelongsTo
    {
        return $this->belongsTo(Season::class);
    }

    public function matchDay(): BelongsTo
    {
        return $this->belongsTo(MatchDay::class);
    }

    public function homeTeam(): BelongsTo
    {
        return $this->belongsTo(Team::class, 'home_team_id');
    }

    public function awayTeam(): BelongsTo
    {
        return $this->belongsTo(Team::class, 'away_team_id');
    }

    public function referee(): BelongsTo
    {
        return $this->belongsTo(User::class, 'referee_id');
    }

    public function venue(): BelongsTo
    {
        return $this->belongsTo(Venue::class);
    }

    public function lineups(): HasMany
    {
        return $this->hasMany(MatchLineup::class, 'match_id');
    }

    public function events(): HasMany
    {
        return $this->hasMany(MatchEvent::class, 'match_id');
    }

    public function isLive(): bool
    {
        return in_array($this->status, ['first_half', 'second_half', 'halftime', 'extra_time', 'penalties']);
    }
}
