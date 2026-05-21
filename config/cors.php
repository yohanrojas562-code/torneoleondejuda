<?php

/*
|--------------------------------------------------------------------------
| CORS — Configuración para la API móvil (Flutter)
|--------------------------------------------------------------------------
|
| Abre CORS para:
|  - `api/*`: endpoints REST consumidos por la app móvil.
|  - `storage/*`: assets públicos (logos de equipos, fotos de jugadores,
|    logos de sponsors). Flutter Web los renderea via canvas que exige
|    CORS; sin esto las imágenes salen en blanco en Chrome. En APK Android
|    no aplica CORS, así que esto solo importa para testing en navegador.
|
| El sitio web Inertia sigue sin CORS porque sirve cookies same-origin.
|
*/

return [

    'paths' => ['api/*', 'storage/*'],

    'allowed_methods' => ['*'],

    'allowed_origins' => ['*'],

    'allowed_origins_patterns' => [],

    'allowed_headers' => ['*'],

    'exposed_headers' => [],

    'max_age' => 0,

    'supports_credentials' => false,

];
