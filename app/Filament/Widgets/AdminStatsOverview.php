<?php

namespace App\Filament\Widgets;

use App\Models\Team;
use App\Models\Player;
use App\Models\GameMatch;
use App\Models\Tournament;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class AdminStatsOverview extends BaseWidget
{
    protected static ?int $sort = 1;

    public static function canView(): bool
    {
        return auth()->user()?->hasRole('admin');
    }

    protected function getStats(): array
    {
        $totalTeams = Team::count();
        $approvedTeams = Team::where('approval_status', 'approved')->count();
        $pendingTeams = Team::where('approval_status', 'pending')->count();

        $totalPlayers = Player::count();
        $approvedPlayers = Player::where('approval_status', 'approved')->count();
        $pendingPlayers = Player::where('approval_status', 'pending')->count();

        $totalMatches = GameMatch::count();
        $playedMatches = GameMatch::where('status', 'played')->count();

        $totalTournaments = Tournament::count();

        return [
            Stat::make('Equipos Registrados', $totalTeams)
                ->description("{$approvedTeams} aprobados · {$pendingTeams} pendientes")
                ->descriptionIcon('heroicon-m-shield-check')
                ->chart([$totalTeams > 0 ? $approvedTeams : 0, $pendingTeams, $totalTeams])
                ->color('warning'),

            Stat::make('Jugadores Inscritos', $totalPlayers)
                ->description("{$approvedPlayers} aprobados · {$pendingPlayers} pendientes")
                ->descriptionIcon('heroicon-m-user-group')
                ->chart([$totalPlayers > 0 ? $approvedPlayers : 0, $pendingPlayers, $totalPlayers])
                ->color('success'),

            Stat::make('Partidos', $totalMatches)
                ->description("{$playedMatches} jugados de {$totalMatches}")
                ->descriptionIcon('heroicon-m-trophy')
                ->chart([$playedMatches, $totalMatches - $playedMatches])
                ->color('primary'),

            Stat::make('Torneos Activos', $totalTournaments)
                ->description('Torneos creados en el sistema')
                ->descriptionIcon('heroicon-m-fire')
                ->color('danger'),
        ];
    }
}
