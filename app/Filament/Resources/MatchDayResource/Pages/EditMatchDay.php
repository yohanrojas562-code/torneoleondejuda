<?php

namespace App\Filament\Resources\MatchDayResource\Pages;

use App\Filament\Resources\MatchDayResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditMatchDay extends EditRecord
{
    protected static string $resource = MatchDayResource::class;

    protected function getHeaderActions(): array
    {
        return [Actions\DeleteAction::make()];
    }
}
