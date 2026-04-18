<?php

use App\Http\Controllers\HomeController;
use App\Http\Controllers\PlayerCardController;
use App\Http\Controllers\ProfileController;
use Illuminate\Foundation\Application;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

Route::get('/', HomeController::class);

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
