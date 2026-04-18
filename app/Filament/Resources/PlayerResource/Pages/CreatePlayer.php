<?php

namespace App\Filament\Resources\PlayerResource\Pages;

use App\Filament\Resources\PlayerResource;
use App\Models\Team;
use Filament\Resources\Pages\CreateRecord;
use Filament\Notifications\Notification;

class CreatePlayer extends CreateRecord
{
    protected static string $resource = PlayerResource::class;

    protected function mutateFormDataBeforeCreate(array $data): array
    {
        $user = auth()->user();

        if ($user->hasRole('lider_equipo')) {
            $team = Team::where('leader_id', $user->id)->first();

            if ($team) {
                $data['team_id'] = $team->id;
                $data['approval_status'] = 'pending';

                // Validar límite de 12 jugadores
                $playerCount = $team->players()->count();
                if ($playerCount >= 12 && empty($data['special_request'])) {
                    Notification::make()
                        ->title('Límite de jugadores alcanzado')
                        ->body('Tu equipo ya tiene 12 jugadores. Debes hacer una solicitud especial.')
                        ->danger()
                        ->send();

                    $this->halt();
                }
            }
        }

        return $data;
    }

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }
}
