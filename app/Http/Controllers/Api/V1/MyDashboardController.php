<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Api\V1\Concerns\ResolvesActiveSeason;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\StoreMyPlayerRequest;
use App\Http\Requests\Api\UpdateMyPlayerRequest;
use App\Http\Resources\Api\MatchResource;
use App\Http\Resources\Api\MyPlayerDetailResource;
use App\Http\Resources\Api\PlayerResource;
use App\Http\Resources\Api\TeamResource;
use App\Models\GameMatch;
use App\Models\Player;
use App\Models\Team;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

/**
 * Endpoints "/my/*" — devuelven los datos del usuario autenticado en función
 * de sus roles. Espeja la lógica de visibilidad de Filament:
 *
 *  - admin: ve todo (stats globales del torneo)
 *  - lider_equipo: solo sus equipos (Team.leader_id = user.id)
 *  - capitan: solo su equipo (Team.captain_id = user.id)
 *  - arbitro: partidos que le toca arbitrar (futuro — requiere campo
 *    referee_id en GameMatch)
 *
 * Todos los endpoints requieren auth:sanctum.
 */
class MyDashboardController extends Controller
{
    use ResolvesActiveSeason;

    /**
     * GET /api/v1/my/dashboard
     *
     * Snapshot del dashboard según rol del usuario. La app móvil decide qué
     * widgets mostrar según `view` (admin|lider|capitan|arbitro|generic).
     */
    public function dashboard(Request $request)
    {
        $user = $request->user();
        $season = $this->activeSeason();

        if ($user->hasRole('admin')) {
            return $this->adminDashboard($season);
        }

        if ($user->hasRole('lider_equipo')) {
            return $this->liderDashboard($user, $season);
        }

        if ($user->hasRole('capitan')) {
            return $this->capitanDashboard($user, $season);
        }

        if ($user->hasRole('arbitro')) {
            return $this->arbitroDashboard($user, $season);
        }

        return response()->json([
            'view' => 'generic',
            'active_season' => $this->seasonPayload($season),
            'message' => 'Tu cuenta no tiene un dashboard asignado.',
        ]);
    }

    /**
     * GET /api/v1/my/teams — solo aplica a lider_equipo y capitan.
     */
    public function teams(Request $request)
    {
        $user = $request->user();
        $query = Team::query();

        if ($user->hasRole('lider_equipo') && ! $user->hasRole('admin')) {
            $query->where('leader_id', $user->id);
        } elseif ($user->hasRole('capitan') && ! $user->hasRole('admin')) {
            $query->where('captain_id', $user->id);
        } elseif (! $user->hasRole('admin')) {
            return response()->json(['teams' => []]);
        }

        $teams = $query->orderBy('name')->get();

        return response()->json([
            'teams' => TeamResource::collection($teams),
        ]);
    }

    /**
     * GET /api/v1/my/matches — partidos de los equipos del usuario.
     */
    public function matches(Request $request)
    {
        $user = $request->user();
        $season = $this->activeSeason();
        $seasonId = $season?->id;

        $teamIds = $this->resolveTeamIds($user);

        if (empty($teamIds) && ! $user->hasRole('admin')) {
            return response()->json([
                'upcoming' => [],
                'finished' => [],
                'postponed' => [],
            ]);
        }

        $relations = ['homeTeam', 'awayTeam', 'venue', 'matchDay'];

        $baseQuery = GameMatch::query()->with($relations);
        if ($seasonId) {
            $baseQuery->where('season_id', $seasonId);
        }
        if (! $user->hasRole('admin')) {
            $baseQuery->where(function ($q) use ($teamIds) {
                $q->whereIn('home_team_id', $teamIds)
                    ->orWhereIn('away_team_id', $teamIds);
            });
        }

        $upcoming = (clone $baseQuery)
            ->whereIn('status', [
                'scheduled', 'warmup', 'first_half', 'halftime',
                'second_half', 'extra_time', 'penalties',
            ])
            ->orderBy('scheduled_at')
            ->get();

        $finished = (clone $baseQuery)
            ->with(array_merge($relations, [
                'events' => fn ($q) => $q
                    ->whereIn('type', [
                        'goal', 'own_goal', 'penalty_goal',
                        'yellow_card', 'red_card', 'second_yellow', 'blue_card',
                    ])
                    ->orderBy('minute'),
                'events.player',
            ]))
            ->where('status', 'finished')
            ->orderByDesc('scheduled_at')
            ->get();

        $postponed = (clone $baseQuery)
            ->whereIn('status', ['suspended', 'cancelled', 'postponed'])
            ->orderByDesc('scheduled_at')
            ->get();

        return response()->json([
            'upcoming' => MatchResource::collection($upcoming),
            'finished' => MatchResource::collection($finished),
            'postponed' => MatchResource::collection($postponed),
        ]);
    }

