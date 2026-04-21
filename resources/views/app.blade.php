<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        @php
            $siteName        = \App\Models\SiteSetting::get('site_name', 'Torneo León de Judá');
            $siteDescription = \App\Models\SiteSetting::get('site_description', 'Torneo de fútbol León de Judá — inscripciones, equipos, resultados y más.');
            $logoPath        = \App\Models\SiteSetting::get('logo');
            $ogImage         = $logoPath ? asset('storage/' . $logoPath) : null;
        @endphp

        <title inertia>{{ $siteName }}</title>
        <meta name="description" content="{{ $siteDescription }}">

        <!-- Open Graph / WhatsApp / Facebook -->
        <meta property="og:type"        content="website">
        <meta property="og:url"         content="{{ url('/') }}">
        <meta property="og:title"       content="{{ $siteName }}">
        <meta property="og:description" content="{{ $siteDescription }}">
        @if($ogImage)
        <meta property="og:image"       content="{{ $ogImage }}">
        <meta property="og:image:width"  content="800">
        <meta property="og:image:height" content="800">
        @endif

        <!-- Twitter Card -->
        <meta name="twitter:card"        content="summary">
        <meta name="twitter:title"       content="{{ $siteName }}">
        <meta name="twitter:description" content="{{ $siteDescription }}">
        @if($ogImage)
        <meta name="twitter:image"       content="{{ $ogImage }}">
        @endif

        <!-- Favicon -->
        @if($logoPath)
        <link rel="icon" type="image/png" href="{{ asset('storage/' . $logoPath) }}">
        <link rel="apple-touch-icon" href="{{ asset('storage/' . $logoPath) }}">
        @else
        <link rel="icon" type="image/x-icon" href="{{ asset('favicon.ico') }}">
        @endif

        <!-- Fonts -->
        <link rel="preconnect" href="https://fonts.bunny.net">
        <link href="https://fonts.bunny.net/css?family=figtree:400,500,600&display=swap" rel="stylesheet" />

        <!-- Scripts -->
        @routes
        @viteReactRefresh
        @vite(['resources/js/app.tsx', "resources/js/Pages/{$page['component']}.tsx"])
        @inertiaHead
    </head>
    <body class="font-sans antialiased">
        @inertia
    </body>
</html>
