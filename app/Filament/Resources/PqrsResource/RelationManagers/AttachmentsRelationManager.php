<?php

namespace App\Filament\Resources\PqrsResource\RelationManagers;

use App\Models\Pqrs;
use App\Models\PqrsAttachment;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class AttachmentsRelationManager extends RelationManager
{
    protected static string $relationship = 'allAttachments';

    protected static ?string $title = 'Archivos y evidencias';

    protected static ?string $modelLabel = 'archivo';

    protected static ?string $pluralModelLabel = 'archivos';

    public function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\FileUpload::make('file_path')
                ->label('Archivo')
                ->disk('local')
                ->directory(fn () => 'pqrs/' . ($this->getOwnerRecord()->case_number ?? 'admin') . '/admin')
                ->preserveFilenames()
                ->acceptedFileTypes([
                    'image/jpeg', 'image/png', 'image/gif', 'image/webp',
                    'video/mp4', 'video/quicktime', 'video/webm',
                    'application/pdf',
                ])
                ->maxSize(25 * 1024)
                ->required(),
        ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('file_name')
            ->columns([
                Tables\Columns\IconColumn::make('mime_type')
                    ->label('')
                    ->icon(fn ($state) => match (true) {
                        str_starts_with((string) $state, 'image/') => 'heroicon-o-photo',
                        str_starts_with((string) $state, 'video/') => 'heroicon-o-film',
                        $state === 'application/pdf' => 'heroicon-o-document-text',
                        default => 'heroicon-o-document',
                    })
                    ->color('warning'),
                Tables\Columns\TextColumn::make('file_name')
                    ->label('Nombre')
                    ->searchable()
                    ->limit(40),
                Tables\Columns\TextColumn::make('mime_type')
                    ->label('Tipo')
                    ->badge()
                    ->color('gray'),
                Tables\Columns\TextColumn::make('file_size')
                    ->label('Tamaño')
                    ->formatStateUsing(function ($state) {
                        if ($state >= 1048576) return number_format($state / 1048576, 2) . ' MB';
                        if ($state >= 1024) return number_format($state / 1024, 2) . ' KB';
                        return $state . ' B';
                    }),
                Tables\Columns\TextColumn::make('response_id')
                    ->label('Origen')
                    ->formatStateUsing(fn ($state) => $state ? 'Respuesta admin' : 'Solicitud inicial')
                    ->badge()
                    ->color(fn ($state) => $state ? 'info' : 'success'),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Subido')
                    ->dateTime('d M Y H:i')
                    ->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->headerActions([
                Tables\Actions\CreateAction::make()
                    ->label('Subir archivo')
                    ->using(function (array $data): PqrsAttachment {
                        /** @var Pqrs $owner */
                        $owner = $this->getOwnerRecord();
                        $path = $data['file_path'];
                        $absolutePath = Storage::disk('local')->path($path);
                        $size = file_exists($absolutePath) ? filesize($absolutePath) : 0;
                        $mime = file_exists($absolutePath) ? (mime_content_type($absolutePath) ?: 'application/octet-stream') : 'application/octet-stream';

                        return PqrsAttachment::create([
                            'pqrs_id' => $owner->id,
                            'response_id' => null,
                            'file_path' => $path,
                            'file_name' => basename($path),
                            'mime_type' => $mime,
                            'file_size' => $size,
                        ]);
                    }),
            ])
            ->actions([
                Tables\Actions\Action::make('download')
                    ->label('Descargar')
                    ->icon('heroicon-o-arrow-down-tray')
                    ->action(function (PqrsAttachment $record) {
                        if (Storage::disk('local')->exists($record->file_path)) {
                            return Storage::disk('local')->download($record->file_path, $record->file_name);
                        }
                    }),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }
}
