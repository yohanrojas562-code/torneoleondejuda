<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StorePqrsRequest extends FormRequest
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
            'submitter_team_id' => ['nullable', 'exists:teams,id'],
            'submitter_role' => ['required', 'in:capitan,lider_equipo,jugador,padre,espectador,otro'],
            'attachments' => ['nullable', 'array', 'max:5'],
            'attachments.*' => [
                'file',
                'max:25600', // 25 MB
                'mimetypes:image/jpeg,image/png,image/gif,image/webp,video/mp4,video/quicktime,video/webm,application/pdf',
            ],
            'privacy_accepted' => ['required', 'accepted'],
            'website' => ['nullable', 'size:0'], // honeypot: must be empty/absent
        ];
    }

    public function messages(): array
    {
        return [
            'type.required' => 'Selecciona el tipo de PQRS.',
            'type.in' => 'El tipo seleccionado no es válido.',
            'subject.required' => 'El asunto es obligatorio.',
            'subject.max' => 'El asunto no puede exceder 200 caracteres.',
            'description.required' => 'La descripción es obligatoria.',
            'description.min' => 'Describe tu caso con al menos 20 caracteres.',
            'description.max' => 'La descripción no puede exceder 5000 caracteres.',
            'submitter_name.required' => 'Tu nombre es obligatorio.',
            'submitter_email.required' => 'Tu correo electrónico es obligatorio.',
            'submitter_email.email' => 'Ingresa un correo electrónico válido.',
            'submitter_team_id.exists' => 'El equipo seleccionado no existe.',
            'submitter_role.required' => 'Selecciona tu rol en el torneo.',
            'submitter_role.in' => 'El rol seleccionado no es válido.',
            'attachments.max' => 'Puedes subir un máximo de 5 archivos.',
            'attachments.*.max' => 'Cada archivo debe pesar máximo 25 MB.',
            'attachments.*.mimetypes' => 'Solo se permiten imágenes (JPG, PNG, GIF, WEBP), videos (MP4, MOV, WEBM) o PDF.',
            'privacy_accepted.accepted' => 'Debes aceptar el tratamiento de datos personales.',
            'website.size' => 'Solicitud no válida.',
        ];
    }
}
