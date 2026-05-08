<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Sponsor extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'description',
        'logo',
        'website',
        'type',
        'social_links',
        'order',
        'is_active',
    ];

    protected $casts = [
        'social_links' => 'array',
        'is_active' => 'boolean',
    ];

    public static function typeLabels(): array
    {
        return [
            'patrocinio' => 'Patrocinador',
            'alianza' => 'Aliado',
            'apoyo' => 'Apoyo',
        ];
    }

    public static function typeSectionTitles(): array
    {
        return [
            'patrocinio' => 'Patrocinadores Oficiales',
            'alianza' => 'Alianzas',
            'apoyo' => 'Apoyo',
        ];
    }

    public static function socialPlatforms(): array
    {
        return [
            'facebook' => 'Facebook',
            'instagram' => 'Instagram',
            'twitter' => 'Twitter / X',
            'tiktok' => 'TikTok',
            'youtube' => 'YouTube',
            'linkedin' => 'LinkedIn',
            'whatsapp' => 'WhatsApp',
        ];
    }
}
