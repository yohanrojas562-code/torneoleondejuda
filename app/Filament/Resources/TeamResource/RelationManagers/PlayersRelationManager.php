<?php

namespace App\Filament\Resources\TeamResource\RelationManagers;

use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;

class PlayersRelationManager extends RelationManager
{
    protected static string $relationship = 'players';
    protected static ?string $title = 'Jugadores';
    protected static ?string $modelLabel = 'Jugador';

    public function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\TextInput::make('first_name')
                ->label('Nombre')
                ->required()
                ->maxLength(255),
            Forms\Components\TextInput::make('last_name')
                ->label('Apellido')
                ->required()
                ->maxLength(255),
            Forms\Components\TextInput::make('document_number')
                ->label('Documento')
                ->maxLength(20),
            Forms\Components\DatePicker::make('birth_date')
                ->label('Fecha de nacimiento'),
            Forms\Components\TextInput::make('jersey_number')
                ->label('Dorsal')
                ->numeric()
                ->minValue(1)
                ->maxValue(99),
            Forms\Components\Select::make('position')
                ->label('Posición')
                ->options([
                    'portero' => 'Portero',
                    'defensa' => 'Defensa',
                    'mediocampista' => 'Mediocampista',
                    'delantero' => 'Delantero',
                ]),
            Forms\Components\FileUpload::make('photo')
                ->label('Foto')
                ->image()
                ->directory('players/photos')
                ->imageResizeMode('cover')
                ->imageCropAspectRatio('3:4')
                ->imageResizeTargetWidth('300')
                ->imageResizeTargetHeight('400'),
            Forms\Components\Toggle::make('is_active')
                ->label('Activo')
                ->default(true),
        ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('photo')
                    ->label('Foto')
                    ->circular()
                    ->size(35),
                Tables\Columns\TextColumn::make('jersey_number')
                    ->label('#')
                    ->sortable(),
                Tables\Columns\TextColumn::make('first_name')
                    ->label('Nombre')
                    ->searchable(),
                Tables\Columns\TextColumn::make('last_name')
                    ->label('Apellido')
                    ->searchable(),
                Tables\Columns\TextColumn::make('position')
                    ->label('Posición')
                    ->formatStateUsing(fn (?string $state): string => match ($state) {
                        'portero' => 'Portero',
                        'defensa' => 'Defensa',
                        'mediocampista' => 'Mediocampista',
                        'delantero' => 'Delantero',
                        default => $state ?? '-',
                    }),
                Tables\Columns\TextColumn::make('document_number')
                    ->label('Documento'),
                Tables\Columns\IconColumn::make('is_active')
                    ->label('Activo')
                    ->boolean(),
            ])
            ->defaultSort('jersey_number')
            ->headerActions([
                Tables\Actions\CreateAction::make()->label('Agregar Jugador'),
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
}
