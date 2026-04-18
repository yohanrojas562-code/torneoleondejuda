<?php

namespace App\Filament\Resources\PlayerResource\Pages;

use App\Filament\Resources\PlayerResource;
use Filament\Resources\Pages\EditRecord;
use Filament\Actions;

class EditPlayer extends EditRecord
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
                ->url(fn () => 'https://wa.me/?text=' . urlencode(
                    "\xF0\x9F\x8F\x86 *Carnet de Jugador - {$this->record->full_name}*\n" .
                    "\xF0\x9F\x91\x95 Equipo: {$this->record->team?->name}\n" .
                    "\xF0\x9F\x93\x84 Descarga el carnet aqu\u00ed:\n" .
                    route('player.card.download', $this->record)
                ))
                ->openUrlInNewTab(),

            Actions\ViewAction::make(),
            Actions\DeleteAction::make(),
        ];
    }

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }
}
