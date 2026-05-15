<?php

use App\Http\Controllers\Api\V1\CalendarController;
use App\Http\Controllers\Api\V1\DefenseController;
use App\Http\Controllers\Api\V1\HomeController;
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
| Endpoints públicos consumidos por la app móvil (Flutter). El sitio web
| Inertia sigue funcionando por completo sin tocar nada de routes/web.php.
|
| Rate limit: 60 req/min por IP (default global de Laravel). Para POST de
| PQRS aplicamos un límite extra más estricto para frenar spam.
|
*/

Route::prefix('v1')->group(function () {
    Route::get('home', HomeController::class)->name('api.v1.home');
    Route::get('standings', StandingsController::class)->name('api.v1.standings');
    Route::get('calendar', CalendarController::class)->name('api.v1.calendar');
    Route::get('scorers', ScorersController::class)->name('api.v1.scorers');
    Route::get('defense', DefenseController::class)->name('api.v1.defense');
    Route::get('organigram', OrganigramController::class)->name('api.v1.organigram');
    Route::get('sponsors', SponsorsController::class)->name('api.v1.sponsors');
    Route::get('verify', VerifyController::class)->name('api.v1.verify');

    Route::post('pqrs', [PqrsController::class, 'store'])
        ->middleware('throttle:10,1') // 10 PQRS por minuto por IP
        ->name('api.v1.pqrs.store');
});
