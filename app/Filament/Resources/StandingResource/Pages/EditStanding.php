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
     * Cuando el admin cambia un valor de la tabla manualmente, registramos
     * el DELTA en la columna `manual_*` correspondiente. Esto permite que
     * el ajuste persista a través de los recálculos: aunque entren nuevos
     * partidos, el offset manual se acumula encima.
     *
     * Lógica:
     *   delta              = valor_nuevo - valor_antes_de_guardar
     *   manual_offset_new  = manual_offset_actual + delta
     *
     * Ejemplo: admin ve PTS=3 (live=3, manual=0). Cambia a 6.
     *   delta = 6 - 3 = 3 → manual_points = 0 + 3 = 3
     * Próximo recálculo con partido ganado nuevo: live=6 + manual=3 → 9.
     */
    protected function mutateFormDataBeforeSave(array $data): array
    {
        /** @var Standing $current */
        $current = $this->record;

        $fields = [
            'played', 'won', 'drawn', 'lost',
            'goals_for', 'goals_against', 'points',
            'yellow_cards', 'blue_cards', 'red_cards',
        ];

        foreach ($fields as $field) {
            if (! array_key_exists($field, $data)) {
                continue;
            }
            $manualColumn = 'manual_'.$field;
            $oldValue = (int) ($current->{$field} ?? 0);
            $newValue = (int) ($data[$field] ?? 0);
            $oldManual = (int) ($current->{$manualColumn} ?? 0);

            // Solo ajusta si cambió el valor — evita tocar el offset cuando
            // el admin guarda sin cambiar nada (form unchanged save).
            if ($newValue !== $oldValue) {
                $delta = $newValue - $oldValue;
                $data[$manualColumn] = $oldManual + $delta;
            }
        }

        return $data;
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
