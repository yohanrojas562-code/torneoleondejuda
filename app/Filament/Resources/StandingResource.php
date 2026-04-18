<?php

namespace App\Filament\Resources;

use App\Filament\Resources\StandingResource\Pages;
use App\Models\Standing;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class StandingResource extends Resource
{
    protected static ?string $model = Standing::class;
    protected static ?string $navigationIcon = 'heroicon-o-chart-bar';
    protected static ?string $navigationGroup = 'Partidos';
    protected static ?int $navigationSort = 5;
    protected static ?string $modelLabel = 'Clasificación';
    protected static ?string $pluralModelLabel = 'Tabla de Posiciones';

    public static function shouldRegisterNavigation(): bool
    {
        return auth()->user()?->hasRole('admin');
    }

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\Section::make()->schema([
                Forms\Components\Select::make('season_id')
                    ->label('Temporada')
                    ->relationship('season', 'name')
                    ->required()
                    ->searchable()
                    ->preload(),
                Forms\Components\Select::make('group_id')
                    ->label('Grupo')
                    ->relationship('group', 'name')
                    ->searchable()
                    ->preload()
                    ->nullable(),
                Forms\Components\Select::make('team_id')
                    ->label('Equipo')
                    ->relationship('team', 'name')
                    ->required()
                    ->searchable()
                    ->preload(),
                Forms\Components\TextInput::make('position')
                    ->label('Posición')
                    ->numeric()
                    ->default(0),
            ])->columns(2),

            Forms\Components\Section::make('Estadísticas')->schema([
                Forms\Components\TextInput::make('played')->label('PJ')->numeric()->default(0),
                Forms\Components\TextInput::make('won')->label('PG')->numeric()->default(0),
                Forms\Components\TextInput::make('drawn')->label('PE')->numeric()->default(0),
                Forms\Components\TextInput::make('lost')->label('PP')->numeric()->default(0),
                Forms\Components\TextInput::make('goals_for')->label('GF')->numeric()->default(0),
                Forms\Components\TextInput::make('goals_against')->label('GC')->numeric()->default(0),
                Forms\Components\TextInput::make('goal_difference')->label('DG')->numeric()->default(0),
                Forms\Components\TextInput::make('points')->label('PTS')->numeric()->default(0),
            ])->columns(4),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('position')
                    ->label('#')
                    ->sortable(),
                Tables\Columns\ImageColumn::make('team.logo')
                    ->label('')
                    ->circular()
                    ->size(30),
                Tables\Columns\TextColumn::make('team.name')
                    ->label('Equipo')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('group.name')
                    ->label('Grupo')
                    ->sortable(),
                Tables\Columns\TextColumn::make('played')->label('PJ')->sortable()->alignCenter(),
                Tables\Columns\TextColumn::make('won')->label('PG')->alignCenter(),
                Tables\Columns\TextColumn::make('drawn')->label('PE')->alignCenter(),
                Tables\Columns\TextColumn::make('lost')->label('PP')->alignCenter(),
                Tables\Columns\TextColumn::make('goals_for')->label('GF')->alignCenter(),
                Tables\Columns\TextColumn::make('goals_against')->label('GC')->alignCenter(),
                Tables\Columns\TextColumn::make('goal_difference')->label('DG')->alignCenter()
                    ->color(fn ($state) => $state > 0 ? 'success' : ($state < 0 ? 'danger' : 'gray')),
                Tables\Columns\TextColumn::make('points')
                    ->label('PTS')
                    ->sortable()
                    ->alignCenter()
                    ->weight('bold')
                    ->size('lg'),
            ])
            ->defaultSort('points', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('season_id')
                    ->label('Temporada')
                    ->relationship('season', 'name'),
                Tables\Filters\SelectFilter::make('group_id')
                    ->label('Grupo')
                    ->relationship('group', 'name'),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListStandings::route('/'),
            'create' => Pages\CreateStanding::route('/create'),
            'edit' => Pages\EditStanding::route('/{record}/edit'),
        ];
    }
}
