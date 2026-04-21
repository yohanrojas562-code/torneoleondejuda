<?php

namespace App\Filament\Resources;

use App\Filament\Resources\MisPartidosResource\Pages;
use App\Models\GameMatch;
use App\Models\Team;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Tables\Actions\Action;
use Filament\Tables\Filters\SelectFilter;
use Illuminate\Database\Eloquent\Builder;

class MisPartidosResource extends Resource
{
    protected static ?string $model = GameMatch::class;
    protected static ?string $navigationIcon = 'heroicon-o-play-circle';
    protected static ?string $navigationGroup = 'Mi Equipo';
    protected static ?string $navigationLabel = 'Partidos';
    protected static ?string $modelLabel = 'Partido';
    protected static ?string $pluralModelLabel = 'Partidos';
    protected static ?string $slug = 'mis-partidos';
    protected static ?int $navigationSort = 3;

    public static function shouldRegisterNavigation(): bool
    {
        $user = auth()->user();
        return $user?->hasRole('lider_equipo') && !$user?->hasRole('admin');
    }

    public static function canCreate(): bool
    {
        return false;
    }

    public static function canEdit(\Illuminate\Database\Eloquent\Model $record): bool
    {
        return false;
    }

    public static function canDelete(\Illuminate\Database\Eloquent\Model $record): bool
    {
        return false;
    }

    public static function table(Table $table): Table
    {
        $user  = auth()->user();
        $teamIds = Team::where('leader_id', $user?->id)->pluck('id');

        return $table
            ->modifyQueryUsing(fn (Builder $query) => $query
                ->with(['homeTeam', 'awayTeam', 'venue', 'matchDay', 'season'])
                ->where(function (Builder $q) use ($teamIds) {
                    $q->whereIn('home_team_id', $teamIds)
                      ->orWhereIn('away_team_id', $teamIds);
                })
                ->orderByDesc('scheduled_at')
            )
            ->columns([
                Tables\Columns\TextColumn::make('season.name')
                    ->label('Temporada')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('matchDay.name')
                    ->label('Jornada')
                    ->sortable()
                    ->placeholder('—'),

                Tables\Columns\TextColumn::make('scheduled_at')
                    ->label('Fecha y Hora')
                    ->dateTime('d/m/Y H:i', 'UTC')
                    ->sortable(),

                Tables\Columns\TextColumn::make('homeTeam.name')
                    ->label('Local')
                    ->weight('bold')
                    ->formatStateUsing(function ($state, GameMatch $record) use ($teamIds) {
                        return $teamIds->contains($record->home_team_id)
                            ? "⭐ {$state}"
                            : $state;
                    }),

                Tables\Columns\TextColumn::make('marcador')
                    ->label('Marcador')
                    ->alignCenter()
                    ->getStateUsing(function (GameMatch $record): string {
                        if ($record->status === 'finished') {
                            $score = "{$record->home_score} - {$record->away_score}";
                            if ($record->home_penalty_score !== null && $record->away_penalty_score !== null) {
                                $score .= " (pen. {$record->home_penalty_score}-{$record->away_penalty_score})";
                            }
                            return $score;
                        }
                        if (in_array($record->status, ['first_half', 'halftime', 'second_half', 'extra_time', 'penalties', 'warmup'])) {
                            return "{$record->home_score} - {$record->away_score}";
                        }
                        return 'vs';
                    })
                    ->color(function ($state, $record): string {
                        return match ($record->status) {
                            'finished' => 'success',
                            'first_half', 'halftime', 'second_half', 'extra_time', 'penalties' => 'warning',
                            default => 'gray',
                        };
                    }),

                Tables\Columns\TextColumn::make('awayTeam.name')
                    ->label('Visitante')
                    ->weight('bold')
                    ->formatStateUsing(function ($state, GameMatch $record) use ($teamIds) {
                        return $teamIds->contains($record->away_team_id)
                            ? "⭐ {$state}"
                            : $state;
                    }),

                Tables\Columns\TextColumn::make('status')
                    ->label('Estado')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'scheduled'   => 'gray',
                        'warmup'      => 'warning',
                        'first_half'  => 'success',
                        'halftime'    => 'warning',
                        'second_half' => 'success',
                        'extra_time'  => 'success',
                        'penalties'   => 'success',
                        'finished'    => 'primary',
                        'suspended'   => 'danger',
                        'cancelled'   => 'danger',
                        'postponed'   => 'warning',
                        default       => 'gray',
                    })
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'scheduled'    => 'Programado',
                        'warmup'       => 'Calentamiento',
                        'first_half'   => '1er Tiempo',
                        'halftime'     => 'Entretiempo',
                        'second_half'  => '2do Tiempo',
                        'extra_time'   => 'Tiempo extra',
                        'penalties'    => 'Penales',
                        'finished'     => 'Finalizado',
                        'suspended'    => 'Suspendido',
                        'cancelled'    => 'Cancelado',
                        'postponed'    => 'Aplazado',
                        default        => $state,
                    }),

                Tables\Columns\TextColumn::make('venue.name')
                    ->label('Escenario')
                    ->placeholder('—')
                    ->toggleable(),

                Tables\Columns\TextColumn::make('tarjetas_equipo')
                    ->label('Tarjetas equipo')
                    ->alignCenter()
                    ->getStateUsing(function (GameMatch $record) use ($teamIds): string {
                        $isHome = $teamIds->contains($record->home_team_id);
                        $y = $isHome ? $record->home_yellow_cards : $record->away_yellow_cards;
                        $b = $isHome ? $record->home_blue_cards   : $record->away_blue_cards;
                        $r = $isHome ? $record->home_red_cards    : $record->away_red_cards;
                        $parts = [];
                        if ($y) $parts[] = "🟡{$y}";
                        if ($b) $parts[] = "🔵{$b}";
                        if ($r) $parts[] = "🔴{$r}";
                        return $parts ? implode(' ', $parts) : '—';
                    })
                    ->toggleable(),

                Tables\Columns\TextColumn::make('observations')
                    ->label('Observaciones')
                    ->placeholder('—')
                    ->limit(50)
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                SelectFilter::make('status')
                    ->label('Estado')
                    ->options([
                        'scheduled'   => 'Programado',
                        'finished'    => 'Finalizado',
                        'postponed'   => 'Aplazado',
                        'suspended'   => 'Suspendido',
                        'cancelled'   => 'Cancelado',
                    ]),
                SelectFilter::make('match_day_id')
                    ->label('Jornada')
                    ->relationship('matchDay', 'name'),
            ])
            ->defaultSort('scheduled_at', 'desc')
            ->striped()
            ->actions([
                Action::make('ver')
                    ->label('Ver detalles')
                    ->icon('heroicon-o-eye')
                    ->color('gray')
                    ->modalHeading(fn (GameMatch $record) =>
                        ($record->homeTeam->name ?? '') . ' vs ' . ($record->awayTeam->name ?? '')
                    )
                    ->modalSubmitAction(false)
                    ->modalCancelActionLabel('Cerrar')
                    ->modalContent(fn (GameMatch $record) => view(
                        'filament.mis-partidos.detalle',
                        ['match' => $record->load([
                            'homeTeam', 'awayTeam', 'venue', 'matchDay', 'season',
                            'events.player', 'events.team',
                            'lineups.player', 'lineups.team',
                        ])]
                    )),
            ])
            ->bulkActions([]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListMisPartidos::route('/'),
        ];
    }
}
