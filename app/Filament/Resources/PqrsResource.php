<?php

namespace App\Filament\Resources;

use App\Filament\Resources\PqrsResource\Pages;
use App\Filament\Resources\PqrsResource\RelationManagers;
use App\Models\Pqrs;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Infolists;
use Filament\Infolists\Infolist;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class PqrsResource extends Resource
{
    protected static ?string $model = Pqrs::class;
    protected static ?string $slug = 'pqrs';
    protected static ?string $navigationIcon = 'heroicon-o-chat-bubble-left-right';
    protected static ?string $navigationGroup = 'PQRS';
    protected static ?string $navigationLabel = 'Casos PQRS';
    protected static ?string $modelLabel = 'PQRS';
    protected static ?string $pluralModelLabel = 'PQRS';
    protected static ?string $recordTitleAttribute = 'case_number';

    public static function canAccess(): bool
    {
        return auth()->user()?->hasRole('admin') ?? false;
    }

    public static function getNavigationBadge(): ?string
    {
        return (string) static::getModel()::whereIn('status', ['received', 'in_review'])->count();
    }

    public static function getNavigationBadgeColor(): ?string
    {
        return 'warning';
    }

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\Section::make('Gestión del caso')
                ->description('Datos administrativos editables')
                ->columns(2)
                ->schema([
                    Forms\Components\Select::make('status')
                        ->label('Estado')
                        ->options(Pqrs::statusLabels())
                        ->required()
                        ->live(),
                    Forms\Components\Select::make('priority')
                        ->label('Prioridad')
                        ->options(Pqrs::priorityLabels())
                        ->required(),
                    Forms\Components\Select::make('assigned_to')
                        ->label('Asignado a')
                        ->relationship('assignee', 'name')
                        ->searchable()
                        ->preload()
                        ->nullable(),
                    Forms\Components\DateTimePicker::make('resolved_at')
                        ->label('Resuelto el')
                        ->nullable()
                        ->visible(fn (Forms\Get $get) => in_array($get('status'), ['resolved', 'closed', 'rejected'])),
                ]),

            Forms\Components\Section::make('Resolución y notas internas')
                ->collapsible()
                ->schema([
                    Forms\Components\Textarea::make('resolution')
                        ->label('Resolución (visible al cierre del caso)')
                        ->rows(4)
                        ->maxLength(5000),
                    Forms\Components\Textarea::make('internal_notes')
                        ->label('Notas internas (solo administradores)')
                        ->rows(4)
                        ->maxLength(5000),
                ]),
        ]);
    }

    public static function infolist(Infolist $infolist): Infolist
    {
        return $infolist->schema([
            Infolists\Components\Section::make('Caso')
                ->columns(3)
                ->schema([
                    Infolists\Components\TextEntry::make('case_number')
                        ->label('Número de caso')
                        ->copyable()
                        ->weight('bold')
                        ->color('warning'),
                    Infolists\Components\TextEntry::make('type')
                        ->label('Tipo')
                        ->formatStateUsing(fn ($state) => Pqrs::typeLabels()[$state] ?? $state)
                        ->badge(),
                    Infolists\Components\TextEntry::make('status')
                        ->label('Estado actual')
                        ->formatStateUsing(fn ($state) => Pqrs::statusLabels()[$state] ?? $state)
                        ->badge()
                        ->color(fn (string $state) => match ($state) {
                            'received' => 'gray',
                            'in_review' => 'info',
                            'in_progress' => 'warning',
                            'awaiting_response' => 'warning',
                            'resolved' => 'success',
                            'closed' => 'success',
                            'rejected' => 'danger',
                            default => 'gray',
                        }),
                    Infolists\Components\TextEntry::make('priority')
                        ->label('Prioridad')
                        ->formatStateUsing(fn ($state) => Pqrs::priorityLabels()[$state] ?? $state)
                        ->badge()
                        ->color(fn (string $state) => match ($state) {
                            'low' => 'gray',
                            'medium' => 'info',
                            'high' => 'warning',
                            'urgent' => 'danger',
                            default => 'gray',
                        }),
                    Infolists\Components\TextEntry::make('assignee.name')
                        ->label('Asignado a')
                        ->placeholder('Sin asignar'),
                    Infolists\Components\TextEntry::make('created_at')
                        ->label('Recibido el')
                        ->dateTime('d M Y H:i'),
                ]),

            Infolists\Components\Section::make('Solicitante')
                ->columns(2)
                ->schema([
                    Infolists\Components\TextEntry::make('submitter_name')->label('Nombre'),
                    Infolists\Components\TextEntry::make('submitter_email')
                        ->label('Email')
                        ->copyable()
                        ->icon('heroicon-m-envelope'),
                    Infolists\Components\TextEntry::make('submitter_phone')
                        ->label('Teléfono')
                        ->placeholder('No proporcionado')
                        ->copyable()
                        ->icon('heroicon-m-phone'),
                    Infolists\Components\TextEntry::make('submitter_role')
                        ->label('Rol')
                        ->formatStateUsing(fn ($state) => Pqrs::roleLabels()[$state] ?? $state),
                    Infolists\Components\TextEntry::make('team.name')
                        ->label('Equipo')
                        ->placeholder('No aplica'),
                ]),

            Infolists\Components\Section::make('Detalle de la solicitud')
                ->schema([
                    Infolists\Components\TextEntry::make('subject')
                        ->label('Asunto')
                        ->weight('bold')
                        ->size('lg'),
                    Infolists\Components\TextEntry::make('description')
                        ->label('Descripción')
                        ->markdown()
                        ->columnSpanFull(),
                ]),

            Infolists\Components\Section::make('Resolución')
                ->visible(fn ($record) => filled($record->resolution) || filled($record->resolved_at))
                ->schema([
                    Infolists\Components\TextEntry::make('resolution')
                        ->label('Resolución')
                        ->placeholder('Sin resolución registrada'),
                    Infolists\Components\TextEntry::make('resolved_at')
                        ->label('Fecha de resolución')
                        ->dateTime('d M Y H:i'),
                ]),

            Infolists\Components\Section::make('Notas internas')
                ->visible(fn ($record) => filled($record->internal_notes))
                ->schema([
                    Infolists\Components\TextEntry::make('internal_notes')
                        ->label('')
                        ->markdown(),
                ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('case_number')
                    ->label('Caso')
                    ->searchable()
                    ->sortable()
                    ->copyable()
                    ->weight('bold')
                    ->color('warning'),
                Tables\Columns\TextColumn::make('type')
                    ->label('Tipo')
                    ->formatStateUsing(fn ($state) => Pqrs::typeLabels()[$state] ?? $state)
                    ->badge()
                    ->color(fn (string $state) => match ($state) {
                        'queja' => 'danger',
                        'reclamo' => 'danger',
                        'apelacion' => 'warning',
                        'peticion' => 'info',
                        'sugerencia' => 'gray',
                        'felicitacion' => 'success',
                        default => 'gray',
                    }),
                Tables\Columns\TextColumn::make('subject')
                    ->label('Asunto')
                    ->searchable()
                    ->limit(40),
                Tables\Columns\TextColumn::make('submitter_name')
                    ->label('Solicitante')
                    ->searchable()
                    ->limit(25),
                Tables\Columns\TextColumn::make('team.name')
                    ->label('Equipo')
                    ->limit(20)
                    ->placeholder('—'),
                Tables\Columns\TextColumn::make('status')
                    ->label('Estado')
                    ->formatStateUsing(fn ($state) => Pqrs::statusLabels()[$state] ?? $state)
                    ->badge()
                    ->color(fn (string $state) => match ($state) {
                        'received' => 'gray',
                        'in_review' => 'info',
                        'in_progress' => 'warning',
                        'awaiting_response' => 'warning',
                        'resolved' => 'success',
                        'closed' => 'success',
                        'rejected' => 'danger',
                        default => 'gray',
                    })
                    ->sortable(),
                Tables\Columns\TextColumn::make('priority')
                    ->label('Prioridad')
                    ->formatStateUsing(fn ($state) => Pqrs::priorityLabels()[$state] ?? $state)
                    ->badge()
                    ->color(fn (string $state) => match ($state) {
                        'low' => 'gray',
                        'medium' => 'info',
                        'high' => 'warning',
                        'urgent' => 'danger',
                        default => 'gray',
                    })
                    ->sortable(),
                Tables\Columns\TextColumn::make('assignee.name')
                    ->label('Asignado')
                    ->placeholder('—')
                    ->toggleable(),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Recibido')
                    ->dateTime('d M Y H:i')
                    ->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->label('Estado')
                    ->options(Pqrs::statusLabels()),
                Tables\Filters\SelectFilter::make('type')
                    ->label('Tipo')
                    ->options(Pqrs::typeLabels()),
                Tables\Filters\SelectFilter::make('priority')
                    ->label('Prioridad')
                    ->options(Pqrs::priorityLabels()),
                Tables\Filters\SelectFilter::make('assigned_to')
                    ->label('Asignado a')
                    ->relationship('assignee', 'name'),
                Tables\Filters\TrashedFilter::make(),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                    Tables\Actions\RestoreBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            RelationManagers\ResponsesRelationManager::class,
            RelationManagers\AttachmentsRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListPqrs::route('/'),
            'view' => Pages\ViewPqrs::route('/{record}'),
            'edit' => Pages\EditPqrs::route('/{record}/edit'),
        ];
    }

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()
            ->withoutGlobalScopes([SoftDeletingScope::class]);
    }
}
