<?php

namespace App\Http\Resources\Api;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * Patrocinador / Aliado / Apoyo. El campo `type` viene de la BD como
 * patrocinio|alianza|apoyo y se mapea 1:1 al SponsorTier de la app móvil.
 */
class SponsorResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $social = $this->social_links;
        if (is_string($social)) {
            $decoded = json_decode($social, true);
            $social = is_array($decoded) ? $decoded : null;
        }

        return [
            'id' => $this->id,
            'name' => $this->name,
            'description' => $this->description,
            'logo_url' => $this->logo
                ? asset('storage/'.$this->logo)
                : null,
            'website' => $this->website,
            'type' => $this->type,
            'social_links' => $social,
            'order' => $this->order,
        ];
    }
}
