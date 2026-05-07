<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Pqrs extends Model
{
    use HasFactory, SoftDeletes;

    protected $table = 'pqrs';

    protected $fillable = [
        'case_number',
        'type',
        'subject',
        'description',
        'submitter_name',
        'submitter_email',
        'submitter_phone',
        'submitter_team_id',
        'submitter_role',
        'status',
        'priority',
        'assigned_to',
        'internal_notes',
        'resolution',
        'resolved_at',
    ];

    protected $casts = [
        'resolved_at' => 'datetime',
    ];

    protected static function booted(): void
    {
        static::creating(function (Pqrs $pqrs) {
            if (empty($pqrs->case_number)) {
                $year = now()->year;
                $sequence = static::whereYear('created_at', $year)->withTrashed()->count() + 1;
                $pqrs->case_number = sprintf('PQRS-%d-%04d', $year, $sequence);
            }
        });
    }

    public function team(): BelongsTo
    {
        return $this->belongsTo(Team::class, 'submitter_team_id');
    }

    public function assignee(): BelongsTo
    {
        return $this->belongsTo(User::class, 'assigned_to');
    }

    public function responses(): HasMany
    {
        return $this->hasMany(PqrsResponse::class)->orderBy('created_at');
    }

    public function attachments(): HasMany
    {
        return $this->hasMany(PqrsAttachment::class)->whereNull('response_id');
    }

    public function allAttachments(): HasMany
    {
        return $this->hasMany(PqrsAttachment::class);
    }

    public static function typeLabels(): array
    {
        return [
            'peticion' => 'Petición',
            'queja' => 'Queja',
            'reclamo' => 'Reclamo',
            'sugerencia' => 'Sugerencia',
            'apelacion' => 'Apelación',
            'felicitacion' => 'Felicitación',
        ];
    }

    public static function statusLabels(): array
    {
        return [
            'received' => 'Recibido',
            'in_review' => 'En revisión',
            'in_progress' => 'En gestión',
            'awaiting_response' => 'Esperando respuesta',
            'resolved' => 'Resuelto',
            'closed' => 'Cerrado',
            'rejected' => 'Rechazado',
        ];
    }

    public static function priorityLabels(): array
    {
        return [
            'low' => 'Baja',
            'medium' => 'Media',
            'high' => 'Alta',
            'urgent' => 'Urgente',
        ];
    }

    public static function roleLabels(): array
    {
        return [
            'capitan' => 'Capitán',
            'lider_equipo' => 'Líder de equipo',
            'jugador' => 'Jugador',
            'padre' => 'Padre/Madre',
            'espectador' => 'Espectador',
            'otro' => 'Otro',
        ];
    }
}
