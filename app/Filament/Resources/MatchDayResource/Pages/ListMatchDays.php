<?php

namespace App\Filament\Resources\MatchDayResource\Pages;

use App\Filament\Resources\MatchDayResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListMatchDays extends ListRecords
{
    protected static string $resource = MatchDayResource::class;

    protected function getHeaderActions(): array
    {
        return [Actions\CreateAction::make()->label('Nueva Jornada')];
    }
}
