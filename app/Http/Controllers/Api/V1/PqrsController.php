<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\StorePqrsApiRequest;
use App\Models\Pqrs;
use App\Models\PqrsAttachment;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class PqrsController extends Controller
{
    /**
     * Crea un nuevo caso de PQRS desde la app móvil. Acepta multipart/form-data
     * para soportar adjuntos. Devuelve el case_number único.
     *
     * Reusa el mismo modelo Pqrs + PqrsAttachment que el form web, así que el
     * caso queda visible en el panel administrativo igual que cualquier otro.
     */
    public function store(StorePqrsApiRequest $request)
    {
        $data = $request->validated();

        $pqrs = DB::transaction(function () use ($request, $data) {
            $pqrs = Pqrs::create([
                'type' => $data['type'],
                'subject' => $data['subject'],
                'description' => $data['description'],
                'submitter_name' => $data['submitter_name'],
                'submitter_email' => $data['submitter_email'],
                'submitter_phone' => $data['submitter_phone'] ?? null,
                'submitter_team_id' => $data['submitter_team_id'] ?? null,
                'submitter_role' => $data['submitter_role'] ?? 'otro',
            ]);

            if ($request->hasFile('attachments')) {
                foreach ($request->file('attachments') as $file) {
                    $extension = $file->getClientOriginalExtension() ?: 'bin';
                    $filename = Str::random(24).'.'.$extension;
                    $path = $file->storeAs(
                        "pqrs/{$pqrs->case_number}",
                        $filename,
                        'local',
                    );

                    PqrsAttachment::create([
                        'pqrs_id' => $pqrs->id,
                        'file_path' => $path,
                        'file_name' => $file->getClientOriginalName(),
                        'mime_type' => $file->getMimeType() ?: 'application/octet-stream',
                        'file_size' => $file->getSize(),
                    ]);
                }
            }

            return $pqrs;
        });

        return response()->json([
            'case_number' => $pqrs->case_number,
            'type' => $pqrs->type,
            'type_label' => Pqrs::typeLabels()[$pqrs->type] ?? $pqrs->type,
            'subject' => $pqrs->subject,
            'submitter_email' => $pqrs->submitter_email,
            'created_at' => $pqrs->created_at?->toIso8601String(),
        ], 201);
    }
}