    /**
     * GET /api/v1/my/players — jugadores de los equipos del usuario.
     */
    public function players(Request $request)
    {
        $user = $request->user();
        $teamIds = $this->resolveTeamIds($user);

        if (empty($teamIds) && ! $user->hasRole('admin')) {
            return response()->json(['players' => []]);
        }

        $query = Player::with('team');
        if (! $user->hasRole('admin')) {
            $query->whereIn('team_id', $teamIds);
        }

        $players = $query
            ->orderBy('approval_status')
            ->orderBy('last_name')
            ->orderBy('first_name')
            ->get();

        return response()->json([
            'players' => PlayerResource::collection($players),
            'counts' => [
                'total' => $players->count(),
                'approved' => $players->where('approval_status', 'approved')->count(),
                'pending' => $players->where('approval_status', 'pending')->count(),
                'rejected' => $players->where('approval_status', 'rejected')->count(),
            ],
        ]);
    }

    /**
     * GET /api/v1/my/players/{player} — Detalle completo de un jugador del
     * usuario autenticado. Devuelve 404 si el jugador no pertenece a ningún
     * equipo del líder.
     */
    public function playerShow(Request $request, Player $player)
    {
        $this->authorizePlayerAccess($request->user(), $player);
        $player->load('team');
        return response()->json([
            'player' => new MyPlayerDetailResource($player),
        ]);
    }

    /**
     * POST /api/v1/my/players — Crea un jugador en uno de los equipos del
     * líder. Si el líder tiene un solo equipo y no envía team_id, se asigna
     * automáticamente.
     */
    public function playerCreate(StoreMyPlayerRequest $request)
    {
        $data = $request->validated();
        $user = $request->user();

        // Resolver team_id si el líder no lo envía
        if (empty($data['team_id']) && ! $user->hasRole('admin')) {
            $teams = Team::where('leader_id', $user->id)->pluck('id');
            if ($teams->count() === 0) {
                throw ValidationException::withMessages([
                    'team_id' => ['No tienes equipos asignados.'],
                ]);
            }
            if ($teams->count() > 1) {
                throw ValidationException::withMessages([
                    'team_id' => ['Indica el equipo al que pertenece el jugador.'],
                ]);
            }
            $data['team_id'] = $teams->first();
        }

        // Límite de 12 jugadores aprobados por equipo: si ya hay 12, NO se
        // puede crear directamente. El líder debe abrir una PQRS para que el
        // comité lo apruebe manualmente.
        if (! $user->hasRole('admin')) {
            $approvedCount = Player::where('team_id', $data['team_id'])
                ->where('approval_status', 'approved')
                ->count();
            if ($approvedCount >= 12) {
                throw ValidationException::withMessages([
                    'team_id' => [
                        'Tu equipo ya tiene 12 jugadores aprobados. Para inscribir un jugador adicional debes abrir una PQRS al comité.',
                    ],
                ]);
            }
        }
        // El special_request del web sigue disponible para que el admin lo
        // marque al crear el 13+, pero ya no es la vía para el líder.

        // Defaults forzados por seguridad — el cliente no decide estos
        $data['approval_status'] = 'pending';
        $data['is_active'] = true;
        // Si goalkeeper_type llega pero position no es portero, lo limpiamos
        if (($data['position'] ?? null) !== 'portero') {
            $data['goalkeeper_type'] = null;
        }

        $player = Player::create($data);
        $player->load('team');

        return response()->json([
            'player' => new MyPlayerDetailResource($player),
        ], 201);
    }

