<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Facades\Storage;

class PqrsAttachment extends Model
{
    use HasFactory;

    protected $fillable = [
        'pqrs_id',
        'response_id',
        'file_path',
        'file_name',
        'mime_type',
        'file_size',
    ];

    public function pqrs(): BelongsTo
    {
        return $this->belongsTo(Pqrs::class, 'pqrs_id');
    }

    public function response(): BelongsTo
    {
        return $this->belongsTo(PqrsResponse::class, 'response_id');
    }

    public function getCategoryAttribute(): string
    {
        if (str_starts_with($this->mime_type, 'image/')) return 'image';
        if (str_starts_with($this->mime_type, 'video/')) return 'video';
        return 'document';
    }

    public function getHumanFileSizeAttribute(): string
    {
        $bytes = $this->file_size;
        if ($bytes >= 1048576) return number_format($bytes / 1048576, 2) . ' MB';
        if ($bytes >= 1024) return number_format($bytes / 1024, 2) . ' KB';
        return $bytes . ' B';
    }

    protected static function booted(): void
    {
        static::deleting(function (PqrsAttachment $attachment) {
            if ($attachment->file_path && Storage::disk('local')->exists($attachment->file_path)) {
                Storage::disk('local')->delete($attachment->file_path);
            }
        });
    }
}
