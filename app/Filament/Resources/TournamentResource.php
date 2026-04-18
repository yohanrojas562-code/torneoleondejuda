<?php

namespace App\Filament\Resources;

use App\Filament\Resources\TournamentResource\Pages;
use App\Models\Tournament;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Support\Str;

class TournamentResource extends Resource
{
    protected static ?string $model = Tournament::class;
    protected static ?string $navigationIcon = 'heroicon-o-trophy';
    protected static ?string $navigationGroup = 'Torneo';
    protected static ?int $navigationSort = 1;
    protected static ?string $modelLabel = 'Torneo';
    protected static ?string $pluralModelLabel = 'Torneos';

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\Section::make('Información del Torneo')->schema([
                Forms\Components\TextInput::make('name')
                    ->label('Nombre')
                    ->required()
                    ->maxLength(255)
                    ->live(onBlur: true)
                    ->afterStateUpdated(fn (Forms\Set $set, ?string $state) => $set('slug', Str::slug($state))),
                Forms\Components\TextInput::make('slug')
                    ->required()
                    ->maxLength(255)
                    ->unique(ignoreRecord: true),
                Forms\Components\Textarea::make('description')
                    ->label('Descripción')
                    ->rows(3)
                    ->columnSpanFull(),
                Forms\Components\TextInput::make('venue')
                    ->label('Sede')
                    ->maxLength(255),
                Forms\Components\Select::make('status')
                    ->label('Estado')
                    ->options([
                        'draft' => 'Borrador',
                        'registration' => 'Inscripciones',
                        'in_progress' => 'En curso',
                        'finished' => 'Finalizado',
                        'cancelled' => 'Cancelado',
                    ])
                    ->default('draft')
                    ->required(),
                Forms\Components\Toggle::make('is_active')
                    ->label('Activo')
                    ->default(true),
            ])->columns(2),

            Forms\Components\Section::make('Fechas')->schema([
                Forms\Components\DatePicker::make('start_date')
                    ->label('Fecha inicio'),
                Forms\Components\DatePicker::make('end_date')
                    ->label('Fecha fin'),
            ])->columns(2),

            Forms\Components\Section::make('Imágenes')->schema([
                Forms\Components\FileUpload::make('logo')
                    ->label('Logo')
                    ->image()
                    ->directory('tournaments/logos')
                    ->imageResizeMode('cover')
                    ->imageCropAspectRatio('1:1')
                    ->imageResizeTargetWidth('300')
                    ->imageResizeTargetHeight('300'),
                Forms\Components\FileUpload::make('banner')
                    ->label('Banner')
                    ->image()
                    ->directory('tournaments/banners')
                    ->imageResizeMode('cover')
                    ->imageResizeTargetWidth('1200')
                    ->imageResizeTargetHeight('400'),
            ])->columns(2),

            Forms\Components\Section::make('Reglamento')->schema([
                Forms\Components\RichEditor::make('rules')
                    ->label('Reglas del torneo')
                    ->columnSpanFull(),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('logo')
                    ->circular()
                    ->size(40),
                Tables\Columns\TextColumn::make('name')
                    ->label('Nombre')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('venue')
                    ->label('Sede')
                    ->searchable(),
                Tables\Columns\BadgeColumn::make('status')
                    ->label('Estado')
                    ->colors([
                        'gray' => 'draft',
                        'info' => 'registration',
                        'warning' => 'in_progress',
                        'success' => 'finished',
                        'danger' => 'cancelled',
                    ])
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'draft' => 'Borrador',
                        'registration' => 'Inscripciones',
                        'in_progress' => 'En curso',
                        'finished' => 'Finalizado',
                        'cancelled' => 'Cancelado',
                        default => $state,
                    }),
                Tables\Columns\IconColumn::make('is_active')
                    ->label('Activo')
                    ->boolean(),
                Tables\Columns\TextColumn::make('seasons_count')
                    ->label('Temporadas')
                    ->counts('seasons'),
                Tables\Columns\TextColumn::make('start_date')
                    ->label('Inicio')
                    ->date('d/m/Y')
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->label('Estado')
                    ->options([
                        'draft' => 'Borrador',
                        'registration' => 'Inscripciones',
                        'in_progress' => 'En curso',
                        'finished' => 'Finalizado',
                        'cancelled' => 'Cancelado',
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
            TournamentResource\RelationManagers\SeasonsRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListTournaments::route('/'),
            'create' => Pages\CreateTournament::route('/create'),
            'edit' => Pages\EditTournament::route('/{record}/edit'),
        ];
    }
}
