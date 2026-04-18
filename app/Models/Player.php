<?php

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Player extends Model
{
    protected $fillable = [
        'team_id', 'user_id', 'first_name', 'last_name',
        'document_type', 'document_number', 'birth_date', 'photo',
        'jersey_number', 'position', 'is_active',
        'eps_certificate', 'no_eps_consent', 'has_eps',
        'parental_consent', 'church',
        'approval_status', 'rejection_reason', 'observations',
        'total_matches', 'total_goals', 'yellow_cards', 'blue_cards',
        'red_cards', 'total_fouls', 'sanctions',
    ];

    protected function casts(): array
    {
        return [
            'birth_date' => 'date',
            'is_active' => 'boolean',
            'has_eps' => 'boolean',
        ];
    }

    public function team(): BelongsTo
    {
        return $this->belongsTo(Team::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function matchEvents(): HasMany
    {
        return $this->hasMany(MatchEvent::class);
    }

    public function matchLineups(): HasMany
    {
        return $this->hasMany(MatchLineup::class);
    }

    public function getFullNameAttribute(): string
    {
        return "{$this->first_name} {$this->last_name}";
    }

    public function getAgeAttribute(): ?int
    {
        return $this->birth_date ? $this->birth_date->age : null;
    }

    public function getIsMinorAttribute(): bool
    {
        return $this->age !== null && $this->age < 18;
    }
}
