<?php

/*
|--------------------------------------------------------------------------
| CORS — Configuración para la API móvil (Flutter)
|--------------------------------------------------------------------------
|
| Solo abre CORS para el prefijo `api/*`. El sitio web Inertia sigue sin CORS
| porque sirve cookies same-origin. La app de Android/iOS no es un navegador
| y no aplica CORS, así que esta config sólo importa para Flutter Web durante
| el testing en Chrome.
|
*/

return [

    'paths' => ['api/*'],

    'allowed_methods' => ['*'],

    'allowed_origins' => ['*'],

    'allowed_origins_patterns' => [],

    'allowed_headers' => ['*'],

    'exposed_headers' => [],

    'max_age' => 0,

    'supports_credentials' => false,

];
