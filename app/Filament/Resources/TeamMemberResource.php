<?php

namespace App\Filament\Resources;

use App\Filament\Resources\TeamMemberResource\Pages;
use App\Models\TeamMember;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class TeamMemberResource extends Resource
{
    protected static ?string $model = TeamMember::class;
    protected static ?string $navigationIcon = 'heroicon-o-users';
    protected static ?string $navigationGroup = 'Organigrama';
    protected static ?string $navigationLabel = 'Miembros del equipo';
    protected static ?string $modelLabel = 'Miembro del equipo';
    protected static ?string $pluralModelLabel = 'Miembros del equipo';
    protected static ?string $recordTitleAttribute = 'name';

    public static function canAccess(): bool
    {
        return auth()->user()?->hasRole('admin') ?? false;
    }

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\Section::make('Información del miembro')
                ->columns(2)
                ->schema([
                    Forms\Components\TextInput::make('name')
                        ->label('Nombre completo')
                        ->required()
                        ->maxLength(150),

                    Forms\Components\Select::make('roles')
                        ->label('Roles')
                        ->multiple()
                        ->options(TeamMember::roleLabels())
                        ->required()
                        ->searchable()
                        ->helperText('Puedes seleccionar uno o más roles.'),

                    Forms\Components\Textarea::make('description')
                        ->label('Descripción breve')
                        ->rows(3)
                        ->maxLength(500)
                        ->columnSpanFull()
                        ->helperText('Una breve descripción que aparecerá en su tarjeta del organigrama.'),

                    Forms\Components\FileUpload::make('photo')
                        ->label('Foto')
                        ->image()
                        ->disk('public')
                        ->directory('team-members')
                        ->imageEditor()
                        ->imageEditorAspectRatios(['1:1'])
                        ->maxSize(2048)
                        ->columnSpanFull(),
                ]),

            Forms\Components\Section::make('Visualización')
                ->columns(2)
                ->schema([
                    Forms\Components\TextInput::make('order')
                        ->label('Orden')
                        ->numeric()
                        ->default(0)
                        ->helperText('Menor número = aparece primero en su nivel.'),

                    Forms\Components\Toggle::make('is_active')
                        ->label('Activo')
                        ->default(true)
                        ->helperText('Solo se muestran los miembros activos en la página pública.'),
                ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('photo')
                    ->label('Foto')
                    ->disk('public')
                    ->circular()
                    ->size(48)
                    ->defaultImageUrl(fn ($record) => null),

                Tables\Columns\TextColumn::make('name')
                    ->label('Nombre')
                    ->searchable()
                    ->sortable()
                    ->weight('bold'),

                Tables\Columns\TextColumn::make('roles')
                    ->label('Roles')
                    ->badge()
                    ->separator(',')
                    ->formatStateUsing(fn ($state) => TeamMember::roleLabels()[$state] ?? $state)
                    ->color('warning'),

                Tables\Columns\TextColumn::make('description')
                    ->label('Descripción')
                    ->limit(50)
                    ->placeholder('—')
                    ->toggleable(),

                Tables\Columns\TextColumn::make('order')
                    ->label('Orden')
                    ->sortable()
                    ->alignCenter(),

                Tables\Columns\IconColumn::make('is_active')
                    ->label('Activo')
                    ->boolean()
                    ->sortable(),
            ])
            ->defaultSort('order')
            ->filters([
                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('Activos'),
                Tables\Filters\SelectFilter::make('roles')
                    ->label('Rol')
                    ->options(TeamMember::roleLabels())
                    ->query(function ($query, array $data) {
                        if (!empty($data['value'])) {
                            $query->whereJsonContains('roles', $data['value']);
                        }
                    }),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ])
            ->reorderable('order');
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListTeamMembers::route('/'),
            'create' => Pages\CreateTeamMember::route('/create'),
            'edit' => Pages\EditTeamMember::route('/{record}/edit'),
        ];
    }
}
