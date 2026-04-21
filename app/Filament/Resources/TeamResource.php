<?php

namespace App\Filament\Resources;

use App\Filament\Resources\TeamResource\Pages;
use App\Filament\Resources\TeamResource\RelationManagers;
use App\Models\Season;
use App\Models\Team;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Support\Str;
use Illuminate\Database\Eloquent\Builder;

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
        $user = auth()->user();
        $isAdmin = $user?->hasRole('admin');

        return $form->schema([
            Forms\Components\Section::make('Información del Equipo')->schema([
                Forms\Components\TextInput::make('name')
                    ->label('Nombre')
                    ->required()
                    ->maxLength(255)
                    ->unique(ignoreRecord: true)
                    ->live(onBlur: true)
                    ->afterStateUpdated(fn (Forms\Set $set, ?string $state) => $set('slug', Str::slug($state)))
                    ->extraInputAttributes(['style' => 'text-transform: capitalize;'])
                    ->dehydrateStateUsing(fn (?string $state) => $state ? ucwords(mb_strtolower($state)) : null),
                Forms\Components\TextInput::make('slug')
                    ->required()
                    ->unique(ignoreRecord: true)
                    ->visible($isAdmin),
                Forms\Components\TextInput::make('short_name')
                    ->label('Nombre corto')
                    ->maxLength(12)
                    ->placeholder('EJ: LEO'),
                Forms\Components\FileUpload::make('logo')
                    ->label('Escudo')
                    ->image()
                    ->directory('teams/logos')
                    ->disk('public')
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
                    ->default(true)
                    ->visible($isAdmin),
            ])->columns(2),

            Forms\Components\Section::make('Torneo / Temporada')
                ->description('Selecciona el torneo en el que participará tu equipo')
                ->schema([
                    Forms\Components\Select::make('season_id')
                        ->label('Temporada del torneo')
                        ->options(function () {
                            return Season::with('tournament')
                                ->whereIn('status', ['registration', 'group_stage', 'knockout', 'draft'])
                                ->get()
                                ->mapWithKeys(fn (Season $s) => [$s->id => $s->tournament->name . ' - ' . $s->name]);
                        })
                        ->required()
                        ->searchable()
                        ->preload()
                        ->helperText('Elige la temporada activa del torneo al que deseas inscribirte')
                        ->afterStateHydrated(function (Forms\Components\Select $component, $record) {
                            if ($record) {
                                $seasonId = $record->seasons()->first()?->id;
                                $component->state($seasonId);
                            }
                        }),
                ])->columns(1),

            Forms\Components\Section::make('Autorización Pastoral')
                ->description('El pastor de la iglesia debe autorizar la participación del equipo.')
                ->schema([
                    Forms\Components\TextInput::make('pastor_name')
                        ->label('Nombre del pastor que autoriza')
                        ->required()
                        ->maxLength(255)
                        ->placeholder('Nombre completo del pastor')
                        ->extraInputAttributes(['style' => 'text-transform: capitalize;'])
                        ->dehydrateStateUsing(fn (?string $state) => $state ? ucwords(mb_strtolower($state)) : null),
                    Forms\Components\Toggle::make('pastor_authorization')
                        ->label('¿El pastor autoriza la participación del equipo?')
                        ->required()
                        ->accepted()
                        ->default(false)
                        ->helperText('Confirmo que el pastor de nuestra iglesia autoriza la participación de este equipo en el torneo.'),
                    Forms\Components\FileUpload::make('pastor_letter_path')
                        ->label('Carta de autorización pastoral')
                        ->helperText('Suba la carta firmada por el pastor autorizando la participación del equipo (PDF, JPG o PNG).')
                        ->directory('teams/pastor-letters')
                        ->disk('public')
                        ->acceptedFileTypes(['application/pdf', 'image/jpeg', 'image/png'])
                        ->maxSize(5120)
                        ->nullable(),
                ])->columns(1),

            Forms\Components\Section::make('Responsables')
                ->schema([
                    Forms\Components\Select::make('leader_id')
                        ->label('Líder de equipo')
                        ->relationship('leader', 'name', fn ($query) => $query->whereHas('roles', fn ($q) => $q->where('name', 'lider_equipo')))
                        ->searchable()
                        ->preload()
                        ->nullable()
                        ->helperText('Solo muestra usuarios con rol Líder de Equipo.')
                        ->visible($isAdmin),
                    Forms\Components\Select::make('captain_id')
                        ->label('Capitán')
                        ->relationship('captain', 'name')
                        ->searchable()
                        ->preload()
                        ->nullable()
                        ->visible($isAdmin),
                ])->columns(2)
                ->visible($isAdmin),

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
                    // Placeholder para líder de equipo que vea el estado
                    Forms\Components\Placeholder::make('status_display')
                        ->label('Estado de tu solicitud')
                        ->content(function ($record) {
                            if (!$record) return 'Se creará como pendiente de aprobación';
                            return match ($record->approval_status) {
                                'pending' => '⏳ Solicitud enviada - Pendiente de revisión',
                                'approved' => '✅ Equipo aprobado',
                                'rejected' => '❌ Rechazado: ' . ($record->rejection_reason ?? 'Sin motivo especificado'),
                                default => 'Pendiente',
                            };
                        })
                        ->visible(!$isAdmin),
                ])->columns(1),
        ]);
    }

    public static function table(Table $table): Table
    {
        $user = auth()->user();
        $isAdmin = $user?->hasRole('admin');

        return $table
            ->modifyQueryUsing(function (Builder $query) use ($user, $isAdmin) {
                if (!$isAdmin && $user?->hasRole('lider_equipo')) {
                    $query->where('leader_id', $user->id);
                }
            })
            ->columns([
                Tables\Columns\ImageColumn::make('logo')
                    ->label('Escudo')
                    ->disk('public')
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
                    ->label('Líder')
                    ->visible($isAdmin),
                Tables\Columns\TextColumn::make('pastor_name')
                    ->label('Pastor')
                    ->toggleable()
                    ->searchable(),
                Tables\Columns\TextColumn::make('players_count')
                    ->label('Jugadores')
                    ->counts('players'),
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
                    ->boolean()
                    ->visible($isAdmin),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('approval_status')
                    ->label('Aprobación')
                    ->options([
                        'pending' => 'Pendiente',
                        'approved' => 'Aprobado',
                        'rejected' => 'Rechazado',
                    ])
                    ->visible($isAdmin),
                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('Activo')
                    ->visible($isAdmin),
            ])
            ->actions([
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
