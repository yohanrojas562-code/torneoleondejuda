import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';

/// Selector múltiple de fotos como evidencia. Permite cámara o galería,
/// muestra preview en grid y permite eliminar individualmente. Límite [maxFiles].
class EvidencePicker extends StatelessWidget {
  const EvidencePicker({
    required this.files,
    required this.onChanged,
    this.maxFiles = 5,
    super.key,
  });

  final List<XFile> files;
  final ValueChanged<List<XFile>> onChanged;
  final int maxFiles;

  Future<void> _pickFromGallery(BuildContext context) async {
    final picker = ImagePicker();
    final remaining = maxFiles - files.length;
    if (remaining <= 0) return;
    final picked = await picker.pickMultiImage(
      imageQuality: 78,
      maxWidth: 2000,
    );
    if (picked.isEmpty) return;
    onChanged([...files, ...picked.take(remaining)]);
  }

  Future<void> _pickFromCamera(BuildContext context) async {
    final picker = ImagePicker();
    if (files.length >= maxFiles) return;
    final shot = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 78,
      maxWidth: 2000,
    );
    if (shot == null) return;
    onChanged([...files, shot]);
  }

  Future<void> _showSource(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.of(sheetCtx).pop();
                _pickFromCamera(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de la galería'),
              onTap: () {
                Navigator.of(sheetCtx).pop();
                _pickFromGallery(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _remove(int index) {
    final next = [...files]..removeAt(index);
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final canAdd = files.length < maxFiles;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (files.isEmpty)
          _AddTile(
            onTap: canAdd ? () => _showSource(context) : null,
            label: 'Agregar evidencia',
            subtitle: 'Hasta $maxFiles fotos (opcional)',
            big: true,
          )
        else
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: AppSpacing.xs,
            mainAxisSpacing: AppSpacing.xs,
            children: [
              for (var i = 0; i < files.length; i++)
                _Thumbnail(
                  file: files[i],
                  onRemove: () => _remove(i),
                ),
              if (canAdd)
                _AddTile(
                  onTap: () => _showSource(context),
                  label: 'Agregar',
                  subtitle: '${files.length}/$maxFiles',
                ),
            ],
          ),
      ],
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.file, required this.onRemove});

  final XFile file;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: AppRadius.brSm,
          child: Image.file(
            File(file.path),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.surfaceLow,
              alignment: Alignment.center,
              child: const Icon(
                Icons.broken_image_outlined,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: Material(
            color: Colors.black54,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onRemove,
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({
    required this.onTap,
    required this.label,
    required this.subtitle,
    this.big = false,
  });

  final VoidCallback? onTap;
  final String label;
  final String subtitle;
  final bool big;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.brSm,
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surfaceLow,
            borderRadius: AppRadius.brSm,
            border: Border.all(color: AppColors.border),
          ),
          padding: EdgeInsets.symmetric(
            vertical: big ? AppSpacing.lg : AppSpacing.sm,
            horizontal: AppSpacing.xs,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_a_photo_outlined,
                size: big ? 32 : 22,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: big ? 13 : 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted,
                  fontSize: big ? 11 : 9,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
