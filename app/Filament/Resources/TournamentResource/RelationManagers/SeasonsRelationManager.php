<?php

namespace App\Filament\Resources\TournamentResource\RelationManagers;

use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Support\Str;

class SeasonsRelationManager extends RelationManager
{
    protected static string $relationship = 'seasons';
    protected static ?string $title = 'Temporadas';
    protected static ?string $modelLabel = 'Temporada';

    public function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\TextInput::make('name')
                ->label('Nombre')
                ->required()
                ->live(onBlur: true)
                ->afterStateUpdated(fn (Forms\Set $set, ?string $state) => $set('slug', Str::slug($state))),
            Forms\Components\TextInput::make('slug')
                ->required()
                ->unique(ignoreRecord: true),
            Forms\Components\Select::make('category_id')
                ->label('Categoría')
                ->relationship('category', 'name')
                ->required()
                ->createOptionForm([
                    Forms\Components\TextInput::make('name')->label('Nombre')->required(),
                    Forms\Components\TextInput::make('slug')->required(),
                ]),
            Forms\Components\Select::make('status')
                ->label('Estado')
                ->options([
                    'draft' => 'Borrador',
                    'registration' => 'Inscripciones',
                    'group_stage' => 'Fase de grupos',
                    'knockout' => 'Eliminatorias',
                    'finished' => 'Finalizada',
                ])
                ->default('draft'),
            Forms\Components\DatePicker::make('start_date')->label('Inicio'),
            Forms\Components\DatePicker::make('end_date')->label('Fin'),
        ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')->label('Nombre')->sortable(),
                Tables\Columns\TextColumn::make('category.name')->label('Categoría'),
                Tables\Columns\BadgeColumn::make('status')
                    ->label('Estado')
                    ->colors([
                        'gray' => 'draft',
                        'info' => 'registration',
                        'warning' => 'group_stage',
                        'primary' => 'knockout',
                        'success' => 'finished',
                    ])
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'draft' => 'Borrador',
                        'registration' => 'Inscripciones',
                        'group_stage' => 'Fase de grupos',
                        'knockout' => 'Eliminatorias',
                        'finished' => 'Finalizada',
                        default => $state,
                    }),
                Tables\Columns\TextColumn::make('teams_count')
                    ->label('Equipos')
                    ->counts('teams'),
                Tables\Columns\TextColumn::make('start_date')
                    ->label('Inicio')
                    ->date('d/m/Y'),
            ])
            ->headerActions([
                Tables\Actions\CreateAction::make()->label('Nueva Temporada'),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ]);
    }
}
