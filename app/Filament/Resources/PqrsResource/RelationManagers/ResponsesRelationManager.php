<?php

namespace App\Filament\Resources\PqrsResource\RelationManagers;

use App\Models\Pqrs;
use App\Models\PqrsResponse;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Model;

class ResponsesRelationManager extends RelationManager
{
    protected static string $relationship = 'responses';

    protected static ?string $title = 'Gestiones y respuestas';

    protected static ?string $modelLabel = 'gestión';

    protected static ?string $pluralModelLabel = 'gestiones';

    public function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\Select::make('type')
                ->label('Tipo')
                ->options(PqrsResponse::typeLabels())
                ->required()
                ->default('note')
                ->live(),

            Forms\Components\Select::make('new_status')
                ->label('Cambiar estado a')
                ->options(Pqrs::statusLabels())
                ->visible(fn (Forms\Get $get) => $get('type') === 'status_change')
                ->requiredIf('type', 'status_change'),

            Forms\Components\Textarea::make('content')
                ->label('Contenido')
                ->required()
                ->rows(5)
                ->maxLength(5000),

            Forms\Components\Toggle::make('is_visible_to_submitter')
                ->label('Visible al solicitante')
                ->helperText('Si lo marcas, esta gestión se considera una respuesta oficial al solicitante.')
                ->default(false),
        ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('content')
            ->columns([
                Tables\Columns\TextColumn::make('type')
                    ->label('Tipo')
                    ->formatStateUsing(fn ($state) => PqrsResponse::typeLabels()[$state] ?? $state)
                    ->badge()
                    ->color(fn (string $state) => match ($state) {
                        'note' => 'gray',
                        'status_change' => 'info',
                        'public_response' => 'success',
                        'action_taken' => 'warning',
                        'assignment' => 'info',
                        default => 'gray',
                    }),
                Tables\Columns\TextColumn::make('content')
                    ->label('Contenido')
                    ->limit(80)
                    ->wrap(),
                Tables\Columns\IconColumn::make('is_visible_to_submitter')
                    ->label('Pública')
                    ->boolean(),
                Tables\Columns\TextColumn::make('user.name')
                    ->label('Por')
                    ->placeholder('Sistema'),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Fecha')
                    ->dateTime('d M Y H:i')
                    ->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->headerActions([
                Tables\Actions\CreateAction::make()
                    ->label('Nueva gestión')
                    ->mutateFormDataUsing(function (array $data): array {
                        $data['user_id'] = auth()->id();

                        if (($data['type'] ?? null) === 'status_change' && !empty($data['new_status'])) {
                            /** @var Pqrs $owner */
                            $owner = $this->getOwnerRecord();
                            $data['previous_status'] = $owner->status;
                            $owner->update([
                                'status' => $data['new_status'],
                                'resolved_at' => in_array($data['new_status'], ['resolved', 'closed', 'rejected'])
                                    ? ($owner->resolved_at ?? now())
                                    : null,
                            ]);
                        }

                        return $data;
                    }),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public function isReadOnly(): bool
    {
        return false;
    }
}
