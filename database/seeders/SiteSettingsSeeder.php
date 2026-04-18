<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\SiteSetting;

class SiteSettingsSeeder extends Seeder
{
    public function run(): void
    {
        $settings = [
            ['key' => 'site_name', 'value' => 'Torneo León de Judá', 'type' => 'text', 'group' => 'general'],
            ['key' => 'site_description', 'value' => 'Torneo deportivo de la iglesia CFE Manrique La Salle. Mostrando a Cristo a través del deporte.', 'type' => 'text', 'group' => 'general'],
            ['key' => 'church_name', 'value' => 'Centro de Fe y Esperanza Manrique La Salle', 'type' => 'text', 'group' => 'general'],
            ['key' => 'logo', 'value' => null, 'type' => 'image', 'group' => 'general'],
            ['key' => 'banner_home', 'value' => null, 'type' => 'image', 'group' => 'home'],
            ['key' => 'home_title', 'value' => 'Torneo León de Judá', 'type' => 'text', 'group' => 'home'],
            ['key' => 'home_subtitle', 'value' => 'Mostrando a Cristo a través del deporte', 'type' => 'text', 'group' => 'home'],
            ['key' => 'rules_content', 'value' => null, 'type' => 'html', 'group' => 'rules'],
            ['key' => 'contact_email', 'value' => null, 'type' => 'text', 'group' => 'contact'],
            ['key' => 'contact_phone', 'value' => null, 'type' => 'text', 'group' => 'contact'],
            ['key' => 'social_facebook', 'value' => null, 'type' => 'text', 'group' => 'social'],
            ['key' => 'social_instagram', 'value' => null, 'type' => 'text', 'group' => 'social'],
        ];

        foreach ($settings as $setting) {
            SiteSetting::firstOrCreate(
                ['key' => $setting['key']],
                $setting
            );
        }
    }
}
