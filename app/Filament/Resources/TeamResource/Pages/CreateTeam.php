<?php

namespace App\Filament\Resources\TeamResource\Pages;

use App\Filament\Resources\TeamResource;
use Filament\Resources\Pages\CreateRecord;
use Illuminate\Support\Str;

class CreateTeam extends CreateRecord
{
    protected static string $resource = TeamResource::class;

    protected function mutateFormDataBeforeCreate(array $data): array
    {
        $user = auth()->user();

        // Auto-generar slug si no viene (líder de equipo no ve el campo slug)
        if (empty($data['slug'])) {
            $data['slug'] = Str::slug($data['name']);
        }

        // Si es líder de equipo, asignar automáticamente como líder y estado pendiente
        if ($user->hasRole('lider_equipo')) {
            $data['leader_id'] = $user->id;
            $data['approval_status'] = 'pending';
        }

        return $data;
    }

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }
}
