<?php

namespace App\Filament\Widgets;

use App\Models\Team;
use App\Models\Player;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class LeaderStatsOverview extends BaseWidget
{
    protected static ?int $sort = 1;

    public static function canView(): bool
    {
        return auth()->user()?->hasRole('lider_equipo');
    }

    protected function getStats(): array
    {
        $user = auth()->user();
        $team = Team::where('leader_id', $user->id)->first();

        if (!$team) {
            return [
                Stat::make('Mi Equipo', 'Sin equipo')
                    ->description('Crea tu equipo desde el menú Equipos')
                    ->descriptionIcon('heroicon-m-plus-circle')
                    ->color('warning'),
            ];
        }

        $totalPlayers = Player::where('team_id', $team->id)->count();
        $approvedPlayers = Player::where('team_id', $team->id)->where('approval_status', 'approved')->count();
        $pendingPlayers = Player::where('team_id', $team->id)->where('approval_status', 'pending')->count();
        $rejectedPlayers = Player::where('team_id', $team->id)->where('approval_status', 'rejected')->count();
        $spotsLeft = max(0, 12 - $totalPlayers);

        $teamStatusLabel = match ($team->approval_status) {
            'approved' => '✅ Aprobado',
            'pending' => '⏳ Pendiente',
            'rejected' => '❌ Rechazado',
            default => 'Pendiente',
        };

        $teamStatusColor = match ($team->approval_status) {
            'approved' => 'success',
            'pending' => 'warning',
            'rejected' => 'danger',
            default => 'warning',
        };

        return [
            Stat::make('Mi Equipo', $team->name)
                ->description("Estado: {$teamStatusLabel}")
                ->descriptionIcon('heroicon-m-shield-check')
                ->color($teamStatusColor),

            Stat::make('Jugadores Inscritos', "{$totalPlayers} / 12")
                ->description("{$approvedPlayers} aprobados · {$pendingPlayers} pendientes" . ($rejectedPlayers > 0 ? " · {$rejectedPlayers} rechazados" : ''))
                ->descriptionIcon('heroicon-m-user-group')
                ->chart([$approvedPlayers, $pendingPlayers, $rejectedPlayers])
                ->color($totalPlayers >= 12 ? 'danger' : 'success'),

            Stat::make('Cupos Disponibles', $spotsLeft)
                ->description($spotsLeft > 0 ? "Puedes inscribir {$spotsLeft} jugadores más" : 'Plantilla completa')
                ->descriptionIcon($spotsLeft > 0 ? 'heroicon-m-plus-circle' : 'heroicon-m-check-circle')
                ->color($spotsLeft > 0 ? 'info' : 'success'),
        ];
    }
}
