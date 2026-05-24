import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:torneo_leon_de_juda/core/network/api_exception.dart';
import 'package:torneo_leon_de_juda/core/router/app_route.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';
import 'package:torneo_leon_de_juda/core/theme/app_radius.dart';
import 'package:torneo_leon_de_juda/core/theme/app_spacing.dart';
import 'package:torneo_leon_de_juda/core/theme/app_typography.dart';
import 'package:torneo_leon_de_juda/features/dashboard/data/dashboard_repository.dart';
import 'package:torneo_leon_de_juda/features/dashboard/data/lider_player_detail.dart';
import 'package:torneo_leon_de_juda/shared/widgets/async_view.dart';

/// Form unificado para crear / editar un jugador. Si recibe `playerId`,
/// carga el jugador y permite editar (respetando lock-when-approved). Si no,
/// crea uno nuevo.
class MyPlayerFormScreen extends ConsumerWidget {
  const MyPlayerFormScreen({this.playerId, super.key});

  /// Si está presente, es modo "editar". Si es null, es "crear".
  final int? playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (playerId == null) {
      return const _FormView(initial: null);
    }
    final async = ref.watch(myPlayerDetailProvider(playerId!));
    return Scaffold(
      appBar: AppBar(title: const Text('Editar jugador')),
      body: AsyncView<LiderPlayerDetail>(
        value: async,
        onRetry: () => ref.invalidate(myPlayerDetailProvider(playerId!)),
        data: (player) => _FormView(initial: player),
      ),
    );
  }
}

class _FormView extends ConsumerStatefulWidget {
  const _FormView({required this.initial});
  final LiderPlayerDetail? initial;

  @override
  ConsumerState<_FormView> createState() => _FormViewState();
}