    /**
     * PATCH /api/v1/my/players/{player} — Edita los campos permitidos.
     * Las reglas de lock-when-approved se aplican en UpdateMyPlayerRequest.
     */
    public function playerUpdate(UpdateMyPlayerRequest $request, Player $player)
    {
        $this->authorizePlayerAccess($request->user(), $player);

        $data = $request->validated();
        if (($data['position'] ?? $player->position) !== 'portero') {
            $data['goalkeeper_type'] = null;
        }

        $player->fill($data)->save();
        $player->load('team');

        return response()->json([
            'player' => new MyPlayerDetailResource($player),
        ]);
    }

    /**
     * POST /api/v1/my/players/{player}/files — Sube uno de los 5 archivos
     * del jugador. El cliente envía:
     *  - `kind`: photo | document | eps_certificate | no_eps_consent |
     *    parental_consent
     *  - `file`: el binario (multipart).
     *
     * Conserva la misma estructura de directorios que el Filament para que
     * los archivos se vean igual en el panel admin web y en la app móvil.
     */
    public function playerUploadFile(Request $request, Player $player)
    {
        $this->authorizePlayerAccess($request->user(), $player);

        $data = $request->validate([
            'kind' => ['required', 'in:photo,document,eps_certificate,no_eps_consent,parental_consent'],
            'file' => ['required', 'file', 'max:5120'],
        ]);

        $kindMap = [
            'photo' => [
                'column' => 'photo',
                'directory' => 'players/photos',
                'mimes' => ['image/jpeg', 'image/png', 'image/webp'],
                'max_kb' => 3072,
            ],
            'document' => [
                'column' => 'document_file',
                'directory' => 'players/documents',
                'mimes' => ['application/pdf', 'image/jpeg', 'image/png'],
                'max_kb' => 5120,
            ],
            'eps_certificate' => [
                'column' => 'eps_certificate',
                'directory' => 'players/eps',
                'mimes' => ['application/pdf', 'image/jpeg', 'image/png'],
                'max_kb' => 5120,
            ],
            'no_eps_consent' => [
                'column' => 'no_eps_consent',
                'directory' => 'players/consents',
                'mimes' => ['application/pdf', 'image/jpeg', 'image/png'],
                'max_kb' => 5120,
            ],
            'parental_consent' => [
                'column' => 'parental_consent',
                'directory' => 'players/parental',
                'mimes' => ['application/pdf', 'image/jpeg', 'image/png'],
                'max_kb' => 5120,
            ],
        ];

        $cfg = $kindMap[$data['kind']];
        $file = $request->file('file');

        if (! in_array($file->getMimeType(), $cfg['mimes'], true)) {
            throw ValidationException::withMessages([
                'file' => ['Tipo de archivo no permitido para '.$data['kind'].'.'],
            ]);
        }
        if (($file->getSize() / 1024) > $cfg['max_kb']) {
            throw ValidationException::withMessages([
                'file' => ['El archivo excede el tamaño máximo permitido.'],
            ]);
        }

        // Borrar el archivo anterior si existía, para no llenar storage
        if ($player->{$cfg['column']}) {
            Storage::disk('public')->delete($player->{$cfg['column']});
        }

        $ext = $file->getClientOriginalExtension() ?: 'bin';
        $filename = strtoupper(Str::ulid()).'.'.$ext;
        $path = $file->storeAs($cfg['directory'], $filename, 'public');

        $player->{$cfg['column']} = $path;
        $player->save();
        $player->load('team');

        return response()->json([
            'player' => new MyPlayerDetailResource($player),
        ]);
    }

    /**
     * Garantiza que el usuario autenticado tenga acceso al jugador. Admin ve
     * todos; líder solo los de sus equipos; capitán los de su equipo.
     */
    private function authorizePlayerAccess($user, Player $player): void
    {
        if ($user->hasRole('admin')) return;

        $teamIds = $this->resolveTeamIds($user);
        if (! in_array($player->team_id, $teamIds, true)) {
            abort(404);
        }
    }

    // ─── Dashboards por rol ───────────────────────────────────────────

