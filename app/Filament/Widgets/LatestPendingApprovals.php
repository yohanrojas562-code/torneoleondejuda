<?php

namespace App\Filament\Widgets;

use App\Models\Player;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;

class LatestPendingApprovals extends BaseWidget
{
    protected static ?int $sort = 5;
    protected int|string|array $columnSpan = 'full';
    protected static ?string $heading = 'Últimas Solicitudes Pendientes';

    public static function canView(): bool
    {
        return auth()->user()?->hasRole('admin');
    }

    public function table(Table $table): Table
    {
        return $table
            ->query(
                Player::query()
                    ->where('approval_status', 'pending')
                    ->with('team')
                    ->latest()
                    ->limit(5)
            )
            ->columns([
                Tables\Columns\ImageColumn::make('photo')
                    ->label('Foto')
                    ->disk('public')
                    ->circular()
                    ->size(35),
                Tables\Columns\TextColumn::make('full_name')
                    ->label('Jugador')
                    ->searchable(['first_name', 'last_name']),
                Tables\Columns\TextColumn::make('team.name')
                    ->label('Equipo'),
                Tables\Columns\TextColumn::make('position')
                    ->label('Posición')
                    ->formatStateUsing(fn (?string $state): string => match ($state) {
                        'portero' => 'Portero',
                        'defensa' => 'Defensa',
                        'mediocampista' => 'Mediocampista',
                        'delantero' => 'Delantero',
                        default => $state ?? '-',
                    }),
                Tables\Columns\TextColumn::make('document_number')
                    ->label('Documento'),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Solicitud')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),
            ])
            ->actions([
                Tables\Actions\Action::make('review')
                    ->label('Revisar')
                    ->icon('heroicon-o-eye')
                    ->url(fn (Player $record) => route('filament.admin.resources.players.edit', $record)),
            ])
            ->paginated(false);
    }
}
