<?php

namespace App\Filament\Resources;

use App\Filament\Resources\GameMatchResource\Pages;
use App\Filament\Resources\GameMatchResource\RelationManagers;
use App\Models\GameMatch;
use App\Models\Team;
use App\Models\Venue;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class GameMatchResource extends Resource
{
    protected static ?string $model = GameMatch::class;
    protected static ?string $navigationIcon = 'heroicon-o-play-circle';
    protected static ?string $navigationGroup = 'Partidos';
    protected static ?int $navigationSort = 4;
    protected static ?string $modelLabel = 'Partido';
    protected static ?string $pluralModelLabel = 'Partidos';

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\Section::make('Partido')->schema([
                Forms\Components\Select::make('season_id')
                    ->label('Temporada')
                    ->relationship('season', 'name')
                    ->required()
                    ->searchable()
                    ->preload()
                    ->reactive(),
                Forms\Components\Select::make('match_day_id')
                    ->label('Jornada')
                    ->relationship('matchDay', 'name', fn ($query, Forms\Get $get) =>
                        $query->when($get('season_id'), fn ($q, $v) => $q->where('season_id', $v))
                    )
                    ->searchable()
                    ->preload()
                    ->nullable(),
                Forms\Components\Select::make('home_team_id')
                    ->label('Equipo local')
                    ->options(fn () => Team::where('is_active', true)->pluck('name', 'id'))
                    ->required()
                    ->searchable(),
                Forms\Components\Select::make('away_team_id')
                    ->label('Equipo visitante')
                    ->options(fn () => Team::where('is_active', true)->pluck('name', 'id'))
                    ->required()
                    ->searchable()
                    ->different('home_team_id'),
                Forms\Components\Select::make('referee_id')
                    ->label('Árbitro')
                    ->relationship('referee', 'name')
                    ->searchable()
                    ->preload()
                    ->nullable(),
                Forms\Components\Select::make('status')
                    ->label('Estado')
                    ->options([
                        'scheduled' => 'Programado',
                        'warmup' => 'Calentamiento',
                        'first_half' => '1er Tiempo',
                        'halftime' => 'Entretiempo',
                        'second_half' => '2do Tiempo',
                        'extra_time' => 'Tiempo extra',
                        'penalties' => 'Penales',
                        'finished' => 'Finalizado',
                        'suspended' => 'Suspendido',
                        'cancelled' => 'Cancelado',
                        'postponed' => 'Aplazado',
                    ])
                    ->default('scheduled')
                    ->required(),
            ])->columns(2),

            Forms\Components\Section::make('Programación')->schema([
                Forms\Components\DateTimePicker::make('scheduled_at')
                    ->label('Fecha y hora'),
                Forms\Components\Select::make('venue_id')
                    ->label('Escenario')
                    ->relationship('venue', 'name')
                    ->searchable()
                    ->preload()
                    ->nullable()
                    ->createOptionForm([
                        Forms\Components\TextInput::make('name')
                            ->label('Nombre del escenario')
                            ->required()
                            ->maxLength(255),
                        Forms\Components\TextInput::make('address')
                            ->label('Dirección')
                            ->maxLength(255),
                    ]),
            ])->columns(2),

            Forms\Components\Section::make('Marcador')->schema([
                Forms\Components\TextInput::make('home_score')
                    ->label('Goles local')
                    ->numeric()
                    ->minValue(0)
                    ->nullable(),
                Forms\Components\TextInput::make('away_score')
                    ->label('Goles visitante')
                    ->numeric()
                    ->minValue(0)
                    ->nullable(),
                Forms\Components\TextInput::make('home_penalty_score')
                    ->label('Penales local')
                    ->numeric()
                    ->minValue(0)
                    ->nullable(),
                Forms\Components\TextInput::make('away_penalty_score')
                    ->label('Penales visitante')
                    ->numeric()
                    ->minValue(0)
                    ->nullable(),
            ])->columns(4),

            Forms\Components\Section::make('Observaciones')->schema([
                Forms\Components\Textarea::make('observations')
                    ->label('Notas')
                    ->rows(3)
                    ->columnSpanFull(),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('season.name')
                    ->label('Temporada')
                    ->sortable()
                    ->toggleable(),
                Tables\Columns\TextColumn::make('matchDay.name')
                    ->label('Jornada')
                    ->toggleable(),
                Tables\Columns\TextColumn::make('homeTeam.name')
                    ->label('Local')
                    ->searchable(),
                Tables\Columns\TextColumn::make('home_score')
                    ->label('')
                    ->alignCenter()
                    ->formatStateUsing(fn ($record) =>
                        ($record->home_score !== null && $record->away_score !== null)
                            ? "{$record->home_score} - {$record->away_score}"
                            : 'vs'
                    ),
                Tables\Columns\TextColumn::make('awayTeam.name')
                    ->label('Visitante')
                    ->searchable(),
                Tables\Columns\BadgeColumn::make('status')
                    ->label('Estado')
                    ->colors([
                        'gray' => 'scheduled',
                        'warning' => fn ($state) => in_array($state, ['warmup', 'halftime', 'postponed']),
                        'success' => fn ($state) => in_array($state, ['first_half', 'second_half', 'extra_time', 'penalties']),
                        'primary' => 'finished',
                        'danger' => fn ($state) => in_array($state, ['suspended', 'cancelled']),
                    ])
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'scheduled' => 'Programado',
                        'warmup' => 'Calentamiento',
                        'first_half' => '1er Tiempo',
                        'halftime' => 'Entretiempo',
                        'second_half' => '2do Tiempo',
                        'extra_time' => 'Tiempo extra',
                        'penalties' => 'Penales',
                        'finished' => 'Finalizado',
                        'suspended' => 'Suspendido',
                        'cancelled' => 'Cancelado',
                        'postponed' => 'Aplazado',
                        default => $state,
                    }),
                Tables\Columns\TextColumn::make('scheduled_at')
                    ->label('Fecha')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),
                Tables\Columns\TextColumn::make('venue.name')
                    ->label('Escenario')
                    ->toggleable()
                    ->limit(25),
                Tables\Columns\TextColumn::make('referee.name')
                    ->label('Árbitro')
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->defaultSort('scheduled_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('season_id')
                    ->label('Temporada')
                    ->relationship('season', 'name'),
                Tables\Filters\SelectFilter::make('status')
                    ->label('Estado')
                    ->options([
                        'scheduled' => 'Programado',
                        'first_half' => 'En juego',
                        'finished' => 'Finalizado',
                        'suspended' => 'Suspendido',
                    ]),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            RelationManagers\EventsRelationManager::class,
            RelationManagers\LineupsRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListGameMatches::route('/'),
            'create' => Pages\CreateGameMatch::route('/create'),
            'edit' => Pages\EditGameMatch::route('/{record}/edit'),
        ];
    }
}
