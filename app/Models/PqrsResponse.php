<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class PqrsResponse extends Model
{
    use HasFactory;

    protected $fillable = [
        'pqrs_id',
        'user_id',
        'type',
        'content',
        'previous_status',
        'new_status',
        'is_visible_to_submitter',
    ];

    protected $casts = [
        'is_visible_to_submitter' => 'boolean',
    ];

    public function pqrs(): BelongsTo
    {
        return $this->belongsTo(Pqrs::class, 'pqrs_id');
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function attachments(): HasMany
    {
        return $this->hasMany(PqrsAttachment::class, 'response_id');
    }

    public static function typeLabels(): array
    {
        return [
            'note' => 'Nota interna',
            'status_change' => 'Cambio de estado',
            'public_response' => 'Respuesta al solicitante',
            'action_taken' => 'Acción tomada',
            'assignment' => 'Asignación',
        ];
    }
}
