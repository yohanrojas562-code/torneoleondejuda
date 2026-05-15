<?php

namespace App\Http\Resources\Api;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * Miembro del organigrama (directiva del torneo). El campo `roles` es un
 * array JSON en BD; lo normalizo siempre como array al exponer.
 */
class TeamMemberResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $roles = $this->roles;
        if (is_string($roles)) {
            $decoded = json_decode($roles, true);
            $roles = is_array($decoded) ? $decoded : [];
        }
        if (! is_array($roles)) {
            $roles = [];
        }

        return [
            'id' => $this->id,
            'name' => $this->name,
            'description' => $this->description,
            'photo_url' => $this->photo
                ? asset('storage/'.$this->photo)
                : null,
            'roles' => array_values($roles),
            'tier' => $this->tier ?? 3,
            'order' => $this->order,
        ];
    }
}
