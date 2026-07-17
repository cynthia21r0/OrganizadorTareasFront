import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _familyNameCtrl = TextEditingController();
  final _inviteCodeCtrl = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  final _confirmFocus = FocusNode();
  final _familyFocus = FocusNode();
  final _inviteFocus = FocusNode();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _joiningFamily = false;
  FamilyRole _role = FamilyRole.padre;

  @override
  void initState() {
    super.initState();
    void refreshUI() => setState(() {});
    _nameFocus.addListener(refreshUI);
    _emailFocus.addListener(refreshUI);
    _passFocus.addListener(refreshUI);
    _confirmFocus.addListener(refreshUI);
    _familyFocus.addListener(refreshUI);
    _inviteFocus.addListener(refreshUI);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _familyNameCtrl.dispose();
    _inviteCodeCtrl.dispose();

    _nameFocus.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    _confirmFocus.dispose();
    _familyFocus.dispose();
    _inviteFocus.dispose();
    super.dispose();
  }

  bool get _hasMinLength => _passCtrl.text.length >= 8;
  bool get _hasUppercase => _passCtrl.text.contains(RegExp(r'[A-Z]'));
  bool get _hasLowercase => _passCtrl.text.contains(RegExp(r'[a-z]'));
  bool get _hasNumber => _passCtrl.text.contains(RegExp(r'[0-9]'));
  bool get _hasSpecial =>
      _passCtrl.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  bool get _isPasswordValid =>
      _hasMinLength &&
      _hasUppercase &&
      _hasLowercase &&
      _hasNumber &&
      _hasSpecial;

  bool get _isFormReady {
    if (_nameCtrl.text.trim().isEmpty) return false;
    if (_emailCtrl.text.trim().isEmpty) return false;
    if (!_isPasswordValid) return false;
    if (_confirmCtrl.text.isEmpty || _confirmCtrl.text != _passCtrl.text)
      return false;

    if (_joiningFamily && _inviteCodeCtrl.text.trim().length != 8) return false;
    if (!_joiningFamily && _familyNameCtrl.text.trim().isEmpty) return false;

    return true;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Revisa los campos marcados en rojo.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      role: _role,
      familyName: _joiningFamily ? null : _familyNameCtrl.text.trim(),
      inviteCode: _joiningFamily ? _inviteCodeCtrl.text.trim() : null,
    );

    if (!mounted) return;

    if (ok) {
      final msg = _joiningFamily
          ? '¡Cuenta creada con éxito! Bienvenido a la familia.'
          : 'Familia creada. Código: ${auth.lastInviteCode}\nCompártelo para que otros se unan.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Error al registrarte.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().length < 3)
      return 'Debe tener al menos 3 caracteres.';
    if (!RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$").hasMatch(value.trim()))
      return 'Solo letras y espacios.';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty)
      return 'El correo es obligatorio.';
    if (!RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(value.trim())) {
      return 'Ingresa un correo válido (ej. juan@gmail.com).';
    }
    return null;
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isMet
                ? Colors.green
                : AppColors.textSecondary.withOpacity(0.5),
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isMet ? Colors.green : AppColors.textSecondary,
              fontSize: 12.5,
              decoration: isMet ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Crear cuenta'), elevation: 0),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    '¡Comencemos!',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Text(
                    'Configura tu espacio familiar en pocos pasos.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                        value: false,
                        label: Text('Crear familia'),
                        icon: Icon(Icons.add_home_work_outlined),
                      ),
                      ButtonSegment(
                        value: true,
                        label: Text('Unirme a una'),
                        icon: Icon(Icons.group_add_outlined),
                      ),
                    ],
                    selected: {_joiningFamily},
                    onSelectionChanged: (s) {
                      setState(() {
                        _joiningFamily = s.first;
                        if (_joiningFamily)
                          _familyNameCtrl.clear();
                        else
                          _inviteCodeCtrl.clear();
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  if (!_joiningFamily)
                    TextFormField(
                      controller: _familyNameCtrl,
                      focusNode: _familyFocus,
                      onChanged: (_) => setState(() {}),
                      textCapitalization: TextCapitalization.words,
                      maxLength: 30,
                      decoration: InputDecoration(
                        labelText: 'Nombre de la familia',
                        helperText: _familyFocus.hasFocus
                            ? 'Así es como todos verán el hogar.'
                            : null,
                        prefixIcon: const Icon(Icons.home_outlined),
                        counterText: "",
                      ),
                    )
                  else
                    TextFormField(
                      controller: _inviteCodeCtrl,
                      focusNode: _inviteFocus,
                      onChanged: (_) => setState(() {}),
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 8,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9]'),
                        ),
                        TextInputFormatter.withFunction(
                          (old, newVal) =>
                              newVal.copyWith(text: newVal.text.toUpperCase()),
                        ),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Código de invitación',
                        helperText: _inviteFocus.hasFocus
                            ? 'Pídeselo al creador de la familia.'
                            : null,
                        prefixIcon: const Icon(Icons.key_outlined),
                        counterText: "",
                      ),
                    ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _nameCtrl,
                    focusNode: _nameFocus,
                    onChanged: (_) => setState(() {}),
                    textCapitalization: TextCapitalization.words,
                    maxLength: 50,
                    decoration: InputDecoration(
                      labelText: 'Tu nombre',
                      helperText: _nameFocus.hasFocus
                          ? 'Como te identificarán en las tareas.'
                          : null,
                      prefixIcon: const Icon(Icons.person_outline),
                      counterText: "",
                    ),
                    validator: _validateName,
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<FamilyRole>(
                    value: _role,
                    decoration: const InputDecoration(
                      labelText: 'Rol en la familia',
                      prefixIcon: Icon(Icons.diversity_3_outlined),
                    ),
                    items: FamilyRole.values
                        .map(
                          (r) =>
                              DropdownMenuItem(value: r, child: Text(r.label)),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _role = v!),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _emailCtrl,
                    focusNode: _emailFocus,
                    onChanged: (_) => setState(() {}),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Correo electrónico',
                      helperText: _emailFocus.hasFocus
                          ? 'Lo usarás para iniciar sesión.'
                          : null,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passCtrl,
                    focusNode: _passFocus,
                    onChanged: (_) => setState(() {}),
                    obscureText: _obscurePass,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePass
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePass = !_obscurePass),
                      ),
                    ),
                    validator: (v) =>
                        _passCtrl.text.isNotEmpty && !_isPasswordValid
                        ? 'La contraseña no cumple todos los requisitos'
                        : null,
                  ),

                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: (_passFocus.hasFocus || _passCtrl.text.isNotEmpty)
                        ? 120
                        : 0,
                    curve: Curves.easeInOut,
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(),
                    margin: const EdgeInsets.only(top: 8, left: 12),
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRequirement(
                            'Al menos 8 caracteres',
                            _hasMinLength,
                          ),
                          _buildRequirement(
                            'Una letra mayúscula (A-Z)',
                            _hasUppercase,
                          ),
                          _buildRequirement(
                            'Una letra minúscula (a-z)',
                            _hasLowercase,
                          ),
                          _buildRequirement(
                            'Al menos un número (0-9)',
                            _hasNumber,
                          ),
                          _buildRequirement(
                            'Un símbolo especial (@, #, !, etc.)',
                            _hasSpecial,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _confirmCtrl,
                    focusNode: _confirmFocus,
                    onChanged: (_) => setState(() {}),
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      labelText: 'Confirmar contraseña',
                      helperText: _confirmFocus.hasFocus
                          ? 'Debe coincidir exactamente.'
                          : null,
                      prefixIcon: const Icon(Icons.lock_reset_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    validator: (v) =>
                        (v != null && v.isNotEmpty && v != _passCtrl.text)
                        ? 'Las contraseñas no coinciden.'
                        : null,
                  ),

                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: (_isFormReady && !auth.isLoading)
                        ? _submit
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: auth.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _joiningFamily
                                ? 'Unirme a la familia'
                                : 'Crear familia y registrarme',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),

                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        '¿Ya tienes una cuenta? Inicia sesión aquí',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
