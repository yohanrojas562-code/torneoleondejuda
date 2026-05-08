<?php

namespace App\Filament\Resources;

use App\Filament\Resources\SponsorResource\Pages;
use App\Models\Sponsor;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class SponsorResource extends Resource
{
    protected static ?string $model = Sponsor::class;
    protected static ?string $navigationIcon = 'heroicon-o-star';
    protected static ?string $navigationGroup = 'Patrocinadores';
    protected static ?string $navigationLabel = 'Patrocinadores';
    protected static ?string $modelLabel = 'patrocinador';
    protected static ?string $pluralModelLabel = 'patrocinadores';
    protected static ?string $recordTitleAttribute = 'name';

    public static function canAccess(): bool
    {
        return auth()->user()?->hasRole('admin') ?? false;
    }

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\Section::make('Información')
                ->columns(2)
                ->schema([
                    Forms\Components\TextInput::make('name')
                        ->label('Nombre')
                        ->required()
                        ->maxLength(150),

                    Forms\Components\Select::make('type')
                        ->label('Tipo')
                        ->options(Sponsor::typeLabels())
                        ->required()
                        ->default('patrocinio')
                        ->helperText('Patrocinador (oficial), Aliado (alianza estratégica) o Apoyo (colaboración).'),

                    Forms\Components\Textarea::make('description')
                        ->label('Descripción')
                        ->rows(3)
                        ->maxLength(500)
                        ->columnSpanFull(),

                    Forms\Components\FileUpload::make('logo')
                        ->label('Logo')
                        ->image()
                        ->disk('public')
                        ->directory('sponsors')
                        ->maxSize(2048)
                        ->columnSpanFull()
                        ->helperText('Imagen del logo (PNG, JPG, WEBP o SVG). Recomendado fondo transparente.'),

                    Forms\Components\TextInput::make('website')
                        ->label('Sitio web')
                        ->url()
                        ->prefix('https://')
                        ->maxLength(255)
                        ->columnSpanFull(),
                ]),

            Forms\Components\Section::make('Redes sociales')
                ->collapsible()
                ->collapsed()
                ->columns(2)
                ->schema([
                    Forms\Components\TextInput::make('social_links.facebook')
                        ->label('Facebook')
                        ->url()
                        ->prefixIcon('heroicon-o-link')
                        ->placeholder('https://facebook.com/...'),
                    Forms\Components\TextInput::make('social_links.instagram')
                        ->label('Instagram')
                        ->url()
                        ->prefixIcon('heroicon-o-link')
                        ->placeholder('https://instagram.com/...'),
                    Forms\Components\TextInput::make('social_links.twitter')
                        ->label('Twitter / X')
                        ->url()
                        ->prefixIcon('heroicon-o-link')
                        ->placeholder('https://x.com/...'),
                    Forms\Components\TextInput::make('social_links.tiktok')
                        ->label('TikTok')
                        ->url()
                        ->prefixIcon('heroicon-o-link')
                        ->placeholder('https://tiktok.com/@...'),
                    Forms\Components\TextInput::make('social_links.youtube')
                        ->label('YouTube')
                        ->url()
                        ->prefixIcon('heroicon-o-link')
                        ->placeholder('https://youtube.com/@...'),
                    Forms\Components\TextInput::make('social_links.linkedin')
                        ->label('LinkedIn')
                        ->url()
                        ->prefixIcon('heroicon-o-link')
                        ->placeholder('https://linkedin.com/...'),
                    Forms\Components\TextInput::make('social_links.whatsapp')
                        ->label('WhatsApp')
                        ->url()
                        ->prefixIcon('heroicon-o-link')
                        ->placeholder('https://wa.me/57...')
                        ->columnSpanFull(),
                ]),

            Forms\Components\Section::make('Visualización')
                ->columns(2)
                ->schema([
                    Forms\Components\TextInput::make('order')
                        ->label('Orden')
                        ->numeric()
                        ->default(0)
                        ->helperText('Menor número = aparece primero dentro de su tipo.'),

                    Forms\Components\Toggle::make('is_active')
                        ->label('Activo')
                        ->default(true)
                        ->helperText('Solo se muestran los patrocinadores activos en la página pública.'),
                ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('logo')
                    ->label('Logo')
                    ->disk('public')
                    ->size(60)
                    ->defaultImageUrl(fn ($record) => null),

                Tables\Columns\TextColumn::make('name')
                    ->label('Nombre')
                    ->searchable()
                    ->sortable()
                    ->weight('bold'),

                Tables\Columns\TextColumn::make('type')
                    ->label('Tipo')
                    ->formatStateUsing(fn ($state) => Sponsor::typeLabels()[$state] ?? $state)
                    ->badge()
                    ->color(fn (string $state) => match ($state) {
                        'patrocinio' => 'warning',
                        'alianza' => 'info',
                        'apoyo' => 'gray',
                        default => 'gray',
                    })
                    ->sortable(),

                Tables\Columns\TextColumn::make('website')
                    ->label('Sitio web')
                    ->url(fn ($state) => $state, true)
                    ->limit(30)
                    ->placeholder('—')
                    ->color('warning'),

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
                Tables\Filters\SelectFilter::make('type')
                    ->label('Tipo')
                    ->options(Sponsor::typeLabels()),
                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('Activos'),
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
            'index' => Pages\ListSponsors::route('/'),
            'create' => Pages\CreateSponsor::route('/create'),
            'edit' => Pages\EditSponsor::route('/{record}/edit'),
        ];
    }
}
