<?php

namespace App\Policies;

use App\Models\Team;
use App\Models\User;

class TeamPolicy
{
    public function viewAny(User $user): bool
    {
        return $user->hasAnyPermission(['view_any_team']);
    }

    public function view(User $user, Team $team): bool
    {
        if ($user->hasRole('admin')) return true;
        if ($user->hasRole('lider_equipo')) return $team->leader_id === $user->id;
        return $user->hasPermission('view_team');
    }

    public function create(User $user): bool
    {
        if ($user->hasRole('lider_equipo')) {
            // Solo puede crear 1 equipo
            return !Team::where('leader_id', $user->id)->exists();
        }
        return $user->hasAnyPermission(['create_team']);
    }

    public function update(User $user, Team $team): bool
    {
        if ($user->hasRole('admin')) return true;
        if ($user->hasRole('lider_equipo')) return $team->leader_id === $user->id;
        return false;
    }

    public function delete(User $user, Team $team): bool
    {
        return $user->hasRole('admin');
    }

    public function deleteAny(User $user): bool
    {
        return $user->hasRole('admin');
    }
}