    private function adminDashboard($season)
    {
        $seasonId = $season?->id;

        $counts = [
            'teams' => Team::where('approval_status', 'approved')->count(),
            'players' => Player::where('approval_status', 'approved')->count(),
            'players_pending' => Player::where('approval_status', 'pending')->count(),
            'matches_played' => $seasonId
                ? GameMatch::where('season_id', $seasonId)
                    ->where('status', 'finished')
                    ->count()
                : 0,
            'matches_upcoming' => $seasonId
                ? GameMatch::where('season_id', $seasonId)
                    ->whereIn('status', ['scheduled', 'warmup'])
                    ->count()
                : 0,
        ];

        return response()->json([
            'view' => 'admin',
            'active_season' => $this->seasonPayload($season),
            'counts' => $counts,
            'web_admin_url' => url('/admin'),
        ]);
    }

    private function liderDashboard($user, $season)
    {
        $teamIds = Team::where('leader_id', $user->id)->pluck('id')->all();
        $teams = Team::whereIn('id', $teamIds)->get();

        $seasonId = $season?->id;

        $upcomingMatches = empty($teamIds) || ! $seasonId
            ? collect()
            : GameMatch::with(['homeTeam', 'awayTeam', 'venue', 'matchDay'])
                ->where('season_id', $seasonId)
                ->whereIn('status', ['scheduled', 'warmup'])
                ->where(function ($q) use ($teamIds) {
                    $q->whereIn('home_team_id', $teamIds)
                        ->orWhereIn('away_team_id', $teamIds);
                })
                ->orderBy('scheduled_at')
                ->limit(5)
                ->get();

        $playerCounts = Player::whereIn('team_id', $teamIds)
            ->selectRaw('approval_status, count(*) as total')
            ->groupBy('approval_status')
            ->pluck('total', 'approval_status');

        return response()->json([
            'view' => 'lider',
            'active_season' => $this->seasonPayload($season),
            'teams' => TeamResource::collection($teams),
            'upcoming_matches' => MatchResource::collection($upcomingMatches),
            'player_counts' => [
                'approved' => (int) ($playerCounts['approved'] ?? 0),
                'pending' => (int) ($playerCounts['pending'] ?? 0),
                'rejected' => (int) ($playerCounts['rejected'] ?? 0),
            ],
        ]);
    }

    private function capitanDashboard($user, $season)
    {
        $teamIds = Team::where('captain_id', $user->id)->pluck('id')->all();
        $teams = Team::whereIn('id', $teamIds)->get();

        $seasonId = $season?->id;

        $upcomingMatches = empty($teamIds) || ! $seasonId
            ? collect()
            : GameMatch::with(['homeTeam', 'awayTeam', 'venue', 'matchDay'])
                ->where('season_id', $seasonId)
                ->whereIn('status', ['scheduled', 'warmup'])
                ->where(function ($q) use ($teamIds) {
                    $q->whereIn('home_team_id', $teamIds)
                        ->orWhereIn('away_team_id', $teamIds);
                })
                ->orderBy('scheduled_at')
                ->limit(5)
                ->get();

        return response()->json([
            'view' => 'capitan',
            'active_season' => $this->seasonPayload($season),
            'teams' => TeamResource::collection($teams),
            'upcoming_matches' => MatchResource::collection($upcomingMatches),
        ]);
    }

    private function arbitroDashboard($user, $season)
    {
        return response()->json([
            'view' => 'arbitro',
            'active_season' => $this->seasonPayload($season),
            'message' => 'Pronto: partidos asignados para arbitrar.',
        ]);
    }

    private function seasonPayload($season): ?array
    {
        if (! $season) {
            return null;
        }
        return [
            'id' => $season->id,
            'name' => $season->name,
            'status' => $season->status,
            'tournament' => $season->tournament ? [
                'id' => $season->tournament->id,
                'name' => $season->tournament->name,
            ] : null,
        ];
    }

    /**
     * Devuelve los IDs de equipos del usuario según su rol. Admin ve todos
     * (devuelve [] que el caller interpreta como "sin filtro").
     */
    private function resolveTeamIds($user): array
    {
        if ($user->hasRole('admin')) {
            return [];
        }
        if ($user->hasRole('lider_equipo')) {
            return Team::where('leader_id', $user->id)->pluck('id')->all();
        }
        if ($user->hasRole('capitan')) {
            return Team::where('captain_id', $user->id)->pluck('id')->all();
        }
        return [];
    }
}
