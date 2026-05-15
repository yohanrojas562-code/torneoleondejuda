<?php

namespace App\Http\Requests\Api;

use Illuminate\Foundation\Http\FormRequest;

/**
 * Reglas de validación específicas para PQRS enviadas desde la app móvil.
 * Difiere del StorePqrsRequest web en:
 *  - `submitter_role` opcional (la app no lo pide en su form simplificado).
 *  - `submitter_team_id` opcional.
 *  - Sin honeypot ni privacy_accepted (los Términos del app store aplican).
 *  - Subset de mimetypes permitidos (solo imágenes — image_picker no sube
 *    videos/PDF desde el form actual).
 */
class StorePqrsApiRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'type' => ['required', 'in:peticion,queja,reclamo,sugerencia,apelacion,felicitacion'],
            'subject' => ['required', 'string', 'max:200'],
            'description' => ['required', 'string', 'min:20', 'max:5000'],
            'submitter_name' => ['required', 'string', 'max:150'],
            'submitter_email' => ['required', 'email:rfc', 'max:150'],
            'submitter_phone' => ['nullable', 'string', 'max:30'],
            'submitter_team_id' => ['nullable', 'integer', 'exists:teams,id'],
            'submitter_role' => ['nullable', 'in:capitan,lider_equipo,jugador,padre,espectador,otro'],
            'attachments' => ['nullable', 'array', 'max:5'],
            'attachments.*' => [
                'file',
                'max:25600',
                'mimetypes:image/jpeg,image/png,image/gif,image/webp',
            ],
        ];
    }

    public function messages(): array
    {
        return [
            'type.required' => 'Selecciona el tipo de solicitud.',
            'type.in' => 'El tipo seleccionado no es válido.',
            'subject.required' => 'El asunto es obligatorio.',
            'subject.max' => 'El asunto no puede exceder 200 caracteres.',
            'description.required' => 'La descripción es obligatoria.',
            'description.min' => 'Describe tu caso con al menos 20 caracteres.',
            'description.max' => 'La descripción no puede exceder 5000 caracteres.',
            'submitter_name.required' => 'Tu nombre es obligatorio.',
            'submitter_email.required' => 'Tu correo electrónico es obligatorio.',
            'submitter_email.email' => 'Ingresa un correo electrónico válido.',
            'attachments.max' => 'Puedes subir un máximo de 5 archivos.',
            'attachments.*.max' => 'Cada archivo debe pesar máximo 25 MB.',
            'attachments.*.mimetypes' => 'Solo se permiten imágenes (JPG, PNG, GIF, WEBP).',
        ];
    }
}
