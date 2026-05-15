<?php

namespace App\Filament\Resources\StandingResource\Pages;

use App\Filament\Resources\StandingResource;
use App\Models\Standing;
use Filament\Actions;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\EditRecord;

class EditStanding extends EditRecord
{
    protected static string $resource = StandingResource::class;

    protected function getHeaderActions(): array
    {
        return [Actions\DeleteAction::make()];
    }

    /**
     * Tras guardar manualmente un Standing, reordena las posiciones del grupo
     * con la misma logica que StandingsService::recalculateForSeason:
     *   PTS desc -> DG desc -> FairPlay desc -> GF desc -> GC asc -> PP asc
     * NO toca ningun otro campo (PTS, PJ, GF, etc. quedan tal como el admin
     * los guardo). Solo actualiza la columna 'position'.
     */
    protected function afterSave(): void
    {
        /** @var Standing $current */
        $current = $this->record;

        $query = Standing::query()
            ->where('season_id', $current->season_id);

        if ($current->group_id === null) {
            $query->whereNull('group_id');
        } else {
            $query->where('group_id', $current->group_id);
        }

        $standings = $query
            ->orderByDesc('points')
            ->orderByDesc('goal_difference')
            ->orderByDesc('fair_play_points')
            ->orderByDesc('goals_for')
            ->orderBy('goals_against')
            ->orderBy('lost')
            ->get();

        $changed = 0;
        foreach ($standings as $index => $s) {
            $newPosition = $index + 1;
            if ((int) $s->position !== $newPosition) {
                $s->update(['position' => $newPosition]);
                $changed++;
            }
        }

        if ($changed > 0) {
            Notification::make()
                ->title('Posiciones reordenadas')
                ->body("Se actualizaron {$changed} posiciones del grupo segun los nuevos valores.")
                ->success()
                ->send();
        }
    }
}
