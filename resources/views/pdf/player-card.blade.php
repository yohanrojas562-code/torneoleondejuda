<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        @page {
            margin: 0;
        }

        body {
            font-family: 'Helvetica', 'Arial', sans-serif;
            margin: 0;
            padding: 0;
            background: #ffffff;
        }

        .card {
            width: 242.65pt;
            height: 153.01pt;
            position: relative;
            overflow: hidden;
            background: #ffffff;
            color: #0a0a0a;
            border: 0.5pt solid #d0d0d0;
        }

        /* Gold top bar (solid, sin gradient para que DomPDF lo renderice bien) */
        .top-bar {
            background: #D68F03;
            height: 26pt;
            padding: 2pt 6pt;
            display: flex;
            align-items: center;
        }

        .top-bar-inner {
            width: 100%;
        }

        .logo-section {
            float: left;
            height: 22pt;
        }

        .logo-section img {
            height: 22pt;
            width: auto;
        }

        .tournament-section {
            float: right;
            text-align: right;
            padding-top: 1pt;
        }

        .tournament-name {
            font-size: 6pt;
            font-weight: bold;
            color: #0a0a0a;
            text-transform: uppercase;
            letter-spacing: 0.4pt;
        }

        .category-name {
            font-size: 5pt;
            color: #1a1a1a;
            text-transform: uppercase;
            margin-top: 0.5pt;
        }

        /* Main content */
        .content {
            padding: 5pt 6pt 5pt 6pt;
            position: relative;
            height: 124pt;
            background: #ffffff;
        }

        /* Left column: photo + jersey + position */
        .left-col {
            float: left;
            width: 52pt;
        }

        .photo-frame {
            width: 50pt;
            height: 60pt;
            border: 1.5pt solid #D68F03;
            border-radius: 3pt;
            overflow: hidden;
            background: #f5f5f5;
        }

        .photo-frame img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .no-photo {
            width: 100%;
            height: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 6pt;
            color: #888;
            text-align: center;
            padding-top: 22pt;
        }

        .jersey-number {
            text-align: center;
            font-size: 13pt;
            font-weight: bold;
            color: #B57A02;
            margin-top: 2pt;
            line-height: 1;
            letter-spacing: -0.3pt;
        }

        .position-label {
            text-align: center;
            font-size: 5pt;
            color: #1a1a1a;
            text-transform: uppercase;
            letter-spacing: 0.4pt;
            margin-top: 1pt;
            font-weight: bold;
        }

        /* Center column: name + team + ficha técnica */
        .center-col {
            float: left;
            width: 118pt;
            padding-left: 6pt;
        }

        .name-row {
            border-bottom: 0.7pt solid #D68F03;
            padding-bottom: 2pt;
            margin-bottom: 3pt;
        }

        .player-name {
            font-weight: bold;
            color: #000000;
            text-transform: uppercase;
            letter-spacing: 0.1pt;
            line-height: 1.1;
            word-wrap: break-word;
            overflow-wrap: break-word;
        }

        .player-name-short { font-size: 8.5pt; }
        .player-name-mid   { font-size: 7.5pt; }
        .player-name-long  { font-size: 6.5pt; }
        .player-name-xlong { font-size: 5.5pt; }

        .captain-badge {
            display: inline-block;
            background: #D68F03;
            color: #0a0a0a;
            font-size: 5pt;
            font-weight: bold;
            padding: 0pt 2pt;
            border-radius: 1.5pt;
            margin-left: 2pt;
            vertical-align: middle;
        }

        .team-name {
            font-size: 6.5pt;
            color: #B57A02;
            text-transform: uppercase;
            font-weight: bold;
            margin-bottom: 3pt;
            letter-spacing: 0.3pt;
            word-wrap: break-word;
            overflow-wrap: break-word;
            line-height: 1.1;
        }

        .info-grid {
            width: 100%;
        }

        .info-row {
            font-size: 5.5pt;
            line-height: 1.3;
            margin-bottom: 0.8pt;
            color: #000000;
        }

        .info-label {
            display: inline-block;
            color: #555555;
            text-transform: uppercase;
            letter-spacing: 0.3pt;
            font-size: 4.2pt;
            font-weight: bold;
            width: 28pt;
        }

        .info-value {
            display: inline;
            color: #000000;
            font-weight: bold;
            font-size: 5.5pt;
            word-wrap: break-word;
            overflow-wrap: break-word;
        }

        .info-value-note {
            color: #555555;
            font-weight: normal;
        }

        .rh-badge {
            display: inline-block;
            background: #D68F03;
            color: #0a0a0a;
            font-size: 5pt;
            font-weight: bold;
            padding: 0pt 3pt;
            border-radius: 1.5pt;
            line-height: 1.4;
        }

        .status-badge {
            display: inline-block;
            font-size: 4.5pt;
            font-weight: bold;
            padding: 1pt 3pt;
            border-radius: 1.5pt;
            text-transform: uppercase;
            letter-spacing: 0.3pt;
            line-height: 1;
        }

        .status-approved { background: #10b981; color: #ffffff; }
        .status-pending { background: #f59e0b; color: #0a0a0a; }
        .status-rejected { background: #ef4444; color: #ffffff; }

        /* Right column: QR + code */
        .right-col {
            float: right;
            width: 60pt;
            text-align: center;
        }

        .qr-frame {
            width: 60pt;
            height: 60pt;
            margin: 0 auto 2pt auto;
            padding: 1.5pt;
            background: #ffffff;
            border: 1pt solid #D68F03;
            border-radius: 3pt;
            overflow: hidden;
        }

        .qr-frame img {
            width: 57pt;
            height: 57pt;
        }

        .qr-fallback {
            width: 57pt;
            height: 57pt;
            background: #f5f5f5;
            display: flex;
            align-items: center;
            justify-content: center;
            text-align: center;
            font-size: 5pt;
            color: #555;
            padding: 4pt;
        }

        .qr-label {
            font-size: 4pt;
            color: #B57A02;
            text-transform: uppercase;
            letter-spacing: 0.4pt;
            font-weight: bold;
            margin-top: 1pt;
        }

        .qr-hint {
            font-size: 3.5pt;
            color: #555555;
            margin-top: 0.5pt;
            text-transform: uppercase;
            letter-spacing: 0.3pt;
        }

        /* Bottom gold accent */
        .bottom-bar {
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            height: 2.5pt;
            background: #D68F03;
        }

        .clearfix::after {
            content: "";
            display: table;
            clear: both;
        }
    </style>
</head>
<body>
    @php
        $statusLabels = [
            'approved' => 'Aprobado',
            'pending' => 'Pendiente',
            'rejected' => 'Rechazado',
        ];
        $statusKey = $player->approval_status ?? 'pending';
        $statusLabel = $statusLabels[$statusKey] ?? ucfirst($statusKey);

        $positionLabels = [
            'portero' => 'Portero',
            'defensa' => 'Defensa',
            'mediocampista' => 'Mediocampista',
            'delantero' => 'Delantero',
        ];
        $positionLabel = $positionLabels[$player->position] ?? ucfirst($player->position ?? '—');

        $fullName = trim(($player->first_name ?? '') . ' ' . ($player->last_name ?? ''));

        // Clase de tamaño de nombre según longitud para evitar que quede mocho
        $nameLen = mb_strlen($fullName);
        $nameClass = $nameLen <= 16 ? 'player-name-short'
            : ($nameLen <= 22 ? 'player-name-mid'
            : ($nameLen <= 30 ? 'player-name-long' : 'player-name-xlong'));
    @endphp

    <div class="card">
        {{-- Gold header bar --}}
        <div class="top-bar">
            <div class="top-bar-inner clearfix">
                <div class="logo-section">
                    @if($logoBase64)
                        <img src="{{ $logoBase64 }}" alt="Logo">
                    @endif
                </div>
                <div class="tournament-section">
                    <div class="tournament-name">{{ $tournamentName }}</div>
                    @if($categoryName)
                        <div class="category-name">{{ $categoryName }}</div>
                    @endif
                </div>
            </div>
        </div>

        {{-- Main content --}}
        <div class="content clearfix">
            {{-- Left: photo + jersey + position --}}
            <div class="left-col">
                <div class="photo-frame">
                    @if($photoBase64)
                        <img src="{{ $photoBase64 }}" alt="Foto">
                    @else
                        <div class="no-photo">SIN<br>FOTO</div>
                    @endif
                </div>
                <div class="jersey-number">#{{ $player->jersey_number ?? '-' }}</div>
                <div class="position-label">{{ $positionLabel }}</div>
            </div>

            {{-- Center: name + team + ficha técnica --}}
            <div class="center-col">
                <div class="name-row">
                    <div class="player-name {{ $nameClass }}">
                        {{ $fullName ?: '—' }}
                        @if($player->is_captain)
                            <span class="captain-badge">C</span>
                        @endif
                    </div>
                </div>

                <div class="team-name">{{ $player->team?->name ?? 'Sin equipo' }}</div>

                <div class="info-grid">
                    <div class="info-row">
                        <span class="info-label">Doc</span>
                        <span class="info-value">{{ $player->document_type }} {{ $player->document_number }}</span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Nac</span>
                        <span class="info-value">
                            {{ $player->birth_date?->format('d/m/Y') ?? '—' }}
                            @if($player->age)
                                <span class="info-value-note">({{ $player->age }} años)</span>
                            @endif
                        </span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">RH</span>
                        <span class="info-value">
                            @if($player->blood_type)
                                <span class="rh-badge">{{ $player->blood_type }}</span>
                            @else
                                —
                            @endif
                        </span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Iglesia</span>
                        <span class="info-value">{{ $player->church ?? '—' }}</span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Dorsal</span>
                        <span class="info-value">{{ $player->jersey_name ?? '—' }}</span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Estado</span>
                        <span class="info-value">
                            <span class="status-badge status-{{ $statusKey }}">{{ $statusLabel }}</span>
                        </span>
                    </div>
                </div>
            </div>

            {{-- Right: QR + unique code --}}
            <div class="right-col">
                <div class="qr-frame">
                    @if($qrBase64)
                        <img src="{{ $qrBase64 }}" alt="QR">
                    @else
                        <div class="qr-fallback">{{ $player->unique_code ?? 'Sin QR' }}</div>
                    @endif
                </div>
                <div class="qr-label">{{ $player->unique_code ?? '' }}</div>
                <div class="qr-hint">Escanea ficha</div>
            </div>

            <div class="bottom-bar"></div>
        </div>
    </div>
</body>
</html>
