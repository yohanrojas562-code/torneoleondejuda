<?php

namespace App\Policies;

use App\Models\Player;
use App\Models\Team;
use App\Models\User;

class PlayerPolicy
{
    /**
     * Cupo máximo de jugadores activos (aprobados + pendientes) por equipo.
     * Una vez alcanzado, el líder no puede agregar más y debe generar una
     * PQRS para solicitar el cambio de un jugador.
     */
    public const MAX_PLAYERS_PER_TEAM = 12;

    public function viewAny(User $user): bool
    {
        return $user->hasAnyPermission(['view_any_player']);
    }

    public function view(User $user, Player $player): bool
    {
        if ($user->hasRole('admin')) return true;
        if ($user->hasRole('lider_equipo')) {
            return $player->team && $player->team->leader_id === $user->id;
        }
        return $user->hasPermission('view_player');
    }

    public function create(User $user): bool
    {
        if ($user->hasRole('admin')) {
            return true;
        }

        if (!$user->hasAnyPermission(['create_player'])) {
            return false;
        }

        // Lideres de equipo: bloquear creacion cuando ya tienen el cupo lleno.
        if ($user->hasRole('lider_equipo')) {
            $team = Team::where('leader_id', $user->id)->first();
            if (!$team) {
                return false;
            }
            $activeCount = $team->players()
                ->whereIn('approval_status', ['approved', 'pending'])
                ->count();
            return $activeCount < self::MAX_PLAYERS_PER_TEAM;
        }

        return true;
    }

    public function update(User $user, Player $player): bool
    {
        if ($user->hasRole('admin')) return true;
        if ($user->hasRole('lider_equipo')) {
            return $player->team && $player->team->leader_id === $user->id;
        }
        return false;
    }

    public function delete(User $user, Player $player): bool
    {
        // Solo admin puede eliminar. Lideres NO pueden eliminar jugadores
        // (deben generar PQRS para solicitar cambios).
        return $user->hasRole('admin');
    }

    public function deleteAny(User $user): bool
    {
        return $user->hasRole('admin');
    }
}
