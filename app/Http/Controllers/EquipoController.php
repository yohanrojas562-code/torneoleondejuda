<?php

namespace App\Http\Controllers;

use App\Models\SiteSetting;
use App\Models\TeamMember;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

class EquipoController extends Controller
{
    public function __invoke()
    {
        $members = TeamMember::where('is_active', true)
            ->orderBy('order')
            ->orderBy('name')
            ->get();

        $settings = SiteSetting::pluck('value', 'key');

        return Inertia::render('Equipo', [
            'canLogin' => Route::has('login'),
            'canRegister' => Route::has('register'),
            'members' => $members->map(fn ($m) => [
                'id' => $m->id,
                'name' => $m->name,
                'description' => $m->description,
                'photo' => $m->photo,
                'roles' => $m->roles ?: [],
                'tier' => $m->tier,
                'order' => $m->order,
            ])->toArray(),
            'roleLabels' => TeamMember::roleLabels(),
            'settings' => $settings->toArray(),
        ]);
    }
}
