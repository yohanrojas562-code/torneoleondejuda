<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TeamMember extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'description',
        'photo',
        'roles',
        'order',
        'is_active',
    ];

    protected $casts = [
        'roles' => 'array',
        'is_active' => 'boolean',
    ];

    public static function roleLabels(): array
    {
        return [
            'director' => 'Director',
            'codirector' => 'Codirector',
            'coordinador' => 'Coordinador',
            'tesorero' => 'Tesorero',
            'tecnologia' => 'Tecnología',
            'veedor' => 'Veedor',
            'oracion' => 'Oración',
            'apoyo_logistico' => 'Apoyo Logístico',
        ];
    }

    public static function tierFor(?array $roles): int
    {
        $roles = $roles ?: [];
        if (array_intersect(['director', 'codirector'], $roles)) {
            return 1;
        }
        if (in_array('coordinador', $roles)) {
            return 2;
        }
        return 3;
    }

    public function getTierAttribute(): int
    {
        return static::tierFor($this->roles);
    }
}
