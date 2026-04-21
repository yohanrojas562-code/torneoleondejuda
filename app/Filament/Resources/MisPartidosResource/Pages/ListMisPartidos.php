<?php

namespace App\Filament\Resources\MisPartidosResource\Pages;

use App\Filament\Resources\MisPartidosResource;
use Filament\Resources\Pages\ListRecords;
use Filament\Resources\Pages\ListRecords\Tab;
use Illuminate\Database\Eloquent\Builder;

class ListMisPartidos extends ListRecords
{
    protected static string $resource = MisPartidosResource::class;

    protected function getHeaderActions(): array
    {
        return [];
    }

    public function getTabs(): array
    {
        return [
            'proximos' => Tab::make('Próximos')
                ->modifyQueryUsing(fn (Builder $q) => $q
                    ->whereIn('status', [
                        'scheduled', 'warmup', 'first_half', 'halftime',
                        'second_half', 'extra_time', 'penalties',
                        'postponed', 'suspended', 'cancelled',
                    ])
                    ->orderBy('scheduled_at', 'asc')
                )
                ->icon('heroicon-m-calendar'),

            'finalizados' => Tab::make('Finalizados')
                ->modifyQueryUsing(fn (Builder $q) => $q
                    ->where('status', 'finished')
                    ->orderByDesc('scheduled_at')
                )
                ->icon('heroicon-m-check-circle'),

            'todos' => Tab::make('Todos')
                ->modifyQueryUsing(fn (Builder $q) => $q->orderByDesc('scheduled_at'))
                ->icon('heroicon-m-list-bullet'),
        ];
    }
}
