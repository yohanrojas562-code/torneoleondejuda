<?php

namespace App\Filament\Resources;

use App\Filament\Resources\MatchDayResource\Pages;
use App\Models\MatchDay;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class MatchDayResource extends Resource
{
    protected static ?string $model = MatchDay::class;
    protected static ?string $navigationIcon = 'heroicon-o-calendar-days';
    protected static ?string $navigationGroup = 'Partidos';
    protected static ?int $navigationSort = 6;
    protected static ?string $modelLabel = 'Jornada';
    protected static ?string $pluralModelLabel = 'Jornadas';

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
                Forms\Components\TextInput::make('name')
                    ->label('Nombre')
                    ->required()
                    ->placeholder('Jornada 1'),
                Forms\Components\TextInput::make('order')
                    ->label('Orden')
                    ->numeric()
                    ->default(0),
                Forms\Components\DatePicker::make('date')
                    ->label('Fecha'),
                Forms\Components\Select::make('type')
                    ->label('Tipo')
                    ->options([
                        'group' => 'Fase de grupos',
                        'round_of_16' => 'Octavos de final',
                        'quarter_final' => 'Cuartos de final',
                        'semi_final' => 'Semifinal',
                        'third_place' => 'Tercer puesto',
                        'final' => 'Final',
                    ])
                    ->default('group'),
            ])->columns(2),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('season.name')
                    ->label('Temporada')
                    ->sortable(),
                Tables\Columns\TextColumn::make('name')
                    ->label('Nombre')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\BadgeColumn::make('type')
                    ->label('Tipo')
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'group' => 'Grupos',
                        'round_of_16' => 'Octavos',
                        'quarter_final' => 'Cuartos',
                        'semi_final' => 'Semi',
                        'third_place' => '3er puesto',
                        'final' => 'Final',
                        default => $state,
                    })
                    ->colors([
                        'gray' => 'group',
                        'info' => 'round_of_16',
                        'warning' => fn ($state) => in_array($state, ['quarter_final', 'semi_final']),
                        'success' => fn ($state) => in_array($state, ['third_place', 'final']),
                    ]),
                Tables\Columns\TextColumn::make('date')
                    ->label('Fecha')
                    ->date('d/m/Y')
                    ->sortable(),
                Tables\Columns\TextColumn::make('matches_count')
                    ->label('Partidos')
                    ->counts('matches'),
                Tables\Columns\TextColumn::make('order')
                    ->label('Orden')
                    ->sortable(),
            ])
            ->defaultSort('order')
            ->filters([
                Tables\Filters\SelectFilter::make('season_id')
                    ->label('Temporada')
                    ->relationship('season', 'name'),
                Tables\Filters\SelectFilter::make('type')
                    ->label('Tipo')
                    ->options([
                        'group' => 'Fase de grupos',
                        'quarter_final' => 'Cuartos de final',
                        'semi_final' => 'Semifinal',
                        'final' => 'Final',
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

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListMatchDays::route('/'),
            'create' => Pages\CreateMatchDay::route('/create'),
            'edit' => Pages\EditMatchDay::route('/{record}/edit'),
        ];
    }
}
