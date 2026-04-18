<?php

namespace App\Filament\Resources;

use App\Filament\Resources\SiteSettingResource\Pages;
use App\Models\SiteSetting;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class SiteSettingResource extends Resource
{
    protected static ?string $model = SiteSetting::class;
    protected static ?string $navigationIcon = 'heroicon-o-cog-6-tooth';
    protected static ?string $navigationGroup = 'Configuración';
    protected static ?int $navigationSort = 10;
    protected static ?string $modelLabel = 'Configuración';
    protected static ?string $pluralModelLabel = 'Configuración del Sitio';

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\Section::make()->schema([
                Forms\Components\TextInput::make('key')
                    ->label('Clave')
                    ->required()
                    ->unique(ignoreRecord: true)
                    ->disabled(fn (?SiteSetting $record) => $record !== null),
                Forms\Components\Select::make('type')
                    ->label('Tipo')
                    ->options([
                        'text' => 'Texto',
                        'image' => 'Imagen',
                        'html' => 'HTML',
                        'json' => 'JSON',
                    ])
                    ->default('text')
                    ->required()
                    ->reactive(),
                Forms\Components\Select::make('group')
                    ->label('Grupo')
                    ->options([
                        'general' => 'General',
                        'home' => 'Página de inicio',
                        'rules' => 'Reglamento',
                        'contact' => 'Contacto',
                        'social' => 'Redes sociales',
                    ])
                    ->default('general'),
                Forms\Components\Textarea::make('value')
                    ->label('Valor')
                    ->rows(3)
                    ->columnSpanFull()
                    ->visible(fn (Forms\Get $get) => in_array($get('type'), ['text', 'json', null])),
                Forms\Components\RichEditor::make('value')
                    ->label('Contenido')
                    ->columnSpanFull()
                    ->visible(fn (Forms\Get $get) => $get('type') === 'html'),
                Forms\Components\FileUpload::make('value')
                    ->label('Imagen')
                    ->image()
                    ->directory('site')
                    ->columnSpanFull()
                    ->visible(fn (Forms\Get $get) => $get('type') === 'image'),
            ])->columns(2),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('key')
                    ->label('Clave')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('type')
                    ->label('Tipo')
                    ->badge(),
                Tables\Columns\TextColumn::make('group')
                    ->label('Grupo')
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'general' => 'General',
                        'home' => 'Inicio',
                        'rules' => 'Reglamento',
                        'contact' => 'Contacto',
                        'social' => 'Redes',
                        default => $state,
                    }),
                Tables\Columns\TextColumn::make('value')
                    ->label('Valor')
                    ->limit(50)
                    ->toggleable(),
                Tables\Columns\TextColumn::make('updated_at')
                    ->label('Actualizado')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('group')
                    ->label('Grupo')
                    ->options([
                        'general' => 'General',
                        'home' => 'Inicio',
                        'rules' => 'Reglamento',
                        'contact' => 'Contacto',
                        'social' => 'Redes',
                    ]),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListSiteSettings::route('/'),
            'edit' => Pages\EditSiteSetting::route('/{record}/edit'),
        ];
    }
}
