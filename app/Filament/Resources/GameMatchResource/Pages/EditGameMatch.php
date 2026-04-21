<?php

namespace App\Filament\Resources\GameMatchResource\Pages;

use App\Filament\Resources\GameMatchResource;
use App\Services\StandingsService;
use Filament\Actions;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\EditRecord;

class EditGameMatch extends EditRecord
{
    protected static string $resource = GameMatchResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\Action::make('recalculate_standings')
                ->label('Recalcular Posiciones')
                ->icon('heroicon-o-arrow-path')
                ->color('info')
                ->requiresConfirmation()
                ->modalHeading('Recalcular tabla de posiciones')
                ->modalDescription('Se recalcularán las posiciones para la temporada de este partido a partir de los partidos finalizados. ¿Continuar?')
                ->action(function (): void {
                    $seasonId = $this->record->season_id;
                    if (!$seasonId) {
                        Notification::make()
                            ->title('Este partido no tiene temporada asignada.')
                            ->warning()
                            ->send();
                        return;
                    }
                    app(StandingsService::class)->recalculateForSeason($seasonId);
                    Notification::make()
                        ->title('Tabla de posiciones actualizada correctamente.')
                        ->success()
                        ->send();
                }),
            Actions\DeleteAction::make(),
        ];
    }
}

