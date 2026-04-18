<?php

namespace App\Services;

use App\Models\Player;
use Barryvdh\DomPDF\Facade\Pdf;
use SimpleSoftwareIO\QrCode\Facades\QrCode;

class PlayerCardService
{
    public static function generateCard(Player $player): \Barryvdh\DomPDF\PDF
    {
        $player->load(['team.seasons.tournament', 'team.seasons.category']);

        // Build QR data
        $qrData = json_encode([
            'id' => $player->id,
            'name' => $player->full_name,
            'doc_type' => $player->document_type,
            'doc' => $player->document_number,
            'rh' => $player->blood_type,
            'team' => $player->team?->name,
            'jersey' => $player->jersey_number,
        ]);

        // Generate QR as SVG then convert to base64 PNG
        $qrSvg = QrCode::format('svg')
            ->size(200)
            ->errorCorrection('H')
            ->generate($qrData);

        $qrBase64 = 'data:image/svg+xml;base64,' . base64_encode($qrSvg);

        // Player photo
        $photoBase64 = null;
        if ($player->photo) {
            $photoPath = storage_path('app/public/' . $player->photo);
            if (file_exists($photoPath)) {
                $ext = pathinfo($photoPath, PATHINFO_EXTENSION);
                $photoBase64 = 'data:image/' . $ext . ';base64,' . base64_encode(file_get_contents($photoPath));
            }
        }

        // Logo
        $logoBase64 = null;
        $logoPath = storage_path('app/public/site/01KPGXECZX5VF8YQAA8AD210WM.png');
        if (file_exists($logoPath)) {
            $logoBase64 = 'data:image/png;base64,' . base64_encode(file_get_contents($logoPath));
        }

        // Tournament & category info
        $season = $player->team?->seasons?->first();
        $tournament = $season?->tournament;
        $category = $season?->category ?? $tournament?->category;
        $tournamentName = $tournament?->name ?? 'Torneo León de Judá';
        $categoryName = $category?->name ?? '';

        $pdf = Pdf::loadView('pdf.player-card', [
            'player' => $player,
            'qrBase64' => $qrBase64,
            'photoBase64' => $photoBase64,
            'logoBase64' => $logoBase64,
            'tournamentName' => $tournamentName,
            'categoryName' => $categoryName,
        ]);

        // Card size: credit card format (85.6mm x 53.98mm)
        $pdf->setPaper([0, 0, 242.65, 153.01], 'landscape');

        return $pdf;
    }
}
