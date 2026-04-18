<?php

namespace App\Filament\Resources;

use App\Filament\Resources\TeamResource\Pages;
use App\Filament\Resources\TeamResource\RelationManagers;
use App\Models\Team;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Support\Str;

class TeamResource extends Resource
{
    protected static ?string $model = Team::class;
    protected static ?string $navigationIcon = 'heroicon-o-user-group';
    protected static ?string $navigationGroup = 'Equipos';
    protected static ?int $navigationSort = 3;
    protected static ?string $modelLabel = 'Equipo';
    protected static ?string $pluralModelLabel = 'Equipos';

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\Section::make('Información del Equipo')->schema([
                Forms\Components\TextInput::make('name')
                    ->label('Nombre')
                    ->required()
                    ->maxLength(255)
                    ->live(onBlur: true)
                    ->afterStateUpdated(fn (Forms\Set $set, ?string $state) => $set('slug', Str::slug($state))),
                Forms\Components\TextInput::make('slug')
                    ->required()
                    ->unique(ignoreRecord: true),
                Forms\Components\TextInput::make('short_name')
                    ->label('Nombre corto')
                    ->maxLength(5)
                    ->placeholder('EJ: LEO'),
                Forms\Components\FileUpload::make('logo')
                    ->label('Escudo')
                    ->image()
                    ->directory('teams/logos')
                    ->imageResizeMode('cover')
                    ->imageCropAspectRatio('1:1')
                    ->imageResizeTargetWidth('300')
                    ->imageResizeTargetHeight('300'),
                Forms\Components\ColorPicker::make('primary_color')
                    ->label('Color principal'),
                Forms\Components\ColorPicker::make('secondary_color')
                    ->label('Color secundario'),
                Forms\Components\Toggle::make('is_active')
                    ->label('Activo')
                    ->default(true),
            ])->columns(2),

            Forms\Components\Section::make('Responsables')->schema([
                Forms\Components\Select::make('leader_id')
                    ->label('Líder de equipo')
                    ->relationship('leader', 'name')
                    ->searchable()
                    ->preload()
                    ->nullable(),
                Forms\Components\Select::make('captain_id')
                    ->label('Capitán')
                    ->relationship('captain', 'name')
                    ->searchable()
                    ->preload()
                    ->nullable(),
            ])->columns(2),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('logo')
                    ->label('Escudo')
                    ->circular()
                    ->size(40),
                Tables\Columns\TextColumn::make('name')
                    ->label('Nombre')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('short_name')
                    ->label('Abrev.'),
                Tables\Columns\ColorColumn::make('primary_color')
                    ->label('Color'),
                Tables\Columns\TextColumn::make('leader.name')
                    ->label('Líder'),
                Tables\Columns\TextColumn::make('captain.name')
                    ->label('Capitán'),
                Tables\Columns\TextColumn::make('players_count')
                    ->label('Jugadores')
                    ->counts('players'),
                Tables\Columns\IconColumn::make('is_active')
                    ->label('Activo')
                    ->boolean(),
            ])
            ->filters([
                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('Activo'),
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
            RelationManagers\PlayersRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListTeams::route('/'),
            'create' => Pages\CreateTeam::route('/create'),
            'edit' => Pages\EditTeam::route('/{record}/edit'),
        ];
    }
}
