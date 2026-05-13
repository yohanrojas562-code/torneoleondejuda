<?php

namespace App\Http\Controllers;

use App\Models\Season;
use App\Models\SiteSetting;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

class AcercaController extends Controller
{
    public function __invoke()
    {
        $activeSeason = Season::with(['tournament'])
            ->whereIn('status', ['registration', 'group_stage', 'knockout'])
            ->orderByRaw("CASE WHEN status = 'group_stage' THEN 0 WHEN status = 'knockout' THEN 1 ELSE 2 END")
            ->first();

        if (!$activeSeason) {
            $activeSeason = Season::with(['tournament'])
                ->where('status', '!=', 'draft')
                ->latest('id')
                ->first();
        }

        $settings = SiteSetting::pluck('value', 'key');

        return Inertia::render('Acerca', [
            'canLogin' => Route::has('login'),
            'canRegister' => Route::has('register'),
            'activeSeason' => $activeSeason,
            'settings' => $settings->toArray(),
        ]);
    }
}
