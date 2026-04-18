<?php

namespace App\Filament\Widgets;

use App\Models\Team;
use App\Models\Player;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;

class LeaderPlayersTable extends BaseWidget
{
    protected static ?int $sort = 2;
    protected int|string|array $columnSpan = 'full';
    protected static ?string $heading = 'Mis Jugadores';

    public static function canView(): bool
    {
        return auth()->user()?->hasRole('lider_equipo');
    }

    public function table(Table $table): Table
    {
        $team = Team::where('leader_id', auth()->id())->first();

        return $table
            ->query(
                Player::query()
                    ->where('team_id', $team?->id ?? 0)
                    ->orderBy('jersey_number')
            )
            ->columns([
                Tables\Columns\ImageColumn::make('photo')
                    ->label('Foto')
                    ->disk('public')
                    ->circular()
                    ->size(35),
                Tables\Columns\TextColumn::make('jersey_number')
                    ->label('#')
                    ->sortable()
                    ->alignCenter(),
                Tables\Columns\TextColumn::make('full_name')
                    ->label('Nombre')
                    ->searchable(['first_name', 'last_name']),
                Tables\Columns\TextColumn::make('position')
                    ->label('Posición')
                    ->formatStateUsing(fn (?string $state): string => match ($state) {
                        'portero' => 'Portero',
                        'defensa' => 'Defensa',
                        'mediocampista' => 'Mediocampista',
                        'delantero' => 'Delantero',
                        default => $state ?? '-',
                    }),
                Tables\Columns\IconColumn::make('is_captain')
                    ->label('Cap.')
                    ->boolean()
                    ->trueIcon('heroicon-o-star')
                    ->falseIcon('heroicon-o-minus'),
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
                        default => $state ?? '-',
                    }),
            ])
            ->paginated(false)
            ->emptyStateHeading('Sin jugadores inscritos')
            ->emptyStateDescription('Ve al menú Jugadores para inscribir a tus jugadores.')
            ->emptyStateIcon('heroicon-o-user-group');
    }
}
