<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Team extends Model
{
    protected $fillable = [
        'name', 'slug', 'short_name', 'logo',
        'primary_color', 'secondary_color',
        'leader_id', 'captain_id', 'is_active',
        'approval_status', 'rejection_reason',
        'pastor_name', 'pastor_authorization',
    ];

    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
            'pastor_authorization' => 'boolean',
        ];
    }

    public function leader(): BelongsTo
    {
        return $this->belongsTo(User::class, 'leader_id');
    }

    public function captain(): BelongsTo
    {
        return $this->belongsTo(User::class, 'captain_id');
    }

    public function players(): HasMany
    {
        return $this->hasMany(Player::class);
    }

    public function seasons(): BelongsToMany
    {
        return $this->belongsToMany(Season::class)->withPivot('group', 'status')->withTimestamps();
    }

    public function groups(): BelongsToMany
    {
        return $this->belongsToMany(Group::class);
    }

    public function homeMatches(): HasMany
    {
        return $this->hasMany(GameMatch::class, 'home_team_id');
    }

    public function awayMatches(): HasMany
    {
        return $this->hasMany(GameMatch::class, 'away_team_id');
    }
}
