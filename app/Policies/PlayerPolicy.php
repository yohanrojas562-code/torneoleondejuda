<?php

namespace App\Policies;

use App\Models\Player;
use App\Models\User;

class PlayerPolicy
{
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
        return $user->hasAnyPermission(['create_player']);
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
        if ($user->hasRole('admin')) return true;
        if ($user->hasRole('lider_equipo')) {
            // Solo puede eliminar si su equipo y jugador pendiente
            return $player->team
                && $player->team->leader_id === $user->id
                && $player->approval_status === 'pending';
        }
        return false;
    }

    public function deleteAny(User $user): bool
    {
        return $user->hasRole('admin');
    }
}
