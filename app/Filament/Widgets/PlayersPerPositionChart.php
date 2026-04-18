<?php

namespace App\Filament\Widgets;

use App\Models\Player;
use Filament\Widgets\ChartWidget;

class PlayersPerPositionChart extends ChartWidget
{
    protected static ?string $heading = 'Jugadores por Posición';
    protected static ?int $sort = 2;
    protected static ?string $maxHeight = '280px';

    public static function canView(): bool
    {
        return auth()->user()?->hasRole('admin');
    }

    protected function getData(): array
    {
        $positions = [
            'portero' => 'Porteros',
            'defensa' => 'Defensas',
            'mediocampista' => 'Mediocampistas',
            'delantero' => 'Delanteros',
        ];

        $counts = [];
        $labels = [];
        foreach ($positions as $key => $label) {
            $counts[] = Player::where('position', $key)->where('approval_status', 'approved')->count();
            $labels[] = $label;
        }

        return [
            'datasets' => [
                [
                    'label' => 'Jugadores',
                    'data' => $counts,
                    'backgroundColor' => ['#D68F03', '#E5A824', '#FFD966', '#FFF0BF'],
                    'borderColor' => '#0a0a0a',
                    'borderWidth' => 2,
                ],
            ],
            'labels' => $labels,
        ];
    }

    protected function getType(): string
    {
        return 'doughnut';
    }

    protected function getOptions(): array
    {
        return [
            'plugins' => [
                'legend' => [
                    'position' => 'bottom',
                ],
            ],
        ];
    }
}
