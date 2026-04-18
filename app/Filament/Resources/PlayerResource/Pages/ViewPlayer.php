<?php

namespace App\Filament\Resources\PlayerResource\Pages;

use App\Filament\Resources\PlayerResource;
use App\Services\PlayerCardService;
use Filament\Resources\Pages\ViewRecord;
use Filament\Actions;
use Filament\Notifications\Notification;
use Illuminate\Support\Facades\URL;

class ViewPlayer extends ViewRecord
{
    protected static string $resource = PlayerResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\Action::make('downloadCard')
                ->label('Descargar Carnet')
                ->icon('heroicon-o-identification')
                ->color('success')
                ->visible(fn () => $this->record->approval_status === 'approved')
                ->url(fn () => route('player.card.download', $this->record))
                ->openUrlInNewTab(),

            Actions\Action::make('shareWhatsApp')
                ->label('Compartir por WhatsApp')
                ->icon('heroicon-o-share')
                ->color('info')
                ->visible(fn () => $this->record->approval_status === 'approved')
                ->url(function () {
                    $signedUrl = URL::signedRoute('player.card.public', ['player' => $this->record->id]);
                    return 'https://wa.me/?text=' . urlencode(
                        "\xF0\x9F\x8F\x86 *Carnet de Jugador - {$this->record->full_name}*\n" .
                        "\xF0\x9F\x91\x95 Equipo: {$this->record->team?->name}\n" .
                        "\xF0\x9F\x93\x84 Descarga el carnet aqu\u00ed:\n" .
                        $signedUrl
                    );
                })
                ->openUrlInNewTab(),

            Actions\EditAction::make(),
        ];
    }
}
