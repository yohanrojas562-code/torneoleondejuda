import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:torneo_leon_de_juda/core/network/api_exception.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/features/dashboard/data/dashboard_repository.dart';
import 'package:torneo_leon_de_juda/features/dashboard/data/lider_player_detail.dart';
import 'package:torneo_leon_de_juda/shared/widgets/async_view.dart';

/// Pantalla para gestionar los 5 archivos del jugador (foto, documento, EPS,
/// consentimiento sin EPS, consentimiento padres). Cada slot tiene su propio
/// upload independiente.
class MyPlayerFilesScreen extends ConsumerWidget {
  const MyPlayerFilesScreen({required this.playerId, super.key});

  final int playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myPlayerDetailProvider(playerId));

    return Scaffold(
      appBar: AppBar(title: const Text('Archivos del jugador')),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surfaceLow,
        onRefresh: () async {
          ref.invalidate(myPlayerDetailProvider(playerId));
          await ref.read(myPlayerDetailProvider(playerId).future);
        },
        child: AsyncView<LiderPlayerDetail>(
          value: async,
          onRetry: () => ref.invalidate(myPlayerDetailProvider(playerId)),
          data: (player) => _Body(player: player),
        ),
      ),
    );
  }
}

class _Body extends ConsumerStatefulWidget {
  const _Body({required this.player});

  final LiderPlayerDetail player;

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  PlayerFileKind? _uploading;

  Future<void> _uploadPhoto() async {
    setState(() => _uploading = PlayerFileKind.photo);
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (picked == null) {
        setState(() => _uploading = null);
        return;
      }
      await _send(PlayerFileKind.photo, picked.path);
    } finally {
      if (mounted) setState(() => _uploading = null);
    }
  }

  Future<void> _takePhotoFromCamera() async {
    setState(() => _uploading = PlayerFileKind.photo);
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (picked == null) {
        setState(() => _uploading = null);
        return;
      }
      await _send(PlayerFileKind.photo, picked.path);
    } finally {
      if (mounted) setState(() => _uploading = null);
    }
  }

  Future<void> _uploadDocOrPdf(PlayerFileKind kind) async {
    setState(() => _uploading = kind);
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
      );
      final path = picked?.files.firstOrNull?.path;
      if (path == null) {
        setState(() => _uploading = null);
        return;
      }
      await _send(kind, path);
    } finally {
      if (mounted) setState(() => _uploading = null);
    }
  }

  Future<void> _send(PlayerFileKind kind, String path) async {
    final repo = ref.read(dashboardRepositoryProvider);
    try {
      await repo.uploadPlayerFile(
        playerId: widget.player.id,
        kind: kind,
        filePath: path,
      );
      if (!mounted) return;
      ref.invalidate(myPlayerDetailProvider(widget.player.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.victory,
          content: Text('${kind.label} subido correctamente'),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.defeat,
          content: Text(e.message),
        ),
      );
    }
  }

  Future<void> _showPhotoSourceSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Tomar foto con la cámara'),
              onTap: () {
                Navigator.of(sheetCtx).pop();
                _takePhotoFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de la galería'),
              onTap: () {
                Navigator.of(sheetCtx).pop();
                _uploadPhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.player;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _Slot(
          title: PlayerFileKind.photo.label,
          subtitle: 'JPG o PNG · máx 3 MB',
          icon: Icons.account_circle_rounded,
          previewUrl: p.photoUrl,
          isImage: true,
          uploading: _uploading == PlayerFileKind.photo,
          onTap: _showPhotoSourceSheet,
        ),
        const SizedBox(height: AppSpacing.md),
        _Slot(
          title: PlayerFileKind.document.label,
          subtitle: 'Cédula / TI / pasaporte · PDF o imagen, máx 5 MB',
          icon: Icons.badge_outlined,
          previewUrl: p.documentFileUrl,
          uploading: _uploading == PlayerFileKind.document,
          onTap: () => _uploadDocOrPdf(PlayerFileKind.document),
        ),
        const SizedBox(height: AppSpacing.md),
        if (p.hasEps)
          _Slot(
            title: PlayerFileKind.epsCertificate.label,
            subtitle: 'Certificado de EPS vigente · PDF o imagen',
            icon: Icons.local_hospital_outlined,
            previewUrl: p.epsCertificateUrl,
            uploading: _uploading == PlayerFileKind.epsCertificate,
            onTap: () => _uploadDocOrPdf(PlayerFileKind.epsCertificate),
          )
        else
          _Slot(
            title: PlayerFileKind.noEpsConsent.label,
            subtitle: 'PDF firmado declarando que no tienes EPS',
            icon: Icons.assignment_late_outlined,
            previewUrl: p.noEpsConsentUrl,
            uploading: _uploading == PlayerFileKind.noEpsConsent,
            onTap: () => _uploadDocOrPdf(PlayerFileKind.noEpsConsent),
          ),
        if (p.isMinor) ...[
          const SizedBox(height: AppSpacing.md),
          _Slot(
            title: PlayerFileKind.parentalConsent.label,
            subtitle: 'Obligatorio para menores de 18 · PDF firmado por padres',
            icon: Icons.family_restroom_outlined,
            previewUrl: p.parentalConsentUrl,
            uploading: _uploading == PlayerFileKind.parentalConsent,
            onTap: () => _uploadDocOrPdf(PlayerFileKind.parentalConsent),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.10),
            borderRadius: AppRadius.brSm,
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: AppColors.warning,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'Al subir un archivo nuevo, el anterior se reemplaza '
                  'automáticamente. Los formatos aceptados son PDF, JPG y PNG.',
                  style: AppTypography.bodySmall.copyWith(
                    height: 1.4,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.huge),
      ],
    );
  }
}

class _Slot extends StatelessWidget {
  const _Slot({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.uploading,
    required this.onTap,
    this.previewUrl,
    this.isImage = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool uploading;
  final VoidCallback onTap;
  final String? previewUrl;
  final bool isImage;

  @override
  Widget build(BuildContext context) {
    final hasFile = previewUrl != null && previewUrl!.isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: AppRadius.brMd,
        border: Border.all(
          color: hasFile
              ? AppColors.victory.withValues(alpha: 0.35)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: hasFile
                        ? AppColors.victoryTint
                        : AppColors.primaryTintMedium,
                    borderRadius: AppRadius.brSm,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    color: hasFile ? AppColors.victory : AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: hasFile
                        ? AppColors.victoryTint
                        : AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: AppRadius.brXs,
                    border: Border.all(
                      color: (hasFile ? AppColors.victory : AppColors.warning)
                          .withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    hasFile ? 'CARGADO' : 'PENDIENTE',
                    style: AppTypography.labelSmall.copyWith(
                      color: hasFile ? AppColors.victory : AppColors.warning,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (hasFile && isImage)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(8),
              ),
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: CachedNetworkImage(
                  imageUrl: previewUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: AppColors.surfaceHigh,
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.surfaceHigh,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.broken_image_outlined,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: uploading ? null : onTap,
                    icon: uploading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.textOnPrimary,
                              ),
                            ),
                          )
                        : Icon(
                            hasFile
                                ? Icons.refresh_rounded
                                : Icons.upload_file_rounded,
                          ),
                    label: Text(
                      uploading
                          ? 'Subiendo…'
                          : (hasFile ? 'Reemplazar' : 'Subir archivo'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
