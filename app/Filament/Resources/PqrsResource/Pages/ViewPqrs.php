<?php

namespace App\Filament\Resources\PqrsResource\Pages;

use App\Filament\Resources\PqrsResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;

class ViewPqrs extends ViewRecord
{
    protected static string $resource = PqrsResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\EditAction::make()->label('Gestionar caso'),
        ];
    }
}
