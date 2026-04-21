<div class="space-y-6 py-2">

    {{-- Encabezado del partido --}}
    <div class="bg-gray-50 dark:bg-gray-800 rounded-xl p-4">
        <div class="flex items-center justify-between gap-4">
            {{-- Equipo local --}}
            <div class="flex-1 text-center">
                @if($match->homeTeam->logo)
                    <img src="{{ Storage::url($match->homeTeam->logo) }}" alt="{{ $match->homeTeam->name }}"
                         class="w-16 h-16 object-contain mx-auto mb-2 rounded-full">
                @endif
                <p class="font-bold text-gray-900 dark:text-white text-sm">{{ $match->homeTeam->name }}</p>
                <p class="text-xs text-gray-500">Local</p>
            </div>

            {{-- Marcador / vs --}}
            <div class="text-center flex-shrink-0">
                @if($match->status === 'finished')
                    <div class="text-3xl font-extrabold text-gray-900 dark:text-white">
                        {{ $match->home_score }} - {{ $match->away_score }}
                    </div>
                    @if($match->home_penalty_score !== null && $match->away_penalty_score !== null)
                        <p class="text-xs text-gray-500 mt-1">
                            Penales: {{ $match->home_penalty_score }} - {{ $match->away_penalty_score }}
                        </p>
                    @endif
                    <span class="inline-block mt-1 px-2 py-0.5 rounded-full text-xs font-semibold bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200">
                        Finalizado
                    </span>
                @elseif(in_array($match->status, ['first_half','halftime','second_half','extra_time','penalties','warmup']))
                    <div class="text-3xl font-extrabold text-yellow-500">
                        {{ $match->home_score }} - {{ $match->away_score }}
                    </div>
                    <span class="inline-block mt-1 px-2 py-0.5 rounded-full text-xs font-semibold bg-yellow-100 text-yellow-800 animate-pulse">
                        En juego
                    </span>
                @elseif(in_array($match->status, ['postponed','suspended','cancelled']))
                    <div class="text-lg font-bold text-red-500">vs</div>
                    <span class="inline-block mt-1 px-2 py-0.5 rounded-full text-xs font-semibold bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200">
                        {{ match($match->status) {
                            'postponed'  => 'Aplazado',
                            'suspended'  => 'Suspendido',
                            'cancelled'  => 'Cancelado',
                            default      => $match->status,
                        } }}
                    </span>
                @else
                    <div class="text-2xl font-bold text-gray-400">vs</div>
                    <span class="inline-block mt-1 px-2 py-0.5 rounded-full text-xs font-semibold bg-gray-100 text-gray-600 dark:bg-gray-700 dark:text-gray-300">
                        Programado
                    </span>
                @endif
            </div>

            {{-- Equipo visitante --}}
            <div class="flex-1 text-center">
                @if($match->awayTeam->logo)
                    <img src="{{ Storage::url($match->awayTeam->logo) }}" alt="{{ $match->awayTeam->name }}"
                         class="w-16 h-16 object-contain mx-auto mb-2 rounded-full">
                @endif
                <p class="font-bold text-gray-900 dark:text-white text-sm">{{ $match->awayTeam->name }}</p>
                <p class="text-xs text-gray-500">Visitante</p>
            </div>
        </div>
    </div>

    {{-- Info general --}}
    <div class="grid grid-cols-2 gap-3 text-sm">
        @if($match->season)
        <div class="bg-gray-50 dark:bg-gray-800 rounded-lg p-3">
            <p class="text-xs text-gray-500 uppercase tracking-wide mb-1">Temporada</p>
            <p class="font-semibold text-gray-900 dark:text-white">{{ $match->season->name }}</p>
        </div>
        @endif

        @if($match->matchDay)
        <div class="bg-gray-50 dark:bg-gray-800 rounded-lg p-3">
            <p class="text-xs text-gray-500 uppercase tracking-wide mb-1">Jornada</p>
            <p class="font-semibold text-gray-900 dark:text-white">{{ $match->matchDay->name }}</p>
        </div>
        @endif

        <div class="bg-gray-50 dark:bg-gray-800 rounded-lg p-3">
            <p class="text-xs text-gray-500 uppercase tracking-wide mb-1">Fecha y Hora</p>
            <p class="font-semibold text-gray-900 dark:text-white">
                {{ \Carbon\Carbon::parse($match->scheduled_at)->timezone('UTC')->format('d/m/Y H:i') }}
            </p>
        </div>

        @if($match->venue)
        <div class="bg-gray-50 dark:bg-gray-800 rounded-lg p-3">
            <p class="text-xs text-gray-500 uppercase tracking-wide mb-1">Escenario</p>
            <p class="font-semibold text-gray-900 dark:text-white">{{ $match->venue->name }}</p>
        </div>
        @endif
    </div>

    {{-- Tarjetas --}}
    @php
        $showCards = ($match->home_yellow_cards + $match->home_blue_cards + $match->home_red_cards +
                      $match->away_yellow_cards + $match->away_blue_cards + $match->away_red_cards) > 0;
    @endphp
    @if($showCards)
    <div>
        <h3 class="text-xs font-bold text-gray-500 uppercase tracking-wider mb-2">Tarjetas</h3>
        <div class="overflow-hidden rounded-lg border border-gray-200 dark:border-gray-700">
            <table class="w-full text-sm">
                <thead class="bg-gray-50 dark:bg-gray-800">
                    <tr>
                        <th class="px-3 py-2 text-left text-xs text-gray-500">Equipo</th>
                        <th class="px-3 py-2 text-center text-xs text-yellow-600">🟡 Amarillas</th>
                        <th class="px-3 py-2 text-center text-xs text-blue-600">🔵 Azules</th>
                        <th class="px-3 py-2 text-center text-xs text-red-600">🔴 Rojas</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-200 dark:divide-gray-700">
                    <tr>
                        <td class="px-3 py-2 font-medium text-gray-900 dark:text-white">{{ $match->homeTeam->name }}</td>
                        <td class="px-3 py-2 text-center">{{ $match->home_yellow_cards ?? 0 }}</td>
                        <td class="px-3 py-2 text-center">{{ $match->home_blue_cards ?? 0 }}</td>
                        <td class="px-3 py-2 text-center">{{ $match->home_red_cards ?? 0 }}</td>
                    </tr>
                    <tr>
                        <td class="px-3 py-2 font-medium text-gray-900 dark:text-white">{{ $match->awayTeam->name }}</td>
                        <td class="px-3 py-2 text-center">{{ $match->away_yellow_cards ?? 0 }}</td>
                        <td class="px-3 py-2 text-center">{{ $match->away_blue_cards ?? 0 }}</td>
                        <td class="px-3 py-2 text-center">{{ $match->away_red_cards ?? 0 }}</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
    @endif

    {{-- Eventos --}}
    @if($match->events->count() > 0)
    <div>
        <h3 class="text-xs font-bold text-gray-500 uppercase tracking-wider mb-2">Eventos del Partido</h3>
        <div class="space-y-1 max-h-48 overflow-y-auto">
            @foreach($match->events->sortBy('minute') as $event)
            <div class="flex items-center gap-3 px-3 py-2 rounded-lg bg-gray-50 dark:bg-gray-800 text-sm">
                <span class="text-xs text-gray-400 w-8 text-right flex-shrink-0">
                    {{ $event->minute ? $event->minute."'" : '—' }}
                </span>
                <span class="flex-shrink-0 text-base">
                    {{ match($event->type) {
                        'goal', 'penalty_goal' => '⚽',
                        'own_goal'             => '🙈',
                        'penalty_miss'         => '❌',
                        'yellow_card','second_yellow' => '🟡',
                        'blue_card'            => '🔵',
                        'red_card'             => '🔴',
                        'substitution'         => '🔄',
                        'foul','team_foul'     => '🚫',
                        'injury'               => '🏥',
                        default                => '•',
                    } }}
                </span>
                <span class="flex-1 text-gray-700 dark:text-gray-300">
                    {{ $event->player ? $event->player->first_name.' '.$event->player->last_name : '—' }}
                </span>
                <span class="text-xs text-gray-400">{{ $event->team->name ?? '' }}</span>
            </div>
            @endforeach
        </div>
    </div>
    @endif

    {{-- Observaciones --}}
    @if($match->observations)
    <div class="bg-yellow-50 dark:bg-yellow-900/20 rounded-lg p-3">
        <p class="text-xs font-bold text-yellow-700 dark:text-yellow-400 uppercase tracking-wide mb-1">Observaciones</p>
        <p class="text-sm text-gray-700 dark:text-gray-300">{{ $match->observations }}</p>
    </div>
    @endif

</div>
