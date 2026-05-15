<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\Api\VerifyResultResource;
use App\Models\Player;
use Illuminate\Http\Request;

class VerifyController extends Controller
{
    /**
     * Lookup de jugador por unique_code (formato LDJ-XXXX) o documento.
     * Espeja la lógica del web VerificarController para mantener resultados
     * consistentes entre canales.
     */
    public function __invoke(Request $request)
    {
        $code = trim((string) $request->input('code', ''));

        if ($code === '') {
            return response()->json([
                'result' => null,
                'reason' => 'Código vacío',
            ]);
        }

        $player = $this->findPlayer($code);

        if (! $player) {
            return response()->json([
                'result' => null,
                'reason' => 'No se encontró un jugador con ese código o documento.',
            ]);
        }

        $status = $this->deriveStatus($player);
        $reason = $this->deriveReason($player, $status);

        return response()->json([
            'result' => new VerifyResultResource($player, $status, $reason),
        ]);
    }

    private function findPlayer(string $code): ?Player
    {
        $base = Player::with('team');

        // Unique code LDJ-XXXX (case insensitive, exacto)
        if (stripos($code, 'LDJ-') === 0) {
            return $base->whereRaw('UPPER(unique_code) = ?', [strtoupper($code)])
                ->first();
        }

        // Documento - solo dígitos
        $digits = preg_replace('/\D+/', '', $code);
        if ($digits !== '' && $digits !== null) {
            return $base
                ->where(function ($q) use ($digits) {
                    $q->where('document_number', $digits)
                        ->orWhereRaw(
                            "REGEXP_REPLACE(document_number, '[^0-9]', '', 'g') = ?",
                            [$digits]
                        );
                })
                ->first();
        }

        return null;
    }

    /**
     * Mapea el estado del Player en BD al enum que entiende la app:
     *  - approved      = jugador inscrito y activo
     *  - unregistered  = jugador existe pero no aprobado / sin equipo
     *  - suspended     = (futuro) sanción manual del comité disciplinario
     *  - expired       = (futuro) carnet vencido por fecha
     */
    private function deriveStatus(Player $player): string
    {
        if ($player->approval_status !== 'approved' || ! $player->is_active) {
            return 'unregistered';
        }

        if (! $player->team_id) {
            return 'unregistered';
        }

        return 'approved';
    }

    private function deriveReason(Player $player, string $status): ?string
    {
        return match ($status) {
            'unregistered' => 'El jugador no aparece inscrito o no está aprobado.',
            'suspended' => 'El jugador tiene una sanción vigente.',
            'expired' => 'El carnet del jugador está vencido.',
            default => null,
        };
    }
}
