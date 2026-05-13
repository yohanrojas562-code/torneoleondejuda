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

        $season = $player->team?->seasons?->first();
        $tournament = $season?->tournament;
        $category = $season?->category ?? $tournament?->category;
        $tournamentName = $tournament?->name ?? 'Torneo León de Judá';
        $categoryName = $category?->name ?? '';

        // QR data: ficha completa del jugador en JSON
        $qrData = json_encode([
            'codigo' => $player->unique_code,
            'nombre' => trim(($player->first_name ?? '') . ' ' . ($player->last_name ?? '')),
            'documento' => trim(($player->document_type ?? '') . ' ' . ($player->document_number ?? '')),
            'nacimiento' => $player->birth_date?->format('Y-m-d'),
            'edad' => $player->age,
            'rh' => $player->blood_type,
            'equipo' => $player->team?->name,
            'dorsal' => $player->jersey_number,
            'nombre_dorsal' => $player->jersey_name,
            'posicion' => $player->position,
            'iglesia' => $player->church,
            'estado' => $player->approval_status,
            'capitan' => (bool) $player->is_captain,
            'torneo' => $tournamentName,
            'categoria' => $categoryName,
        ], JSON_UNESCAPED_UNICODE);

        // QR options minimas (sin opciones extras que rompian el render).
        // ECC M + scale 12 + quietzone 2: modulos grandes y margen para escaneo.
        $qrBase64 = null;
        try {
            $options = new QROptions([
                'outputInterface' => QRGdImagePNG::class,
                'eccLevel' => EccLevel::M,
                'scale' => 12,
                'outputBase64' => true,
                'quietzoneSize' => 2,
            ]);

            $qrOutput = (new QRCode($options))->render($qrData);

            // Validar que el output sea un data URI usable por DomPDF
            if (is_string($qrOutput) && str_starts_with($qrOutput, 'data:image/')) {
                $qrBase64 = $qrOutput;
            }
        } catch (\Throwable $e) {
            $qrBase64 = null;
        }

        // Foto del jugador: max 300px ancho + JPEG 70 (mucho mas liviano)
        $photoBase64 = null;
        if ($player->photo) {
            $photoPath = storage_path('app/public/' . $player->photo);
            if (file_exists($photoPath)) {
                $photoBase64 = self::compressImage($photoPath, 300, 70);
            }
        }

        // Logo desde Configuración del sitio (se mantiene tal cual — pequeño y con transparencia)
        $logoBase64 = null;
        $logoValue = \App\Models\SiteSetting::get('logo');
        if ($logoValue) {
            $logoPath = storage_path('app/public/' . $logoValue);
            if (file_exists($logoPath)) {
                $ext = strtolower(pathinfo($logoPath, PATHINFO_EXTENSION)) ?: 'png';
                $logoBase64 = 'data:image/' . $ext . ';base64,' . base64_encode(file_get_contents($logoPath));
            }
        }

        $pdf = Pdf::loadView('pdf.player-card', [
            'player' => $player,
            'qrBase64' => $qrBase64,
            'photoBase64' => $photoBase64,
            'logoBase64' => $logoBase64,
            'tournamentName' => $tournamentName,
            'categoryName' => $categoryName,
        ]);

        // Tarjeta crédito (85.6mm x 53.98mm)
        $pdf->setPaper([0, 0, 242.65, 153.01], 'landscape');

        return $pdf;
    }

    /**
     * Comprime imagen: resize si excede ancho dado, convierte a JPEG con la
     * calidad especificada. Devuelve data URL base64 o null.
     */
    private static function compressImage(string $path, int $maxWidth = 300, int $quality = 70): ?string
    {
        if (!function_exists('imagecreatefromstring')) {
            $ext = strtolower(pathinfo($path, PATHINFO_EXTENSION)) ?: 'png';
            return 'data:image/' . $ext . ';base64,' . base64_encode(file_get_contents($path));
        }

        $data = @file_get_contents($path);
        if ($data === false) {
            return null;
        }

        $img = @imagecreatefromstring($data);
        if (!$img) {
            return null;
        }

        $w = imagesx($img);
        $h = imagesy($img);

        if ($w > $maxWidth) {
            $newH = (int) round($h * $maxWidth / $w);
            $resized = imagecreatetruecolor($maxWidth, $newH);
            // Fondo blanco para imagenes con transparencia (PNG)
            $white = imagecolorallocate($resized, 255, 255, 255);
            imagefill($resized, 0, 0, $white);
            imagecopyresampled($resized, $img, 0, 0, 0, 0, $maxWidth, $newH, $w, $h);
            $img = $resized;
        }

        ob_start();
        imagejpeg($img, null, $quality);
        $jpgData = ob_get_clean();

        if (empty($jpgData)) {
            return null;
        }

        return 'data:image/jpeg;base64,' . base64_encode($jpgData);
    }
}
