<?php

namespace App\Filament\Resources\TeamResource\RelationManagers;

use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;
use Carbon\Carbon;

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
                ->maxLength(255)
                ->extraInputAttributes(['style' => 'text-transform: capitalize;'])
                ->dehydrateStateUsing(fn (?string $state) => $state ? ucwords(mb_strtolower($state)) : null),
            Forms\Components\TextInput::make('last_name')
                ->label('Apellido')
                ->required()
                ->maxLength(255)
                ->extraInputAttributes(['style' => 'text-transform: capitalize;'])
                ->dehydrateStateUsing(fn (?string $state) => $state ? ucwords(mb_strtolower($state)) : null),
            Forms\Components\Select::make('document_type')
                ->label('Tipo de documento')
                ->options([
                    'CC' => 'Cédula de Ciudadanía',
                    'TI' => 'Tarjeta de Identidad',
                    'CE' => 'Cédula de Extranjería',
                    'PA' => 'Pasaporte',
                    'RC' => 'Registro Civil',
                ])
                ->required(),
            Forms\Components\TextInput::make('document_number')
                ->label('Documento')
                ->required()
                ->maxLength(20),
            Forms\Components\DatePicker::make('birth_date')
                ->label('Fecha de nacimiento')
                ->required()
                ->maxDate(now())
                ->reactive(),
            Forms\Components\Placeholder::make('age_display')
                ->label('Edad')
                ->content(function (Forms\Get $get): string {
                    $birthDate = $get('birth_date');
                    if (!$birthDate) return '-';
                    $age = Carbon::parse($birthDate)->age;
                    $minor = $age < 18 ? ' (Menor de edad)' : '';
                    return "{$age} años{$minor}";
                }),
            Forms\Components\TextInput::make('church')
                ->label('Iglesia')
                ->maxLength(255)
                ->extraInputAttributes(['style' => 'text-transform: capitalize;'])
                ->dehydrateStateUsing(fn (?string $state) => $state ? ucwords(mb_strtolower($state)) : null),
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
                ->disk('public')
                ->imageResizeMode('cover')
                ->imageCropAspectRatio('3:4')
                ->imageResizeTargetWidth('300')
                ->imageResizeTargetHeight('400'),
            Forms\Components\Toggle::make('has_eps')
                ->label('¿Tiene EPS?')
                ->default(true)
                ->reactive(),
            Forms\Components\FileUpload::make('eps_certificate')
                ->label('Certificado EPS')
                ->acceptedFileTypes(['application/pdf', 'image/jpeg', 'image/png'])
                ->directory('players/eps')
                ->disk('public')
                ->maxSize(5120)
                ->visible(fn (Forms\Get $get): bool => (bool) $get('has_eps')),
            Forms\Components\FileUpload::make('no_eps_consent')
                ->label('Consentimiento sin EPS')
                ->acceptedFileTypes(['application/pdf', 'image/jpeg', 'image/png'])
                ->directory('players/consents')
                ->disk('public')
                ->maxSize(5120)
                ->visible(fn (Forms\Get $get): bool => !(bool) $get('has_eps')),
            Forms\Components\FileUpload::make('parental_consent')
                ->label('Consentimiento de padres')
                ->acceptedFileTypes(['application/pdf', 'image/jpeg', 'image/png'])
                ->directory('players/parental')
                ->disk('public')
                ->maxSize(5120)
                ->visible(fn (Forms\Get $get): bool => $get('birth_date') && Carbon::parse($get('birth_date'))->age < 18),
            Forms\Components\Select::make('approval_status')
                ->label('Estado aprobación')
                ->options([
                    'pending' => 'Pendiente',
                    'approved' => 'Aprobado',
                    'rejected' => 'Rechazado',
                ])
                ->default('pending'),
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
                    ->disk('public')
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
                Tables\Columns\TextColumn::make('birth_date')
                    ->label('Edad')
                    ->formatStateUsing(fn ($record) => $record->age ? "{$record->age} años" : '-'),
                Tables\Columns\BadgeColumn::make('approval_status')
                    ->label('Estado')
                    ->colors([
                        'warning' => 'pending',
                        'success' => 'approved',
                        'danger' => 'rejected',
                    ])
                    ->formatStateUsing(fn (?string $state): string => match ($state) {
                        'pending' => 'Pendiente',
                        'approved' => 'Aprobado',
                        'rejected' => 'Rechazado',
                        default => $state ?? 'Pendiente',
                    }),
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
