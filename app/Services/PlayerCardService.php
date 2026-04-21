<?php

namespace App\Services;

use App\Models\Player;
use Barryvdh\DomPDF\Facade\Pdf;
use chillerlan\QRCode\QRCode;
use chillerlan\QRCode\QROptions;
use chillerlan\QRCode\Common\EccLevel;
use chillerlan\QRCode\Output\QRGdImagePNG;

class PlayerCardService
{
    public static function generateCard(Player $player): \Barryvdh\DomPDF\PDF
    {
        $player->load(['team.seasons.tournament', 'team.seasons.category']);

        // Build QR data with unique_code for identification
        $qrData = json_encode([
            'code' => $player->unique_code,
            'id' => $player->id,
            'name' => $player->full_name,
            'doc_type' => $player->document_type,
            'doc' => $player->document_number,
            'rh' => $player->blood_type,
            'team' => $player->team?->name,
            'team_id' => $player->team_id,
            'jersey' => $player->jersey_number,
        ]);

        // Generate QR as PNG base64 using chillerlan/php-qrcode v6 (GD, no imagick needed)
        $options = new QROptions([
            'outputInterface' => QRGdImagePNG::class,
            'eccLevel' => EccLevel::H,
            'scale' => 10,
            'outputBase64' => true,
            'quietzoneSize' => 1,
        ]);

        $qrBase64 = (new QRCode($options))->render($qrData);

        // Player photo
        $photoBase64 = null;
        if ($player->photo) {
            $photoPath = storage_path('app/public/' . $player->photo);
            if (file_exists($photoPath)) {
                $ext = pathinfo($photoPath, PATHINFO_EXTENSION);
                $photoBase64 = 'data:image/' . $ext . ';base64,' . base64_encode(file_get_contents($photoPath));
            }
        }

        // Logo dinámico desde Configuración del sitio
        $logoBase64 = null;
        $logoValue = \App\Models\SiteSetting::get('logo');
        if ($logoValue) {
            $logoPath = storage_path('app/public/' . $logoValue);
            if (file_exists($logoPath)) {
                $ext = strtolower(pathinfo($logoPath, PATHINFO_EXTENSION)) ?: 'png';
                $logoBase64 = 'data:image/' . $ext . ';base64,' . base64_encode(file_get_contents($logoPath));
            }
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
