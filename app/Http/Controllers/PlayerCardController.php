<?php

namespace App\Http\Controllers;

use App\Models\Player;
use App\Services\PlayerCardService;
use Illuminate\Http\Request;

class PlayerCardController extends Controller
{
    public function download(Player $player)
    {
        $user = auth()->user();

        // Only admin or the team leader can download
        if (!$user?->hasRole('admin')) {
            $teamLeader = $player->team?->leader_id === $user?->id;
            if (!$teamLeader) {
                abort(403);
            }
        }

        if ($player->approval_status !== 'approved') {
            abort(403, 'El jugador debe estar aprobado para generar el carnet.');
        }

        $pdf = PlayerCardService::generateCard($player);

        $filename = 'carnet-' . str($player->full_name)->slug() . '.pdf';

        return $pdf->download($filename);
    }
}
