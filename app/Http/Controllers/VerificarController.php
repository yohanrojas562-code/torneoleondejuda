<?php

namespace App\Http\Controllers;

use App\Models\Player;
use App\Models\SiteSetting;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

class VerificarController extends Controller
{
    public function __invoke(Request $request)
    {
        $query = trim((string) $request->input('q', ''));
        $players = collect();

        if ($query !== '') {
            $players = self::runSearch($query)->map(fn ($p) => self::formatPlayer($p));
        }

        return Inertia::render('Verificar', [
            'canLogin' => Route::has('login'),
            'canRegister' => Route::has('register'),
            'query' => $query,
            'players' => $players->toArray(),
            'settings' => SiteSetting::pluck('value', 'key')->toArray(),
        ]);
    }

    public function show(string $code)
    {
        $player = Player::with(['team:id,name,short_name,logo,primary_color'])
            ->where('unique_code', $code)
            ->first();

        return Inertia::render('Verificar', [
            'canLogin' => Route::has('login'),
            'canRegister' => Route::has('register'),
            'query' => $code,
            'players' => $player ? [self::formatPlayer($player)] : [],
            'settings' => SiteSetting::pluck('value', 'key')->toArray(),
        ]);
    }

    private static function runSearch(string $q)
    {
        $base = Player::query()->with(['team:id,name,short_name,logo,primary_color']);

        // Codigo unico: si trae el prefijo LDJ-, buscar exacto (case insensitive)
        if (stripos($q, 'LDJ-') === 0) {
            return $base->whereRaw('UPPER(unique_code) = ?', [strtoupper($q)])->limit(1)->get();
        }

        $lower = mb_strtolower($q);
        // Quitar puntos, comas, espacios, guiones para tolerar formato del documento
        // (ej. "1.098.765.432", "10 987 65432", "1098-765-432" -> todo a digitos)
        $digitsOnly = preg_replace('/\D+/', '', $q);

        return $base
            ->where(function ($qb) use ($lower, $digitsOnly) {
                if ($digitsOnly !== '') {
                    // 1) Documento exacto
                    $qb->orWhere('document_number', $digitsOnly);
                    // 2) Documento parcial (por si la persona tipea solo los
                    //    ultimos digitos o le falta uno)
                    $qb->orWhere('document_number', 'LIKE', '%' . $digitsOnly . '%');
                    // 3) Documento normalizado (sin puntos/espacios/guiones)
                    //    para el caso de DBs con formato guardado
                    $qb->orWhereRaw("REGEXP_REPLACE(document_number, '[^0-9]', '', 'g') = ?", [$digitsOnly]);
                }
                // Nombre/apellido por LIKE
                $qb->orWhereRaw('LOWER(first_name) LIKE ?', ['%' . $lower . '%'])
                    ->orWhereRaw('LOWER(last_name) LIKE ?', ['%' . $lower . '%']);
            })
            ->orderBy('first_name')
            ->orderBy('last_name')
            ->limit(30)
            ->get();
    }

    private static function formatPlayer(Player $p): array
    {
        return [
            'id' => $p->id,
            'unique_code' => $p->unique_code,
            'first_name' => $p->first_name,
            'last_name' => $p->last_name,
            'photo' => $p->photo,
            'jersey_number' => $p->jersey_number,
            'jersey_name' => $p->jersey_name,
            'position' => $p->position,
            'church' => $p->church,
            'document_type' => $p->document_type,
            'document_number' => $p->document_number,
            'birth_date' => $p->birth_date?->format('Y-m-d'),
            'age' => $p->age,
            'blood_type' => $p->blood_type,
            'approval_status' => $p->approval_status,
            'is_captain' => (bool) $p->is_captain,
            'team' => $p->team ? [
                'id' => $p->team->id,
                'name' => $p->team->name,
                'short_name' => $p->team->short_name,
                'logo' => $p->team->logo,
                'primary_color' => $p->team->primary_color,
            ] : null,
            'stats' => [
                'goals' => (int) ($p->total_goals ?? 0),
                'matches' => (int) ($p->total_matches ?? 0),
                'yellow_cards' => (int) ($p->yellow_cards ?? 0),
                'blue_cards' => (int) ($p->blue_cards ?? 0),
                'red_cards' => (int) ($p->red_cards ?? 0),
            ],
        ];
    }
}
