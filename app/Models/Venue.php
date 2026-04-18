<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Venue extends Model
{
    protected $fillable = [
        'name', 'address', 'city', 'image', 'google_maps_embed',
        'latitude', 'longitude', 'surface_type', 'capacity',
        'description', 'is_active',
    ];

    protected function casts(): array
    {
        return [
            'latitude' => 'decimal:7',
            'longitude' => 'decimal:7',
            'is_active' => 'boolean',
        ];
    }

    public function matches(): HasMany
    {
        return $this->hasMany(GameMatch::class, 'venue_id');
    }
}
