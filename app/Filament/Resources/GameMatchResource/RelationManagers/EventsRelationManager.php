<?php

namespace App\Filament\Resources\GameMatchResource\RelationManagers;

use App\Models\Player;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;

class EventsRelationManager extends RelationManager
{
    protected static string $relationship = 'events';
    protected static ?string $title = 'Eventos del Partido';
    protected static ?string $modelLabel = 'Evento';

    public function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\Select::make('type')
                ->label('Tipo')
                ->options([
                    'goal' => 'Gol',
                    'own_goal' => 'Autogol',
                    'penalty_goal' => 'Gol de penal',
                    'penalty_miss' => 'Penal fallado',
                    'yellow_card' => 'Tarjeta amarilla',
                    'red_card' => 'Tarjeta roja',
                    'second_yellow' => 'Doble amarilla',
                    'substitution' => 'Sustitución',
                    'injury' => 'Lesión',
                ])
                ->required(),
            Forms\Components\Select::make('team_id')
                ->label('Equipo')
                ->options(function (RelationManager $livewire) {
                    $match = $livewire->getOwnerRecord();
                    return \App\Models\Team::whereIn('id', [$match->home_team_id, $match->away_team_id])
                        ->pluck('name', 'id');
                })
                ->required()
                ->reactive(),
            Forms\Components\Select::make('player_id')
                ->label('Jugador')
                ->options(function (Forms\Get $get) {
                    $teamId = $get('team_id');
                    if (!$teamId) return [];
                    return Player::where('team_id', $teamId)
                        ->where('is_active', true)
                        ->get()
                        ->mapWithKeys(fn ($p) => [$p->id => "#{$p->jersey_number} {$p->first_name} {$p->last_name}"]);
                })
                ->searchable()
                ->nullable(),
            Forms\Components\Select::make('secondary_player_id')
                ->label('Jugador secundario')
                ->helperText('Jugador que entra (sustitución) o asistencia')
                ->options(function (Forms\Get $get) {
                    $teamId = $get('team_id');
                    if (!$teamId) return [];
                    return Player::where('team_id', $teamId)
                        ->where('is_active', true)
                        ->get()
                        ->mapWithKeys(fn ($p) => [$p->id => "#{$p->jersey_number} {$p->first_name} {$p->last_name}"]);
                })
                ->searchable()
                ->nullable(),
            Forms\Components\TextInput::make('minute')
                ->label('Minuto')
                ->numeric()
                ->required()
                ->minValue(0)
                ->maxValue(130),
            Forms\Components\Select::make('half')
                ->label('Tiempo')
                ->options([
                    'first' => '1er Tiempo',
                    'second' => '2do Tiempo',
                    'extra_first' => 'Extra 1',
                    'extra_second' => 'Extra 2',
                ]),
            Forms\Components\Textarea::make('notes')
                ->label('Notas')
                ->rows(2)
                ->columnSpanFull(),
        ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('minute')
                    ->label('Min')
                    ->sortable()
                    ->suffix("'"),
                Tables\Columns\BadgeColumn::make('type')
                    ->label('Tipo')
                    ->colors([
                        'success' => fn ($state) => in_array($state, ['goal', 'penalty_goal']),
                        'warning' => fn ($state) => in_array($state, ['yellow_card', 'second_yellow', 'own_goal']),
                        'danger' => fn ($state) => in_array($state, ['red_card']),
                        'info' => fn ($state) => in_array($state, ['substitution']),
                        'gray' => fn ($state) => in_array($state, ['penalty_miss', 'injury']),
                    ])
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'goal' => 'Gol',
                        'own_goal' => 'Autogol',
                        'penalty_goal' => 'Penal',
                        'penalty_miss' => 'Penal fallado',
                        'yellow_card' => 'Amarilla',
                        'red_card' => 'Roja',
                        'second_yellow' => 'Doble amarilla',
                        'substitution' => 'Cambio',
                        'injury' => 'Lesión',
                        default => $state,
                    }),
                Tables\Columns\TextColumn::make('team.name')
                    ->label('Equipo'),
                Tables\Columns\TextColumn::make('player')
                    ->label('Jugador')
                    ->formatStateUsing(fn ($record) =>
                        $record->player ? "#{$record->player->jersey_number} {$record->player->first_name} {$record->player->last_name}" : '-'
                    ),
            ])
            ->defaultSort('minute')
            ->headerActions([
                Tables\Actions\CreateAction::make()->label('Agregar Evento'),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ]);
    }
}
