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

        // QR encode una URL al validador publico. Al escanear con cualquier
        // camara de celular abre directo la ficha del jugador en el navegador.
        // URL corta = QR con menos modulos = mucho mas facil de escanear.
        $qrData = url('/verificar/' . $player->unique_code);

        // QR options: ECC M + scale 12 + quietzone 2.
        // chillerlan v6 a veces devuelve solo el base64 sin el prefijo data URI,
        // asi que normalizamos al final para garantizar que DomPDF lo decodifique.
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

            if (is_string($qrOutput) && $qrOutput !== '') {
                // Si ya viene con prefijo data URI lo dejamos. Si viene solo el
                // base64 raw (caso comun en v6), agregamos el prefijo manualmente.
                $qrBase64 = str_starts_with($qrOutput, 'data:')
                    ? $qrOutput
                    : 'data:image/png;base64,' . $qrOutput;
            }
        } catch (\Throwable $e) {
            $qrBase64 = null;
        }

        // Foto del jugador: max 250px ancho + JPEG 60 (PDF aun mas liviano)
        $photoBase64 = null;
        if ($player->photo) {
            $photoPath = storage_path('app/public/' . $player->photo);
            if (file_exists($photoPath)) {
                $photoBase64 = self::compressImage($photoPath, 250, 60);
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

        // Pre-calculamos en PHP toda la logica que antes vivia en @php del
        // blade. Mantener el blade SIN @php evita whitespace dentro del .card
        // que generaria un nodo de texto con line-height y rompia la
        // paginacion del PDF.
        $statusLabels = [
            'approved' => 'Aprobado',
            'pending' => 'Pendiente',
            'rejected' => 'Rechazado',
        ];
        $positionLabels = [
            'portero' => 'Portero',
            'defensa' => 'Defensa',
            'mediocampista' => 'Mediocampista',
            'delantero' => 'Delantero',
        ];
        $statusKey = $player->approval_status ?? 'pending';
        $statusLabel = $statusLabels[$statusKey] ?? ucfirst($statusKey);
        $positionLabel = $positionLabels[$player->position] ?? ucfirst($player->position ?? '—');
        $fullName = trim(($player->first_name ?? '') . ' ' . ($player->last_name ?? ''));
        $nameLen = mb_strlen($fullName);
        $nameClass = $nameLen <= 16 ? 'player-name-short'
            : ($nameLen <= 22 ? 'player-name-mid'
            : ($nameLen <= 30 ? 'player-name-long' : 'player-name-xlong'));

        $pdf = Pdf::loadView('pdf.player-card', [
            'player' => $player,
            'qrBase64' => $qrBase64,
            'photoBase64' => $photoBase64,
            'logoBase64' => $logoBase64,
            'tournamentName' => $tournamentName,
            'categoryName' => $categoryName,
            'statusKey' => $statusKey,
            'statusLabel' => $statusLabel,
            'positionLabel' => $positionLabel,
            'fullName' => $fullName,
            'nameClass' => $nameClass,
        ]);

        // Tarjeta crédito (85.6mm x 53.98mm). El bbox ya define ancho > alto
        // (landscape natural). Pasar 'landscape' como segundo argumento hacia
        // que DomPDF rotara el bbox en algunas versiones y produjera A4 vertical.
        $pdf->setPaper([0, 0, 242.65, 153.01]);

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
