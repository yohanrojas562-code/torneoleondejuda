<?php

namespace App\Filament\Widgets;

use App\Models\Team;
use App\Models\Player;
use Filament\Widgets\ChartWidget;

class TeamsPlayersChart extends ChartWidget
{
    protected static ?string $heading = 'Jugadores por Equipo';
    protected static ?int $sort = 3;
    protected static ?string $maxHeight = '300px';

    public static function canView(): bool
    {
        return auth()->user()?->hasRole('admin');
    }

    protected function getData(): array
    {
        $teams = Team::where('approval_status', 'approved')
            ->withCount(['players' => fn ($q) => $q->where('approval_status', 'approved')])
            ->orderByDesc('players_count')
            ->limit(10)
            ->get();

        return [
            'datasets' => [
                [
                    'label' => 'Jugadores aprobados',
                    'data' => $teams->pluck('players_count')->toArray(),
                    'backgroundColor' => '#D68F03',
                    'borderColor' => '#E5A824',
                    'borderWidth' => 1,
                    'borderRadius' => 4,
                ],
            ],
            'labels' => $teams->pluck('name')->map(fn ($n) => mb_substr($n, 0, 15))->toArray(),
        ];
    }

    protected function getType(): string
    {
        return 'bar';
    }

    protected function getOptions(): array
    {
        return [
            'plugins' => [
                'legend' => ['display' => false],
            ],
            'scales' => [
                'y' => [
                    'beginAtZero' => true,
                    'ticks' => ['stepSize' => 1],
                ],
            ],
        ];
    }
}
