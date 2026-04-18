<?php

namespace App\Filament\Resources\GameMatchResource\RelationManagers;

use App\Models\Player;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;

class LineupsRelationManager extends RelationManager
{
    protected static string $relationship = 'lineups';
    protected static ?string $title = 'Alineaciones';
    protected static ?string $modelLabel = 'Jugador';

    public function form(Form $form): Form
    {
        return $form->schema([
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
                ->required()
                ->searchable(),
            Forms\Components\TextInput::make('jersey_number')
                ->label('Dorsal')
                ->numeric()
                ->minValue(1)
                ->maxValue(99),
            Forms\Components\Toggle::make('is_starter')
                ->label('Titular')
                ->default(true),
            Forms\Components\Select::make('position')
                ->label('Posición')
                ->options([
                    'portero' => 'Portero',
                    'defensa' => 'Defensa',
                    'mediocampista' => 'Mediocampista',
                    'delantero' => 'Delantero',
                ]),
        ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('team.name')
                    ->label('Equipo')
                    ->sortable(),
                Tables\Columns\TextColumn::make('jersey_number')
                    ->label('#')
                    ->sortable(),
                Tables\Columns\TextColumn::make('player')
                    ->label('Jugador')
                    ->formatStateUsing(fn ($record) =>
                        "{$record->player->first_name} {$record->player->last_name}"
                    ),
                Tables\Columns\TextColumn::make('position')
                    ->label('Posición')
                    ->formatStateUsing(fn (?string $state): string => match ($state) {
                        'portero' => 'POR',
                        'defensa' => 'DEF',
                        'mediocampista' => 'MED',
                        'delantero' => 'DEL',
                        default => $state ?? '-',
                    }),
                Tables\Columns\IconColumn::make('is_starter')
                    ->label('Titular')
                    ->boolean(),
            ])
            ->defaultSort('team_id')
            ->headerActions([
                Tables\Actions\CreateAction::make()->label('Agregar a Alineación'),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ]);
    }
}
