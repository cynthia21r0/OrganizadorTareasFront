import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
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

  bool _obscure = true;
  bool _joiningFamily = false; // false = crear familia nueva, true = unirse con código
  FamilyRole _role = FamilyRole.padre;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _familyNameCtrl.dispose();
    _inviteCodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      name: _nameCtrl.text,
      email: _emailCtrl.text,
      password: _passCtrl.text,
      role: _role,
      familyName: _joiningFamily ? null : _familyNameCtrl.text,
      inviteCode: _joiningFamily ? _inviteCodeCtrl.text : null,
    );
    if (!mounted) return;
    if (ok) {
      final msg = _joiningFamily
          ? 'Cuenta creada. Ahora inicia sesión.'
          : 'Familia creada. Código de invitación: ${auth.lastInviteCode}\nCompártelo con tu familia. Ahora inicia sesión.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Error al registrarse')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 8),
                const Text('Únete a tu familia',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 20),

                // Selector: crear familia nueva vs unirse con código
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('Crear familia')),
                    ButtonSegment(value: true, label: Text('Unirme con código')),
                  ],
                  selected: {_joiningFamily},
                  onSelectionChanged: (s) => setState(() => _joiningFamily = s.first),
                ),
                const SizedBox(height: 16),

                if (!_joiningFamily)
                  TextFormField(
                    controller: _familyNameCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre de la familia', prefixIcon: Icon(Icons.home_outlined)),
                    validator: (v) => _joiningFamily ? null : Validators.required(v, field: 'El nombre de la familia'),
                  )
                else
                  TextFormField(
                    controller: _inviteCodeCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(labelText: 'Código de invitación', prefixIcon: Icon(Icons.key_outlined)),
                    validator: (v) => !_joiningFamily ? null : Validators.required(v, field: 'El código de invitación'),
                  ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre completo', prefixIcon: Icon(Icons.person_outline)),
                  validator: (v) => Validators.required(v, field: 'El nombre'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<FamilyRole>(
                  value: _role,
                  decoration: const InputDecoration(labelText: 'Rol en la familia', prefixIcon: Icon(Icons.diversity_3_outlined)),
                  items: FamilyRole.values
                      .map((r) => DropdownMenuItem(value: r, child: Text(r.label)))
                      .toList(),
                  onChanged: (v) => setState(() => _role = v!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Correo electrónico', prefixIcon: Icon(Icons.email_outlined)),
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: Validators.password,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: _obscure,
                  decoration: const InputDecoration(labelText: 'Confirmar contraseña', prefixIcon: Icon(Icons.lock_outline)),
                  validator: (v) => Validators.confirmPassword(v, _passCtrl.text),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: auth.isLoading ? null : _submit,
                  child: auth.isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(_joiningFamily ? 'Unirme a la familia' : 'Crear familia y registrarme'),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Ya tengo una cuenta'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}