import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:torneo_leon_de_juda/core/network/api_exception.dart';
import 'package:torneo_leon_de_juda/core/router/app_route.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/features/pqrs/data/pqrs.dart';
import 'package:torneo_leon_de_juda/features/pqrs/data/pqrs_repository.dart';
import 'package:torneo_leon_de_juda/features/pqrs/presentation/widgets/evidence_picker.dart';
import 'package:torneo_leon_de_juda/features/pqrs/presentation/widgets/pqrs_type_selector.dart';
import 'package:torneo_leon_de_juda/shared/widgets/app_drawer.dart';

/// Pantalla PQRS. Form completo: tipo, datos del solicitante, asunto,
/// descripción, evidencias. Al enviar hace POST al API y navega a success.
class PqrsScreen extends ConsumerStatefulWidget {
  const PqrsScreen({super.key});

  @override
  ConsumerState<PqrsScreen> createState() => _PqrsScreenState();
}

class _PqrsScreenState extends ConsumerState<PqrsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  PqrsType _type = PqrsType.peticion;
  List<XFile> _evidence = [];
  bool _submitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final submission = PqrsSubmission(
      type: _type,
      fullName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      subject: _subjectCtrl.text.trim(),
      message: _messageCtrl.text.trim(),
      evidencePaths: _evidence.map((f) => f.path).toList(growable: false),
    );

    try {
      final code =
          await ref.read(pqrsRepositoryProvider).submit(submission);
      if (!mounted) return;
      context.goNamed(
        AppRoute.pqrsSuccess.name,
        pathParameters: {'code': code},
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      final message = e is ValidationException && e.errors != null
          ? e.errors!.values
              .expand((errs) => errs)
              .firstOrNull ??
              e.message
          : e.message;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.defeat,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String? _validateRequired(String? v, {String label = 'Este campo'}) {
    if (v == null || v.trim().isEmpty) return '$label es obligatorio';
    return null;
  }

  String? _validateEmail(String? v) {
    final required = _validateRequired(v, label: 'El correo');
    if (required != null) return required;
    final email = v!.trim();
    final ok = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
    return ok ? null : 'Correo electrónico no válido';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            tooltip: 'Menú',
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('PQRS'),
      ),
      body: AbsorbPointer(
        absorbing: _submitting,
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              const _IntroBanner(),
              const SizedBox(height: AppSpacing.lg),

              const _SectionLabel('TIPO DE SOLICITUD'),
              const SizedBox(height: AppSpacing.sm),
              PqrsTypeSelector(
                selected: _type,
                onChanged: (t) => setState(() => _type = t),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.xxs),
                child: Text(
                  _type.description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              const _SectionLabel('TUS DATOS'),
              const SizedBox(height: AppSpacing.sm),
              _TextField(
                controller: _nameCtrl,
                label: 'Nombre completo',
                icon: Icons.person_outline_rounded,
                validator: (v) =>
                    _validateRequired(v, label: 'El nombre'),
              ),
              const SizedBox(height: AppSpacing.sm),
              _TextField(
                controller: _emailCtrl,
                label: 'Correo electrónico',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: AppSpacing.sm),
              _TextField(
                controller: _phoneCtrl,
                label: 'Teléfono (opcional)',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSpacing.lg),

              const _SectionLabel('TU SOLICITUD'),
              const SizedBox(height: AppSpacing.sm),
              _TextField(
                controller: _subjectCtrl,
                label: 'Asunto',
                icon: Icons.subject_rounded,
                validator: (v) =>
                    _validateRequired(v, label: 'El asunto'),
              ),
              const SizedBox(height: AppSpacing.sm),
              _TextField(
                controller: _messageCtrl,
                label: 'Describe tu solicitud',
                icon: Icons.notes_rounded,
                maxLines: 5,
                validator: (v) =>
                    _validateRequired(v, label: 'La descripción'),
              ),
              const SizedBox(height: AppSpacing.lg),

              const _SectionLabel('EVIDENCIAS (OPCIONAL)'),
              const SizedBox(height: AppSpacing.sm),
              EvidencePicker(
                files: _evidence,
                onChanged: (next) => setState(() => _evidence = next),
              ),
              const SizedBox(height: AppSpacing.xl),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.textOnPrimary,
                            ),
                          ),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(_submitting ? 'Enviando…' : 'Enviar solicitud'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Te responderemos por correo en un máximo de 7 días hábiles.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.huge),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroBanner extends StatelessWidget {
  const _IntroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: AppColors.cardPremiumGradient,
        color: AppColors.surfaceLow,
        borderRadius: AppRadius.brMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryTintMedium,
              borderRadius: AppRadius.brSm,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estamos para escucharte',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Envía tu petición, queja, reclamo o sugerencia al comité.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xxs),
      child: Text(text, style: AppTypography.labelLarge),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: AppColors.surfaceLow,
        alignLabelWithHint: maxLines > 1,
        border: const OutlineInputBorder(
          borderRadius: AppRadius.brSm,
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.brSm,
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.brSm,
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}
