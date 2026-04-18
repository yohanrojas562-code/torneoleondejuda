<?php

namespace App\Filament\Resources;

use App\Filament\Resources\PlayerResource\Pages;
use App\Models\Player;
use App\Models\Team;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Carbon\Carbon;
use Illuminate\Database\Eloquent\Builder;

class PlayerResource extends Resource
{
    protected static ?string $model = Player::class;
    protected static ?string $navigationIcon = 'heroicon-o-identification';
    protected static ?string $navigationGroup = 'Equipos';
    protected static ?int $navigationSort = 4;
    protected static ?string $modelLabel = 'Jugador';
    protected static ?string $pluralModelLabel = 'Jugadores';

    public static function form(Form $form): Form
    {
        $user = auth()->user();
        $isAdmin = $user?->hasRole('admin');
        $isLider = $user?->hasRole('lider_equipo');

        return $form->schema([
            Forms\Components\Section::make('Datos Personales')->schema([
                Forms\Components\TextInput::make('first_name')
                    ->label('Nombres')
                    ->required()
                    ->maxLength(255)
                    ->extraInputAttributes(['style' => 'text-transform: capitalize;'])
                    ->dehydrateStateUsing(fn (?string $state) => $state ? ucwords(mb_strtolower($state)) : null),
                Forms\Components\TextInput::make('last_name')
                    ->label('Apellidos')
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
                    ->label('Número de documento')
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
                    ->label('Iglesia a la que pertenece')
                    ->maxLength(255)
                    ->placeholder('Ej: CFE Manrique La Salle')
                    ->extraInputAttributes(['style' => 'text-transform: capitalize;'])
                    ->dehydrateStateUsing(fn (?string $state) => $state ? ucwords(mb_strtolower($state)) : null),
            ])->columns(2),

            Forms\Components\Section::make('Foto del Jugador')->schema([
                Forms\Components\FileUpload::make('photo')
                    ->label('Foto')
                    ->image()
                    ->directory('players/photos')
                    ->disk('public')
                    ->imageResizeMode('cover')
                    ->imageCropAspectRatio('3:4')
                    ->imageResizeTargetWidth('300')
                    ->imageResizeTargetHeight('400')
                    ->maxSize(3072)
                    ->openable()
                    ->downloadable(),
            ]),

            Forms\Components\Section::make('Documentación EPS')->schema([
                Forms\Components\Toggle::make('has_eps')
                    ->label('¿Tiene EPS?')
                    ->default(true)
                    ->reactive(),
                Forms\Components\FileUpload::make('eps_certificate')
                    ->label('Certificado de EPS (PDF o imagen)')
                    ->acceptedFileTypes(['application/pdf', 'image/jpeg', 'image/png'])
                    ->directory('players/eps')
                    ->disk('public')
                    ->maxSize(5120)
                    ->openable()
                    ->downloadable()
                    ->visible(fn (Forms\Get $get): bool => (bool) $get('has_eps'))
                    ->helperText('Sube el PDF o foto del certificado de EPS'),
                Forms\Components\FileUpload::make('no_eps_consent')
                    ->label('Consentimiento firmado (sin EPS)')
                    ->acceptedFileTypes(['application/pdf', 'image/jpeg', 'image/png'])
                    ->directory('players/consents')
                    ->disk('public')
                    ->maxSize(5120)
                    ->openable()
                    ->downloadable()
                    ->visible(fn (Forms\Get $get): bool => !(bool) $get('has_eps'))
                    ->helperText('Si no tiene EPS, sube el PDF firmado de consentimiento'),
            ])->columns(2),

            Forms\Components\Section::make('Consentimiento de Padres (Menores de 18)')
                ->schema([
                    Forms\Components\FileUpload::make('parental_consent')
                        ->label('Documento de consentimiento de padres (PDF)')
                        ->acceptedFileTypes(['application/pdf', 'image/jpeg', 'image/png'])
                        ->directory('players/parental')
                        ->disk('public')
                        ->maxSize(5120)
                        ->openable()
                        ->downloadable()
                        ->helperText('Obligatorio para menores de 18 años.'),
                ])
                ->visible(fn (Forms\Get $get): bool => $get('birth_date') && Carbon::parse($get('birth_date'))->age < 18),

            Forms\Components\Section::make('Equipo y Posición')->schema([
                Forms\Components\Select::make('team_id')
                    ->label('Equipo')
                    ->relationship('team', 'name')
                    ->searchable()
                    ->preload()
                    ->required()
                    ->visible($isAdmin),
                Forms\Components\TextInput::make('jersey_number')
                    ->label('Número de dorsal')
                    ->numeric()
                    ->minValue(1)
                    ->maxValue(99)
                    ->required(),
                Forms\Components\TextInput::make('jersey_name')
                    ->label('Nombre en dorsal')
                    ->maxLength(50)
                    ->placeholder('Nombre que aparece en la camiseta')
                    ->extraInputAttributes(['style' => 'text-transform: uppercase;'])
                    ->dehydrateStateUsing(fn (?string $state) => $state ? mb_strtoupper($state) : null),
                Forms\Components\Select::make('position')
                    ->label('Posición')
                    ->options([
                        'portero' => 'Portero',
                        'defensa' => 'Defensa',
                        'mediocampista' => 'Mediocampista',
                        'delantero' => 'Delantero',
                    ])
                    ->required(),
                Forms\Components\TextInput::make('height')
                    ->label('Estatura (cm)')
                    ->numeric()
                    ->minValue(100)
                    ->maxValue(250)
                    ->placeholder('Ej: 175')
                    ->suffix('cm'),
                Forms\Components\TextInput::make('weight')
                    ->label('Peso (kg)')
                    ->numeric()
                    ->minValue(30)
                    ->maxValue(200)
                    ->placeholder('Ej: 70')
                    ->suffix('kg'),
                Forms\Components\Toggle::make('is_captain')
                    ->label('¿Es capitán del equipo?')
                    ->default(false),
                Forms\Components\Toggle::make('is_active')
                    ->label('Activo')
                    ->default(true)
                    ->visible($isAdmin),
            ])->columns(2),

            // Solicitud especial (jugador extra, más de 12)
            Forms\Components\Section::make('Solicitud Especial')
                ->schema([
                    Forms\Components\Toggle::make('special_request')
                        ->label('¿Es solicitud especial? (jugador adicional)')
                        ->default(false)
                        ->reactive(),
                    Forms\Components\Textarea::make('special_request_reason')
                        ->label('Motivo de la solicitud especial')
                        ->rows(2)
                        ->required(fn (Forms\Get $get): bool => (bool) $get('special_request'))
                        ->visible(fn (Forms\Get $get): bool => (bool) $get('special_request'))
                        ->placeholder('Explica por qué necesitas inscribir un jugador adicional'),
                ])
                ->visible(function (Forms\Get $get) use ($isLider, $user) {
                    if (!$isLider) return false;
                    $team = Team::where('leader_id', $user?->id)->first();
                    if (!$team) return false;
                    return $team->players()->count() >= 12;
                }),

            Forms\Components\Section::make('Aprobación')
                ->schema([
                    Forms\Components\Select::make('approval_status')
                        ->label('Estado de aprobación')
                        ->options([
                            'pending' => 'Pendiente de revisión',
                            'approved' => 'Aprobado',
                            'rejected' => 'Rechazado',
                        ])
                        ->default('pending')
                        ->disabled(!$isAdmin),
                    Forms\Components\Textarea::make('rejection_reason')
                        ->label('Motivo de rechazo')
                        ->rows(2)
                        ->visible(fn (Forms\Get $get): bool => $get('approval_status') === 'rejected')
                        ->disabled(!$isAdmin),
                    // Vista para líder de equipo
                    Forms\Components\Placeholder::make('status_display')
                        ->label('Estado de la solicitud')
                        ->content(function ($record) {
                            if (!$record) return '⏳ Se creará como pendiente de aprobación';
                            return match ($record->approval_status) {
                                'pending' => '⏳ Solicitud enviada - Pendiente de revisión',
                                'approved' => '✅ Jugador aprobado',
                                'rejected' => '❌ Rechazado: ' . ($record->rejection_reason ?? 'Sin motivo especificado'),
                                default => 'Pendiente',
                            };
                        })
                        ->visible(!$isAdmin),
                ])->columns(1),

            Forms\Components\Section::make('Observaciones')
                ->schema([
                    Forms\Components\Textarea::make('observations')
                        ->label('Observaciones generales')
                        ->rows(3)
                        ->columnSpanFull(),
                    Forms\Components\Textarea::make('sanctions')
                        ->label('Sanciones')
                        ->rows(2)
                        ->columnSpanFull()
                        ->visible($isAdmin),
                ])
                ->visible($isAdmin),

            Forms\Components\Section::make('Estadísticas del Torneo')
                ->description('Se calculan automáticamente desde la planilla de partidos.')
                ->schema([
                    Forms\Components\TextInput::make('total_matches')
                        ->label('Partidos jugados')->numeric()->default(0)->disabled(),
                    Forms\Components\TextInput::make('total_goals')
                        ->label('Goles')->numeric()->default(0)->disabled(),
                    Forms\Components\TextInput::make('yellow_cards')
                        ->label('Tarjetas amarillas')->numeric()->default(0)->disabled(),
                    Forms\Components\TextInput::make('blue_cards')
                        ->label('Tarjetas azules')->numeric()->default(0)->disabled(),
                    Forms\Components\TextInput::make('red_cards')
                        ->label('Tarjetas rojas')->numeric()->default(0)->disabled(),
                    Forms\Components\TextInput::make('total_fouls')
                        ->label('Faltas')->numeric()->default(0)->disabled(),
                ])->columns(3)
                ->visible($isAdmin),
        ]);
    }

