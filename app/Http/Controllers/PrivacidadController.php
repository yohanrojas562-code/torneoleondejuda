<?php

namespace App\Http\Controllers;

use App\Models\SiteSetting;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

class PrivacidadController extends Controller
{
    public function __invoke()
    {
        $settings = SiteSetting::pluck('value', 'key');

        return Inertia::render('Privacidad', [
            'canLogin' => Route::has('login'),
            'canRegister' => Route::has('register'),
            'settings' => $settings->toArray(),
            'lastUpdated' => '2026-06-11',
        ]);
    }
}
