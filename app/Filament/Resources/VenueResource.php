<?php

namespace App\Filament\Resources;

use App\Filament\Resources\VenueResource\Pages;
use App\Models\Venue;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class VenueResource extends Resource
{
    protected static ?string $model = Venue::class;
    protected static ?string $navigationIcon = 'heroicon-o-map-pin';
    protected static ?string $navigationGroup = 'Configuración';
    protected static ?int $navigationSort = 2;
    protected static ?string $modelLabel = 'Escenario';
    protected static ?string $pluralModelLabel = 'Escenarios';

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\Section::make('Información del Escenario')->schema([
                Forms\Components\TextInput::make('name')
                    ->label('Nombre del escenario')
                    ->required()
                    ->maxLength(255)
                    ->placeholder('Ej: Cancha Sintética La Salle'),
                Forms\Components\TextInput::make('address')
                    ->label('Dirección')
                    ->maxLength(255)
                    ->placeholder('Ej: Cra 50 #30-20, Medellín'),
                Forms\Components\TextInput::make('city')
                    ->label('Ciudad')
                    ->maxLength(255)
                    ->placeholder('Ej: Medellín'),
                Forms\Components\Select::make('surface_type')
                    ->label('Tipo de superficie')
                    ->options([
                        'sintetica' => 'Sintética',
                        'natural' => 'Césped natural',
                        'cemento' => 'Cemento',
                        'tierra' => 'Tierra',
                        'mixta' => 'Mixta',
                    ])
                    ->placeholder('Selecciona el tipo'),
                Forms\Components\TextInput::make('capacity')
                    ->label('Capacidad (espectadores)')
                    ->numeric()
                    ->minValue(0)
                    ->placeholder('Ej: 500'),
                Forms\Components\Toggle::make('is_active')
                    ->label('Activo')
                    ->default(true),
            ])->columns(2),

            Forms\Components\Section::make('Imagen')->schema([
                Forms\Components\FileUpload::make('image')
                    ->label('Foto del escenario')
                    ->image()
                    ->imageResizeMode('cover')
                    ->imageCropAspectRatio('16:9')
                    ->imageResizeTargetWidth('1200')
                    ->imageResizeTargetHeight('675')
                    ->directory('venues')
                    ->disk('public')
                    ->maxSize(5120)
                    ->columnSpanFull(),
            ]),

            Forms\Components\Section::make('Ubicación en Google Maps')->schema([
                Forms\Components\Textarea::make('google_maps_embed')
                    ->label('Código de incrustación de Google Maps')
                    ->helperText('Pega aquí el código <iframe> de Google Maps. Ve a Google Maps → Compartir → Insertar un mapa → Copia el HTML.')
                    ->rows(4)
                    ->placeholder('<iframe src="https://www.google.com/maps/embed?pb=..." ...></iframe>')
                    ->columnSpanFull(),
                Forms\Components\TextInput::make('latitude')
                    ->label('Latitud')
                    ->numeric()
                    ->placeholder('Ej: 6.2518400'),
                Forms\Components\TextInput::make('longitude')
                    ->label('Longitud')
                    ->numeric()
                    ->placeholder('Ej: -75.5635900'),
            ])->columns(2),

            Forms\Components\Section::make('Descripción')->schema([
                Forms\Components\Textarea::make('description')
                    ->label('Descripción adicional')
                    ->rows(3)
                    ->placeholder('Información adicional sobre el escenario, acceso, parqueadero, etc.')
                    ->columnSpanFull(),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('image')
                    ->label('Foto')
                    ->disk('public')
                    ->circular()
                    ->defaultImageUrl(url('/images/placeholder.png')),
                Tables\Columns\TextColumn::make('name')
                    ->label('Nombre')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('address')
                    ->label('Dirección')
                    ->searchable()
                    ->limit(40)
                    ->toggleable(),
                Tables\Columns\TextColumn::make('city')
                    ->label('Ciudad')
                    ->sortable()
                    ->toggleable(),
                Tables\Columns\TextColumn::make('surface_type')
                    ->label('Superficie')
                    ->formatStateUsing(fn (?string $state): string => match ($state) {
                        'sintetica' => 'Sintética',
                        'natural' => 'Césped natural',
                        'cemento' => 'Cemento',
                        'tierra' => 'Tierra',
                        'mixta' => 'Mixta',
                        default => $state ?? '-',
                    })
                    ->toggleable(),
                Tables\Columns\TextColumn::make('capacity')
                    ->label('Capacidad')
                    ->numeric()
                    ->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\IconColumn::make('is_active')
                    ->label('Activo')
                    ->boolean(),
                Tables\Columns\TextColumn::make('matches_count')
                    ->label('Partidos')
                    ->counts('matches')
                    ->sortable(),
            ])
            ->defaultSort('name')
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
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListVenues::route('/'),
            'create' => Pages\CreateVenue::route('/create'),
            'edit' => Pages\EditVenue::route('/{record}/edit'),
        ];
    }
}
