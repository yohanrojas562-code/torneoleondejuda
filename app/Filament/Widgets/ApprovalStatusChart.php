<?php

namespace App\Filament\Widgets;

use App\Models\Team;
use App\Models\Player;
use Filament\Widgets\ChartWidget;

class ApprovalStatusChart extends ChartWidget
{
    protected static ?string $heading = 'Estado de Aprobaciones';
    protected static ?int $sort = 4;
    protected static ?string $maxHeight = '280px';

    public static function canView(): bool
    {
        return auth()->user()?->hasRole('admin');
    }

    protected function getData(): array
    {
        $teamsPending = Team::where('approval_status', 'pending')->count();
        $teamsApproved = Team::where('approval_status', 'approved')->count();
        $teamsRejected = Team::where('approval_status', 'rejected')->count();

        $playersPending = Player::where('approval_status', 'pending')->count();
        $playersApproved = Player::where('approval_status', 'approved')->count();
        $playersRejected = Player::where('approval_status', 'rejected')->count();

        return [
            'datasets' => [
                [
                    'label' => 'Equipos',
                    'data' => [$teamsPending, $teamsApproved, $teamsRejected],
                    'backgroundColor' => 'rgba(214, 143, 3, 0.8)',
                    'borderColor' => '#D68F03',
                    'borderWidth' => 2,
                ],
                [
                    'label' => 'Jugadores',
                    'data' => [$playersPending, $playersApproved, $playersRejected],
                    'backgroundColor' => 'rgba(229, 168, 36, 0.6)',
                    'borderColor' => '#E5A824',
                    'borderWidth' => 2,
                ],
            ],
            'labels' => ['Pendientes', 'Aprobados', 'Rechazados'],
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
                'legend' => ['position' => 'bottom'],
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
