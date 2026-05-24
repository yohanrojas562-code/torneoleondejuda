<?php

use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\CalendarController;
use App\Http\Controllers\Api\V1\DefenseController;
use App\Http\Controllers\Api\V1\HomeController;
use App\Http\Controllers\Api\V1\MyDashboardController;
use App\Http\Controllers\Api\V1\OrganigramController;
use App\Http\Controllers\Api\V1\PqrsController;
use App\Http\Controllers\Api\V1\ScorersController;
use App\Http\Controllers\Api\V1\SponsorsController;
use App\Http\Controllers\Api\V1\StandingsController;
use App\Http\Controllers\Api\V1\VerifyController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes — v1
|--------------------------------------------------------------------------
|
| Endpoints públicos + endpoints autenticados via Sanctum. El sitio web
| Inertia sigue funcionando por completo sin tocar nada de routes/web.php.
|
*/

Route::prefix('v1')->group(function () {

    // ─── Públicos (sin auth) ──────────────────────────────────────
    Route::get('home', HomeController::class)->name('api.v1.home');
    Route::get('standings', StandingsController::class)->name('api.v1.standings');
    Route::get('calendar', CalendarController::class)->name('api.v1.calendar');
    Route::get('scorers', ScorersController::class)->name('api.v1.scorers');
    Route::get('defense', DefenseController::class)->name('api.v1.defense');
    Route::get('organigram', OrganigramController::class)->name('api.v1.organigram');
    Route::get('sponsors', SponsorsController::class)->name('api.v1.sponsors');
    Route::get('verify', VerifyController::class)->name('api.v1.verify');

    Route::post('pqrs', [PqrsController::class, 'store'])
        ->middleware('throttle:10,1')
        ->name('api.v1.pqrs.store');

    // ─── Autenticación (Sanctum) ──────────────────────────────────
    Route::post('auth/login', [AuthController::class, 'login'])
        ->middleware('throttle:5,1') // 5 intentos por minuto por IP (anti-brute-force)
        ->name('api.v1.auth.login');

    Route::middleware('auth:sanctum')->group(function () {
        Route::get('auth/me', [AuthController::class, 'me'])
            ->name('api.v1.auth.me');
        Route::post('auth/logout', [AuthController::class, 'logout'])
            ->name('api.v1.auth.logout');

        // ─── Dashboard / recursos del usuario autenticado ──────────
        Route::get('my/dashboard', [MyDashboardController::class, 'dashboard'])
            ->name('api.v1.my.dashboard');
        Route::get('my/teams', [MyDashboardController::class, 'teams'])
            ->name('api.v1.my.teams');
        Route::get('my/matches', [MyDashboardController::class, 'matches'])
            ->name('api.v1.my.matches');
        Route::get('my/players', [MyDashboardController::class, 'players'])
            ->name('api.v1.my.players');

        // ─── CRUD de jugadores del lider de equipo ─────────────────
        Route::get('my/players/{player}', [MyDashboardController::class, 'playerShow'])
            ->name('api.v1.my.players.show');
        Route::post('my/players', [MyDashboardController::class, 'playerCreate'])
            ->name('api.v1.my.players.create');
        Route::patch('my/players/{player}', [MyDashboardController::class, 'playerUpdate'])
            ->name('api.v1.my.players.update');
        Route::post('my/players/{player}/files', [MyDashboardController::class, 'playerUploadFile'])
            ->name('api.v1.my.players.upload');
    });
});
