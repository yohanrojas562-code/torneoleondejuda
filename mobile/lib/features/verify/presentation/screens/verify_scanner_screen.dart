import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/features/verify/data/mock_verify_data.dart';
import 'package:torneo_leon_de_juda/features/verify/presentation/widgets/manual_lookup_sheet.dart';
import 'package:torneo_leon_de_juda/features/verify/presentation/widgets/scanner_overlay.dart';
import 'package:torneo_leon_de_juda/features/verify/presentation/widgets/verify_result_sheet.dart';

/// Pantalla Validador. Cámara activa que escanea QR de carnets de jugadores.
/// Cuando detecta uno → consulta el mock y muestra el resultado en un sheet.
/// Opción de búsqueda manual abajo si la cámara no funciona o el QR está
/// dañado.
class VerifyScannerScreen extends StatefulWidget {
  const VerifyScannerScreen({this.initialCode, super.key});

  /// Si llega por deep-link `/verificar/:code`, lo procesamos al inicio.
  final String? initialCode;

  @override
  State<VerifyScannerScreen> createState() => _VerifyScannerScreenState();
}

class _VerifyScannerScreenState extends State<VerifyScannerScreen>
    with WidgetsBindingObserver {
  late final MobileScannerController _controller;
  bool _torchOn = false;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = MobileScannerController();

    if (widget.initialCode != null && widget.initialCode!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleCode(widget.initialCode!);
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller.start();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _controller.stop();
    }
  }

  Future<void> _handleCode(String code) async {
    if (_processing) return;
    setState(() => _processing = true);
    unawaited(HapticFeedback.mediumImpact());
    await _controller.stop();

    final result = MockVerifyData.lookup(code);
    if (!mounted) return;

    await VerifyResultSheet.show(
      context,
      result: result,
      searchedCode: code,
    );

    if (!mounted) return;
    await _controller.start();
    setState(() => _processing = false);
  }

  Future<void> _toggleTorch() async {
    await _controller.toggleTorch();
    setState(() => _torchOn = !_torchOn);
  }

  Future<void> _openManualLookup() async {
    final code = await ManualLookupSheet.show(context);
    if (code != null && code.isNotEmpty) {
      await _handleCode(code);
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_processing) return;
    final value = capture.barcodes
        .map((b) => b.rawValue)
        .firstWhere((v) => v != null && v.isNotEmpty, orElse: () => null);
    if (value == null) return;
    unawaited(_handleCode(value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Validador'),
        actions: [
          IconButton(
            onPressed: _toggleTorch,
            tooltip: _torchOn ? 'Apagar linterna' : 'Encender linterna',
            icon: Icon(
              _torchOn
                  ? Icons.flashlight_on_rounded
                  : Icons.flashlight_off_rounded,
            ),
          ),
          IconButton(
            onPressed: () => _controller.switchCamera(),
            tooltip: 'Cambiar cámara',
            icon: const Icon(Icons.cameraswitch_rounded),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error, _) => _CameraError(error: error),
          ),
          const ScannerOverlay(),
          const _Instructions(),
          Positioned(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.lg,
            child: SafeArea(
              child: FilledButton.tonalIcon(
                onPressed: _openManualLookup,
                icon: const Icon(Icons.keyboard_alt_outlined),
                label: const Text('Buscar manualmente'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: AppColors.surfaceHigh.withValues(
                    alpha: 0.92,
                  ),
                  foregroundColor: AppColors.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.brSm,
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Instructions extends StatelessWidget {
  const _Instructions();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: kToolbarHeight + 24,
      left: AppSpacing.lg,
      right: AppSpacing.lg,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: AppRadius.brSm,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.qr_code_2_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Apunta al QR del carnet del jugador',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CameraError extends StatelessWidget {
  const _CameraError({required this.error});
  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgDeep,
      padding: const EdgeInsets.all(AppSpacing.lg),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.no_photography_rounded,
            size: 48,
            color: AppColors.defeat,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No se pudo acceder a la cámara',
            style: AppTypography.headerSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            error.errorDetails?.message ??
                'Verifica los permisos de cámara en los ajustes del dispositivo.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
