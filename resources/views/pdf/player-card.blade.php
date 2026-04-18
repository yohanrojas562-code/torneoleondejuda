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
        }

        .card {
            width: 242.65pt;
            height: 153.01pt;
            position: relative;
            overflow: hidden;
            background: linear-gradient(135deg, #0a0a0a 0%, #1a1a1a 100%);
            color: #ffffff;
        }

        /* Gold top bar */
        .top-bar {
            background: linear-gradient(90deg, #D68F03 0%, #E5A824 50%, #D68F03 100%);
            height: 28pt;
            padding: 3pt 8pt;
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
            letter-spacing: 0.5pt;
        }

        .category-name {
            font-size: 5pt;
            color: #2a2a2a;
            text-transform: uppercase;
        }

        /* Main content */
        .content {
            padding: 6pt 8pt 4pt 8pt;
            position: relative;
            height: 125pt;
        }

        .left-col {
            float: left;
            width: 55pt;
        }

        .photo-frame {
            width: 50pt;
            height: 62pt;
            border: 1.5pt solid #D68F03;
            border-radius: 3pt;
            overflow: hidden;
            background: #1a1a1a;
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
            font-size: 7pt;
            color: #666;
            text-align: center;
            padding-top: 20pt;
        }

        .jersey-number {
            text-align: center;
            font-size: 14pt;
            font-weight: bold;
            color: #D68F03;
            margin-top: 2pt;
            line-height: 1;
        }

        .position-label {
            text-align: center;
            font-size: 5pt;
            color: #999;
            text-transform: uppercase;
            letter-spacing: 0.5pt;
        }

        .center-col {
            float: left;
            width: 108pt;
            padding-left: 6pt;
        }

        .player-name {
            font-size: 8.5pt;
            font-weight: bold;
            color: #ffffff;
            text-transform: uppercase;
            letter-spacing: 0.3pt;
            margin-bottom: 4pt;
            border-bottom: 0.5pt solid #D68F03;
            padding-bottom: 3pt;
        }

        .team-name {
            font-size: 6pt;
            color: #D68F03;
            text-transform: uppercase;
            font-weight: bold;
            margin-bottom: 4pt;
            letter-spacing: 0.3pt;
        }

        .info-grid {
            width: 100%;
        }

        .info-row {
            margin-bottom: 2pt;
        }

        .info-label {
            font-size: 4.5pt;
            color: #888;
            text-transform: uppercase;
            letter-spacing: 0.3pt;
        }

        .info-value {
            font-size: 6pt;
            color: #e0e0e0;
            font-weight: bold;
        }

        .right-col {
            float: right;
            width: 65pt;
            text-align: center;
        }

        .qr-frame {
            width: 58pt;
            height: 58pt;
            margin: 0 auto 2pt auto;
            padding: 3pt;
            background: #ffffff;
            border-radius: 3pt;
        }

        .qr-frame img {
            width: 100%;
            height: 100%;
        }

        .qr-label {
            font-size: 3.5pt;
            color: #666;
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
            background: linear-gradient(90deg, #D68F03 0%, #E5A824 50%, #D68F03 100%);
        }

        /* RH badge */
        .rh-badge {
            display: inline-block;
            background: #D68F03;
            color: #0a0a0a;
            font-size: 7pt;
            font-weight: bold;
            padding: 1pt 4pt;
            border-radius: 2pt;
            margin-top: 1pt;
        }

        .clearfix::after {
            content: "";
            display: table;
            clear: both;
        }
    </style>
</head>
<body>
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
            {{-- Left: photo + jersey --}}
            <div class="left-col">
                <div class="photo-frame">
                    @if($photoBase64)
                        <img src="{{ $photoBase64 }}" alt="Foto">
                    @else
                        <div class="no-photo">SIN<br>FOTO</div>
                    @endif
                </div>
                <div class="jersey-number">#{{ $player->jersey_number ?? '-' }}</div>
                <div class="position-label">
                    {{ match($player->position) {
                        'portero' => 'Portero',
                        'defensa' => 'Defensa',
                        'mediocampista' => 'Mediocampista',
                        'delantero' => 'Delantero',
                        default => $player->position ?? '-'
                    } }}
                </div>
            </div>

            {{-- Center: info --}}
            <div class="center-col">
                <div class="player-name">{{ $player->first_name }} {{ $player->last_name }}</div>
                <div class="team-name">{{ $player->team?->name ?? 'Sin equipo' }}</div>

                <div class="info-grid">
                    <div class="info-row">
                        <div class="info-label">Documento</div>
                        <div class="info-value">{{ $player->document_type }} {{ $player->document_number }}</div>
                    </div>
                    <div class="info-row">
                        <div class="info-label">Fecha Nac.</div>
                        <div class="info-value">{{ $player->birth_date?->format('d/m/Y') ?? '-' }}</div>
                    </div>
                    <div class="info-row">
                        <div class="info-label">Tipo de Sangre</div>
                        <div class="info-value">
                            @if($player->blood_type)
                                <span class="rh-badge">{{ $player->blood_type }}</span>
                            @else
                                -
                            @endif
                        </div>
                    </div>
                    <div class="info-row">
                        <div class="info-label">Dorsal</div>
                        <div class="info-value">{{ $player->jersey_name ?? '-' }}</div>
                    </div>
                </div>
            </div>

            {{-- Right: QR --}}
            <div class="right-col">
                <div class="qr-frame">
                    <img src="{{ $qrBase64 }}" alt="QR Code">
                </div>
                <div class="qr-label">Escanear para verificar</div>
            </div>

            <div class="bottom-bar"></div>
        </div>
    </div>
</body>
</html>
