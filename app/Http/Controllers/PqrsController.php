<?php

namespace App\Http\Controllers;

use App\Http\Requests\StorePqrsRequest;
use App\Models\Pqrs;
use App\Models\PqrsAttachment;
use App\Models\SiteSetting;
use App\Models\Team;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Inertia\Inertia;

class PqrsController extends Controller
{
    public function create()
    {
        $teams = Team::where('approval_status', 'approved')
            ->orderBy('name')
            ->get(['id', 'name']);

        $settings = SiteSetting::pluck('value', 'key');

        return Inertia::render('Pqrs/Create', [
            'teams' => $teams->toArray(),
            'settings' => $settings->toArray(),
            'typeOptions' => Pqrs::typeLabels(),
            'roleOptions' => Pqrs::roleLabels(),
        ]);
    }

    public function store(StorePqrsRequest $request)
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
                'submitter_role' => $data['submitter_role'],
            ]);

            if ($request->hasFile('attachments')) {
                foreach ($request->file('attachments') as $file) {
                    $extension = $file->getClientOriginalExtension() ?: 'bin';
                    $filename = Str::random(24) . '.' . $extension;
                    $path = $file->storeAs("pqrs/{$pqrs->case_number}", $filename, 'local');

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

        return redirect()->route('pqrs.success', ['caseNumber' => $pqrs->case_number]);
    }

    public function success(string $caseNumber)
    {
        $pqrs = Pqrs::where('case_number', $caseNumber)->firstOrFail();
        $settings = SiteSetting::pluck('value', 'key');

        return Inertia::render('Pqrs/Success', [
            'caseNumber' => $pqrs->case_number,
            'type' => $pqrs->type,
            'typeLabel' => Pqrs::typeLabels()[$pqrs->type] ?? $pqrs->type,
            'subject' => $pqrs->subject,
            'submitterEmail' => $pqrs->submitter_email,
            'createdAt' => $pqrs->created_at->toIso8601String(),
            'settings' => $settings->toArray(),
        ]);
    }
}
