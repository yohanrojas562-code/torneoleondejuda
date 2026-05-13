<?php

use App\Http\Controllers\AcercaController;
use App\Http\Controllers\CalendarioController;
use App\Http\Controllers\EquipoController;
use App\Http\Controllers\GoleadoresController;
use App\Http\Controllers\HomeController;
use App\Http\Controllers\PatrocinadoresController;
use App\Http\Controllers\PlayerCardController;
use App\Http\Controllers\PqrsController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\StandingsController;
use App\Http\Controllers\VallaController;
use Illuminate\Foundation\Application;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

Route::get('/', HomeController::class);
Route::get('/tabla-de-posiciones', StandingsController::class)->name('standings');
Route::get('/calendario', CalendarioController::class)->name('calendario');
Route::get('/goleadores', GoleadoresController::class)->name('goleadores');
Route::get('/valla-menos-vencida', VallaController::class)->name('valla');
Route::get('/equipo', EquipoController::class)->name('equipo');
Route::get('/acerca-del-torneo', AcercaController::class)->name('acerca');
Route::get('/patrocinadores', PatrocinadoresController::class)->name('patrocinadores');

Route::get('/pqrs', [PqrsController::class, 'create'])->name('pqrs.create');
Route::post('/pqrs', [PqrsController::class, 'store'])->middleware('throttle:5,1')->name('pqrs.store');
Route::get('/pqrs/enviado/{caseNumber}', [PqrsController::class, 'success'])->name('pqrs.success');

Route::get('/dashboard', function () {
    return Inertia::render('Dashboard');
})->middleware(['auth', 'verified'])->name('dashboard');

Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');

    Route::get('/player/{player}/card', [PlayerCardController::class, 'download'])->name('player.card.download');
});

// Public signed URL for sharing player card via WhatsApp
Route::get('/player/{player}/card/share', [PlayerCardController::class, 'publicDownload'])
    ->name('player.card.public')
    ->middleware('signed');

require __DIR__.'/auth.php';
