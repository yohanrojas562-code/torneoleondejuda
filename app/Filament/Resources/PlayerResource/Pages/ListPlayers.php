<?php

namespace App\Filament\Resources\PlayerResource\Pages;

use App\Filament\Resources\PlayerResource;
use App\Models\Team;
use App\Policies\PlayerPolicy;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListPlayers extends ListRecords
{
    protected static string $resource = PlayerResource::class;

    protected function getHeaderActions(): array
    {
        $user = auth()->user();
        $actions = [];

        // CreateAction se auto-oculta si la policy::create devuelve false.
        // Para lideres con 12 jugadores, la policy bloquea y el boton no aparece.
        $actions[] = Actions\CreateAction::make();

        // Para lideres que ya llegaron al cupo, mostramos un boton informativo
        // que abre un modal explicando que deben generar una PQRS.
        if ($user && !$user->hasRole('admin') && $user->hasRole('lider_equipo')) {
            $team = Team::where('leader_id', $user->id)->first();
            $activeCount = $team
                ? $team->players()
                    ->whereIn('approval_status', ['approved', 'pending'])
                    ->count()
                : 0;

            if ($activeCount >= PlayerPolicy::MAX_PLAYERS_PER_TEAM) {
                $actions[] = Actions\Action::make('player_change_pqrs')
                    ->label('Solicitar cambio de jugador')
                    ->icon('heroicon-o-exclamation-triangle')
                    ->color('warning')
                    ->modalHeading('Tu equipo ya tiene ' . PlayerPolicy::MAX_PLAYERS_PER_TEAM . ' jugadores registrados')
                    ->modalDescription('Para cambiar un jugador debes generar una PQRS de tipo "Petición" o "Apelación" indicando el nombre del jugador a reemplazar y el motivo. Un administrador revisará tu solicitud y te ayudará con el cambio. Los líderes no pueden eliminar jugadores directamente para evitar inconsistencias.')
                    ->modalSubmitActionLabel('Ir a generar PQRS')
                    ->modalCancelActionLabel('Entendido')
                    ->action(fn () => redirect('/pqrs'));
            }
        }

        return $actions;
    }
}
