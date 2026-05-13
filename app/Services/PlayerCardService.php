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

        // Tournament & category info (se calculan antes para incluirlos en QR)
        $season = $player->team?->seasons?->first();
        $tournament = $season?->tournament;
        $category = $season?->category ?? $tournament?->category;
        $tournamentName = $tournament?->name ?? 'Torneo León de Judá';
        $categoryName = $category?->name ?? '';

        // QR data: ficha completa del jugador en JSON Unicode-safe
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

        // QR: ECC M (mejor capacidad de datos sin sacrificar mucha tolerancia)
        // + scale 15 + quietzone 2 → módulos más grandes y margen suficiente
        // para que cámaras de celular escaneen bien al imprimir el carnet.
        $options = new QROptions([
            'outputInterface' => QRGdImagePNG::class,
            'eccLevel' => EccLevel::M,
            'scale' => 15,
            'outputBase64' => true,
            'quietzoneSize' => 2,
            'imageTransparent' => false,
            'bgColor' => [255, 255, 255],
        ]);

        $qrBase64 = (new QRCode($options))->render($qrData);

        // Foto del jugador comprimida (resize a 400px máx + JPEG 80)
        $photoBase64 = null;
        if ($player->photo) {
            $photoPath = storage_path('app/public/' . $player->photo);
            if (file_exists($photoPath)) {
                $photoBase64 = self::compressImage($photoPath, 400, 80);
            }
        }

        // Logo dinámico desde Configuración del sitio (no se comprime — suele
        // ser pequeño y la transparencia importa)
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

        // Tamaño tarjeta crédito (85.6mm x 53.98mm) en puntos
        $pdf->setPaper([0, 0, 242.65, 153.01], 'landscape');

        return $pdf;
    }

    /**
     * Comprime una imagen: resize si excede max width y la convierte a JPEG
     * con la calidad dada. Devuelve un data URL base64 listo para embed.
     */
    private static function compressImage(string $path, int $maxWidth = 400, int $quality = 80): ?string
    {
        if (!function_exists('imagecreatefromstring')) {
            // Fallback: GD no disponible → embebe original sin tocar
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
            imagedestroy($img);
            $img = $resized;
        }

        ob_start();
        imagejpeg($img, null, $quality);
        $jpgData = ob_get_clean();
        imagedestroy($img);

        if ($jpgData === false || $jpgData === '' || $jpgData === null) {
            return null;
        }

        return 'data:image/jpeg;base64,' . base64_encode($jpgData);
    }
}
