<?php

namespace App\Filament\Resources\MatchDayResource\Pages;

use App\Filament\Resources\MatchDayResource;
use Filament\Resources\Pages\CreateRecord;

class CreateMatchDay extends CreateRecord
{
    protected static string $resource = MatchDayResource::class;

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }
}