class _FormViewState extends ConsumerState<_FormView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _documentNumber;
  late final TextEditingController _church;
  late final TextEditingController _jerseyNumber;
  late final TextEditingController _jerseyName;
  late final TextEditingController _height;
  late final TextEditingController _weight;
  late final TextEditingController _specialReason;

  String _documentType = 'CC';
  String _bloodType = 'O+';
  String _position = 'mediocampista';
  String? _goalkeeperType;
  DateTime? _birthDate;
  bool _isCaptain = false;
  bool _hasEps = true;
  bool _specialRequest = false;
  bool _imageConsent = false;
  bool _habeasData = false;

  bool _submitting = false;
  String? _serverError;
  Map<String, String> _fieldErrors = {};

  bool get _isEditing => widget.initial != null;
  bool get _isApproved => widget.initial?.isApproved ?? false;
  bool get _isLocked => _isApproved;

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    _firstName = TextEditingController(text: p?.firstName ?? '');
    _lastName = TextEditingController(text: p?.lastName ?? '');
    _documentNumber = TextEditingController(text: p?.documentNumber ?? '');
    _church = TextEditingController(text: p?.church ?? '');
    _jerseyNumber = TextEditingController(
      text: p?.jerseyNumber.toString() ?? '',
    );
    _jerseyName = TextEditingController(text: p?.jerseyName ?? '');
    _height = TextEditingController(
      text: p?.height?.toStringAsFixed(0) ?? '',
    );
    _weight = TextEditingController(
      text: p?.weight?.toStringAsFixed(0) ?? '',
    );
    _specialReason = TextEditingController(text: p?.specialRequestReason ?? '');

    _documentType = p?.documentType ?? 'CC';
    _bloodType = p?.bloodType ?? 'O+';
    _position = p?.position ?? 'mediocampista';
    _goalkeeperType = p?.goalkeeperType;
    _birthDate = (p?.birthDate.isNotEmpty ?? false)
        ? DateTime.tryParse(p!.birthDate)
        : null;
    _isCaptain = p?.isCaptain ?? false;
    _hasEps = p?.hasEps ?? true;
    _specialRequest = p?.specialRequest ?? false;

    // En edición damos por aceptados los consentimientos (ya existen en DB)
    _imageConsent = _isEditing;
    _habeasData = _isEditing;
  }

  @override
  void dispose() {
    for (final c in [
      _firstName,
      _lastName,
      _documentNumber,
      _church,
      _jerseyNumber,
      _jerseyName,
      _height,
      _weight,
      _specialReason,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 25),
      firstDate: DateTime(1940),
      lastDate: now,
      locale: const Locale('es', 'CO'),
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  bool get _isMinor {
    if (_birthDate == null) return false;
    final years = DateTime.now().difference(_birthDate!).inDays ~/ 365;
    return years < 18;
  }

  Map<String, dynamic> _collectData() {
    final data = <String, dynamic>{
      'document_type': _documentType,
      'document_number': _documentNumber.text.trim(),
      'blood_type': _bloodType,
      'church': _church.text.trim().isEmpty ? null : _church.text.trim(),
      'position': _position,
      'goalkeeper_type': _position == 'portero' ? _goalkeeperType : null,
      'height': _height.text.trim().isEmpty ? null : num.tryParse(_height.text),
      'weight': _weight.text.trim().isEmpty ? null : num.tryParse(_weight.text),
      'is_captain': _isCaptain,
      'has_eps': _hasEps,
      'special_request': _specialRequest,
      'special_request_reason': _specialRequest
          ? _specialReason.text.trim()
          : null,
    };

    // Nombre/dorsal: solo si NO está bloqueado por approval
    if (!_isLocked) {
      data['first_name'] = _firstName.text.trim();
      data['last_name'] = _lastName.text.trim();
      data['jersey_number'] = int.tryParse(_jerseyNumber.text);
      data['jersey_name'] = _jerseyName.text.trim().isEmpty
          ? null
          : _jerseyName.text.trim();
    }

    if (_birthDate != null) {
      data['birth_date'] = DateFormat('yyyy-MM-dd').format(_birthDate!);
    }

    // En creación los consentimientos son requeridos
    if (!_isEditing) {
      data['image_consent'] = _imageConsent;
      data['habeas_data'] = _habeasData;
    }

    return data;
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _serverError = null;
      _fieldErrors = {};
    });

    final data = _collectData();
    final repo = ref.read(dashboardRepositoryProvider);

    try {
      final result = _isEditing
          ? await repo.updatePlayer(widget.initial!.id, data)
          : await repo.createPlayer(data);
      if (!mounted) return;
      // Invalida cachés para que la lista y detalle muestren cambios
      ref.invalidate(myPlayersProvider);
      ref.invalidate(myPlayerDetailProvider(result.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.victory,
          content: Text(
            _isEditing ? 'Jugador actualizado' : 'Jugador creado correctamente',
          ),
        ),
      );
      if (_isEditing) {
        context.pop();
      } else {
        // Después de crear, ir al detalle para que el líder cargue archivos
        context.pushReplacementNamed(
          AppRoute.myPlayerDetail.name,
          pathParameters: {'id': '${result.id}'},
        );
      }
    } on ValidationException catch (e) {
      if (!mounted) return;
      setState(() {
        _serverError = e.message;
        _fieldErrors = e.errors?.map(
              (k, v) => MapEntry(k, v.firstOrNull ?? ''),
            ) ??
            {};
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _serverError = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String? _required(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? '$label es obligatorio' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isEditing
          ? null
          : AppBar(title: const Text('Nuevo jugador')),
      body: AbsorbPointer(
        absorbing: _submitting,
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              if (_isLocked) const _LockedBanner(),
              if (_serverError != null) ...[
                _ErrorBanner(message: _serverError!),
                const SizedBox(height: AppSpacing.md),
              ],
              const _SectionTitle('Datos personales'),
              _TextField(
                controller: _firstName,
                label: 'Nombres',
                disabled: _isLocked,
                validator: (v) => _required(v, 'El nombre'),
                errorText: _fieldErrors['first_name'],
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp('[a-zA-ZáéíóúÁÉÍÓÚñÑ ]'),
                  ),
                ],
              ),
              _TextField(
                controller: _lastName,
                label: 'Apellidos',
                disabled: _isLocked,
                validator: (v) => _required(v, 'El apellido'),
                errorText: _fieldErrors['last_name'],
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp('[a-zA-ZáéíóúÁÉÍÓÚñÑ ]'),
                  ),
                ],
              ),
              _DropdownField<String>(
                label: 'Tipo de documento',
                value: _documentType,
                items: const {
                  'CC': 'Cédula de Ciudadanía',
                  'TI': 'Tarjeta de Identidad',
                  'CE': 'Cédula de Extranjería',
                  'PA': 'Pasaporte',
                  'RC': 'Registro Civil',
                },
                onChanged: (v) => setState(() => _documentType = v ?? 'CC'),
              ),
              _TextField(
                controller: _documentNumber,
                label: 'Número de documento',
                keyboardType: TextInputType.number,
                validator: (v) => _required(v, 'El documento'),
                errorText: _fieldErrors['document_number'],
              ),
              _DropdownField<String>(
                label: 'Tipo de sangre',
                value: _bloodType,
                items: const {
                  'O+': 'O+',
                  'O-': 'O-',
                  'A+': 'A+',
                  'A-': 'A-',
                  'B+': 'B+',
                  'B-': 'B-',
                  'AB+': 'AB+',
                  'AB-': 'AB-',
                },
                onChanged: (v) => setState(() => _bloodType = v ?? 'O+'),
              ),
              _DateField(
                label: 'Fecha de nacimiento',
                value: _birthDate,
                onTap: _pickBirthDate,
              ),
              if (_isMinor) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                  ),
                  child: Text(
                    '⚠ Menor de edad: deberás subir el consentimiento de '
                    'padres en la pantalla de Archivos.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.warning,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
              _TextField(
                controller: _church,
                label: 'Iglesia (opcional)',
                errorText: _fieldErrors['church'],
              ),

              const SizedBox(height: AppSpacing.lg),
              const _SectionTitle('Equipo y posición'),
              _TextField(
                controller: _jerseyNumber,
                label: 'Número de dorsal (1-99)',
                disabled: _isLocked,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (_isLocked) return null;
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 1 || n > 99) {
                    return 'Debe estar entre 1 y 99';
                  }
                  return null;
                },
                errorText: _fieldErrors['jersey_number'],
              ),
              _TextField(
                controller: _jerseyName,
                label: 'Nombre en dorsal (opcional)',
                disabled: _isLocked,
                errorText: _fieldErrors['jersey_name'],
              ),
              _DropdownField<String>(
                label: 'Posición',
                value: _position,
                items: const {
                  'portero': 'Portero',
                  'defensa': 'Defensa',
                  'mediocampista': 'Mediocampista',
                  'delantero': 'Delantero',
                },
                onChanged: (v) {
                  setState(() {
                    _position = v ?? 'mediocampista';
                    if (_position != 'portero') _goalkeeperType = null;
                  });
                },
              ),
              if (_position == 'portero')
                _DropdownField<String?>(
                  label: 'Tipo de portero',
                  value: _goalkeeperType,
                  nullable: true,
                  items: const {
                    'titular': 'Titular',
                    'suplente': 'Suplente',
                  },
                  onChanged: (v) => setState(() => _goalkeeperType = v),
                ),
              Row(
                children: [
                  Expanded(
                    child: _TextField(
                      controller: _height,
                      label: 'Estatura (cm)',
                      keyboardType: TextInputType.number,
                      errorText: _fieldErrors['height'],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _TextField(
                      controller: _weight,
                      label: 'Peso (kg)',
                      keyboardType: TextInputType.number,
                      errorText: _fieldErrors['weight'],
                    ),
                  ),
                ],
              ),
              SwitchListTile.adaptive(
                value: _isCaptain,
                onChanged: (v) => setState(() => _isCaptain = v),
                title: const Text('¿Es capitán del equipo?'),
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: AppSpacing.lg),
              const _SectionTitle('Documentación EPS'),
              SwitchListTile.adaptive(
                value: _hasEps,
                onChanged: (v) => setState(() => _hasEps = v),
                title: const Text('¿Tiene EPS?'),
                subtitle: Text(
                  _hasEps
                      ? 'Sube el certificado en la pantalla de Archivos.'
                      : 'Sube el consentimiento firmado en la pantalla de Archivos.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: AppSpacing.lg),
              const _SectionTitle('Solicitud especial'),
              SwitchListTile.adaptive(
                value: _specialRequest,
                onChanged: (v) => setState(() => _specialRequest = v),
                title: const Text('¿Solicitud especial?'),
                subtitle: Text(
                  'Marca esto si necesitas inscribir un jugador adicional '
                  '(más de 12 en el equipo).',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                contentPadding: EdgeInsets.zero,
              ),
              if (_specialRequest)
                _TextField(
                  controller: _specialReason,
                  label: 'Motivo de la solicitud especial',
                  maxLines: 3,
                  validator: (v) {
                    if (!_specialRequest) return null;
                    return _required(v, 'El motivo');
                  },
                  errorText: _fieldErrors['special_request_reason'],
                ),

              if (!_isEditing) ...[
                const SizedBox(height: AppSpacing.lg),
                const _SectionTitle('Consentimientos obligatorios'),
                CheckboxListTile.adaptive(
                  value: _imageConsent,
                  onChanged: (v) => setState(() => _imageConsent = v ?? false),
                  title: const Text('Autorización de uso de imagen'),
                  subtitle: Text(
                    'Autorizo el uso de fotografías y videos del jugador para '
                    'fines del torneo, redes sociales y material promocional.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile.adaptive(
                  value: _habeasData,
                  onChanged: (v) => setState(() => _habeasData = v ?? false),
                  title: const Text('Habeas Data — Ley 1581 de 2012'),
                  subtitle: Text(
                    'Autorizo el tratamiento de datos personales para uso '
                    'exclusivo en la gestión del torneo.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              ],

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
                      : const Icon(Icons.save_rounded),
                  label: Text(
                    _submitting
                        ? 'Guardando…'
                        : (_isEditing ? 'Guardar cambios' : 'Crear jugador'),
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.huge),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xxs,
        bottom: AppSpacing.sm,
      ),
      child: Text(
        text.toUpperCase(),
        style: AppTypography.labelLarge.copyWith(color: AppColors.primary),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
    this.errorText,
    this.disabled = false,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final String? errorText;
  final bool disabled;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: TextFormField(
        controller: controller,
        enabled: !disabled,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          filled: true,
          fillColor: disabled
              ? AppColors.surfaceHigh
              : AppColors.surfaceLow,
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
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.nullable = false,
  });

  final String label;
  final T value;
  final Map<T, String> items;
  final ValueChanged<T?> onChanged;
  final bool nullable;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: DropdownButtonFormField<T>(
        value: value,
        onChanged: onChanged,
        items: [
          if (nullable)
            const DropdownMenuItem(
              child: Text('Sin especificar'),
            ),
          for (final entry in items.entries)
            DropdownMenuItem(value: entry.key, child: Text(entry.value)),
        ],
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.surfaceLow,
          border: const OutlineInputBorder(
            borderRadius: AppRadius.brSm,
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: AppRadius.brSm,
            borderSide: BorderSide(color: AppColors.border),
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final formatted = value != null
        ? DateFormat("d 'de' MMMM 'de' y", 'es_CO').format(value!)
        : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.brSm,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: AppColors.surfaceLow,
            suffixIcon: const Icon(Icons.calendar_today_rounded),
            border: const OutlineInputBorder(
              borderRadius: AppRadius.brSm,
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: AppRadius.brSm,
              borderSide: BorderSide(color: AppColors.border),
            ),
          ),
          child: Text(
            formatted ?? 'Selecciona una fecha',
            style: AppTypography.bodyMedium.copyWith(
              color: formatted != null
                  ? AppColors.textPrimary
                  : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _LockedBanner extends StatelessWidget {
  const _LockedBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: AppRadius.brSm,
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            color: AppColors.warning,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              'Jugador aprobado: nombre, apellido y dorsal están bloqueados. '
              'Genera una PQRS si necesitas cambiar estos datos.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.defeatTint,
        borderRadius: AppRadius.brSm,
        border: Border.all(color: AppColors.defeat.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.defeat,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
