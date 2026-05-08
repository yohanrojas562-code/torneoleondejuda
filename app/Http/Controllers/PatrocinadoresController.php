<?php

namespace App\Http\Controllers;

use App\Models\SiteSetting;
use App\Models\Sponsor;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

class PatrocinadoresController extends Controller
{
    public function __invoke()
    {
        $sponsors = Sponsor::where('is_active', true)
            ->orderBy('order')
            ->orderBy('name')
            ->get();

        $settings = SiteSetting::pluck('value', 'key');

        return Inertia::render('Patrocinadores', [
            'canLogin' => Route::has('login'),
            'canRegister' => Route::has('register'),
            'sponsors' => $sponsors->map(fn ($s) => [
                'id' => $s->id,
                'name' => $s->name,
                'description' => $s->description,
                'logo' => $s->logo,
                'website' => $s->website,
                'type' => $s->type,
                'social_links' => $s->social_links ?: [],
            ])->toArray(),
            'typeLabels' => Sponsor::typeLabels(),
            'sectionTitles' => Sponsor::typeSectionTitles(),
            'settings' => $settings->toArray(),
        ]);
    }
}
