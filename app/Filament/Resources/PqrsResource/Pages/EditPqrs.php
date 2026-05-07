<?php

namespace App\Filament\Resources\PqrsResource\Pages;

use App\Filament\Resources\PqrsResource;
use App\Models\Pqrs;
use App\Models\PqrsResponse;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditPqrs extends EditRecord
{
    protected static string $resource = PqrsResource::class;

    protected ?string $previousStatus = null;

    protected function getHeaderActions(): array
    {
        return [
            Actions\ViewAction::make(),
            Actions\DeleteAction::make(),
        ];
    }

    protected function mutateFormDataBeforeSave(array $data): array
    {
        /** @var Pqrs $record */
        $record = $this->record;
        $this->previousStatus = $record->status;

        if (in_array($data['status'] ?? null, ['resolved', 'closed', 'rejected']) && empty($data['resolved_at'])) {
            $data['resolved_at'] = now();
        }

        return $data;
    }

    protected function afterSave(): void
    {
        /** @var Pqrs $record */
        $record = $this->record;

        if ($this->previousStatus && $this->previousStatus !== $record->status) {
            PqrsResponse::create([
                'pqrs_id' => $record->id,
                'user_id' => auth()->id(),
                'type' => 'status_change',
                'content' => sprintf(
                    'Estado cambiado de "%s" a "%s".',
                    Pqrs::statusLabels()[$this->previousStatus] ?? $this->previousStatus,
                    Pqrs::statusLabels()[$record->status] ?? $record->status
                ),
                'previous_status' => $this->previousStatus,
                'new_status' => $record->status,
                'is_visible_to_submitter' => false,
            ]);
        }
    }
}