    public static function table(Table $table): Table
    {
        $user = auth()->user();
        $isAdmin = $user?->hasRole('admin');

        return $table
            ->modifyQueryUsing(function (Builder $query) use ($user, $isAdmin) {
                if (!$isAdmin && $user?->hasRole('lider_equipo')) {
                    $teamIds = Team::where('leader_id', $user->id)->pluck('id');
                    $query->whereIn('team_id', $teamIds);
                }
            })
            ->columns([
                Tables\Columns\ImageColumn::make('photo')
                    ->label('Foto')
                    ->disk('public')
                    ->circular()
                    ->size(40),
                Tables\Columns\TextColumn::make('first_name')
                    ->label('Nombre')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('last_name')
                    ->label('Apellidos')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('document_number')
                    ->label('Documento')
                    ->searchable(),
                Tables\Columns\TextColumn::make('team.name')
                    ->label('Equipo')
                    ->sortable()
                    ->searchable()
                    ->visible($isAdmin),
                Tables\Columns\TextColumn::make('jersey_number')
                    ->label('#')
                    ->sortable(),
                Tables\Columns\TextColumn::make('jersey_name')
                    ->label('Dorsal')
                    ->toggleable(),
                Tables\Columns\TextColumn::make('position')
                    ->label('Posición')
                    ->formatStateUsing(fn (?string $state): string => match ($state) {
                        'portero' => 'POR',
                        'defensa' => 'DEF',
                        'mediocampista' => 'MED',
                        'delantero' => 'DEL',
                        default => $state ?? '-',
                    }),
                Tables\Columns\IconColumn::make('is_captain')
                    ->label('Cap.')
                    ->boolean()
                    ->trueIcon('heroicon-o-star')
                    ->falseIcon('heroicon-o-minus'),
                Tables\Columns\TextColumn::make('birth_date')
                    ->label('Edad')
                    ->formatStateUsing(fn ($record) => $record->age ? "{$record->age} años" : '-')
                    ->sortable(),
                Tables\Columns\BadgeColumn::make('approval_status')
                    ->label('Estado')
                    ->colors([
                        'warning' => 'pending',
                        'success' => 'approved',
                        'danger' => 'rejected',
                    ])
                    ->formatStateUsing(fn (?string $state): string => match ($state) {
                        'pending' => $isAdmin ? 'Pendiente' : 'Solicitud enviada',
                        'approved' => 'Aprobado',
                        'rejected' => 'Rechazado',
                        default => $state ?? 'Pendiente',
                    }),
                Tables\Columns\TextColumn::make('total_matches')
                    ->label('PJ')
                    ->sortable()
                    ->toggleable()
                    ->visible($isAdmin),
                Tables\Columns\TextColumn::make('total_goals')
                    ->label('Goles')
                    ->sortable()
                    ->toggleable()
                    ->visible($isAdmin),
            ])
            ->defaultSort('first_name')
            ->filters([
                Tables\Filters\SelectFilter::make('team_id')
                    ->label('Equipo')
                    ->relationship('team', 'name')
                    ->visible($isAdmin),
                Tables\Filters\SelectFilter::make('approval_status')
                    ->label('Aprobación')
                    ->options([
                        'pending' => 'Pendiente',
                        'approved' => 'Aprobado',
                        'rejected' => 'Rechazado',
                    ]),
                Tables\Filters\SelectFilter::make('position')
                    ->label('Posición')
                    ->options([
                        'portero' => 'Portero',
                        'defensa' => 'Defensa',
                        'mediocampista' => 'Mediocampista',
                        'delantero' => 'Delantero',
                    ]),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make()
                    ->visible($isAdmin),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ])->visible($isAdmin),
            ]);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListPlayers::route('/'),
            'create' => Pages\CreatePlayer::route('/create'),
            'view' => Pages\ViewPlayer::route('/{record}'),
            'edit' => Pages\EditPlayer::route('/{record}/edit'),
        ];
    }
}
