<?php

namespace App\Filament\Resources\MisPartidosResource\Pages;

use App\Filament\Resources\MisPartidosResource;
use App\Models\Team;
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
                ->modifyQueryUsing(function (Builder $q) {
                    $teamIds = Team::where('leader_id', auth()->id())->pluck('id');
                    $q->whereIn('status', [
                            'scheduled', 'warmup', 'first_half', 'halftime',
                            'second_half', 'extra_time', 'penalties',
                            'postponed', 'suspended', 'cancelled',
                        ])
                      ->where(fn (Builder $inner) => $inner
                          ->whereIn('home_team_id', $teamIds)
                          ->orWhereIn('away_team_id', $teamIds)
                      )
                      ->orderBy('scheduled_at', 'asc');
                })
                ->icon('heroicon-m-calendar'),

            'finalizados' => Tab::make('Finalizados')
                ->modifyQueryUsing(function (Builder $q) {
                    $teamIds = Team::where('leader_id', auth()->id())->pluck('id');
                    $q->where('status', 'finished')
                      ->where(fn (Builder $inner) => $inner
                          ->whereIn('home_team_id', $teamIds)
                          ->orWhereIn('away_team_id', $teamIds)
                      )
                      ->orderByDesc('scheduled_at');
                })
                ->icon('heroicon-m-check-circle'),

            'todos' => Tab::make('Todos')
                ->modifyQueryUsing(function (Builder $q) {
                    $teamIds = Team::where('leader_id', auth()->id())->pluck('id');
                    $q->where(fn (Builder $inner) => $inner
                          ->whereIn('home_team_id', $teamIds)
                          ->orWhereIn('away_team_id', $teamIds)
                      )
                      ->orderByDesc('scheduled_at');
                })
                ->icon('heroicon-m-list-bullet'),
        ];
    }
}
