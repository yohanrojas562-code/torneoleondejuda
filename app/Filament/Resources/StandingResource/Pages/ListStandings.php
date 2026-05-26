<?php

namespace App\Filament\Resources\StandingResource\Pages;

use App\Filament\Resources\StandingResource;
use App\Models\Season;
use App\Services\StandingsService;
use Filament\Actions;
use Filament\Forms;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\ListRecords;

class ListStandings extends ListRecords
{
    protected static string $resource = StandingResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make()->label('Nueva Entrada'),

            Actions\Action::make('recalculate_from_matches')
                ->label('Recalcular desde partidos')
                ->icon('heroicon-o-arrow-path')
                ->color('warning')
                ->visible(fn () => auth()->user()?->hasRole('admin'))
                ->modalHeading('Recalcular tabla desde partidos finalizados')
                ->modalDescription('Recalcula las estadisticas (PG, PE, PP, GF, GC, PTS, FairPlay, posicion, tarjetas y stats de jugadores) de la temporada seleccionada usando los partidos marcados como "finalizado". Los ajustes manuales que hayas hecho (PJ, PTS, tarjetas) se PRESERVAN y se SUMAN al recalculo — no se borran. Usa esto cada vez que cargues nuevos resultados para que la tabla refleje partidos + manuales.')
                ->form([
                    Forms\Components\Select::make('season_id')
                        ->label('Temporada')
                        ->options(function () {
                            return Season::with('tournament')
                                ->where('status', '!=', 'draft')
                                ->orderByDesc('id')
                                ->get()
                                ->mapWithKeys(fn ($s) => [
                                    $s->id => ($s->tournament?->name ?? 'Sin torneo')
                                        . ' — ' . $s->name
                                        . ' (' . $s->status . ')',
                                ])
                                ->all();
                        })
                        ->default(function () {
                            $active = Season::whereIn('status', ['group_stage', 'knockout', 'registration'])
                                ->orderByRaw("CASE WHEN status = 'group_stage' THEN 0 WHEN status = 'knockout' THEN 1 ELSE 2 END")
                                ->first();
                            return $active?->id;
                        })
                        ->required()
                        ->searchable()
                        ->preload(),
                ])
                ->action(function (array $data) {
                    $seasonId = (int) $data['season_id'];

                    try {
                        StandingsService::recalculateForSeason($seasonId);

                        Notification::make()
                            ->title('Tabla recalculada')
                            ->body('Las estadisticas se actualizaron desde los partidos finalizados.')
                            ->success()
                            ->send();
                    } catch (\Throwable $e) {
                        Notification::make()
                            ->title('Error al recalcular')
                            ->body($e->getMessage())
                            ->danger()
                            ->send();
                    }
                })
                ->modalSubmitActionLabel('Si, recalcular')
                ->modalCancelActionLabel('Cancelar'),
        ];
    }
}
