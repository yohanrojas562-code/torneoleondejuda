<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Tournament extends Model
{
    protected $fillable = [
        'name', 'slug', 'description', 'logo', 'banner',
        'start_date', 'end_date', 'venue', 'rules', 'status', 'is_active',
    ];

    protected function casts(): array
    {
        return [
            'start_date' => 'date',
            'end_date' => 'date',
            'is_active' => 'boolean',
        ];
    }

    public function seasons(): HasMany
    {
        return $this->hasMany(Season::class);
    }
}
