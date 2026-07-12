import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Utilidades de autenticación. En un entorno productivo con backend
/// (NestJS/Elysia) este hash se haría en el servidor con bcrypt/argon2;
/// aquí, al ser una app 100% local con SQLite, hasheamos con SHA-256
/// + salt fijo por app para no guardar contraseñas en texto plano.
class AuthService {
  AuthService._();

  static const String _salt = 'gestor_tareas_salt_v1';

  static String hashPassword(String plainPassword) {
    final bytes = utf8.encode('$plainPassword$_salt');
    return sha256.convert(bytes).toString();
  }

  static bool verifyPassword(String plainPassword, String hash) {
    return hashPassword(plainPassword) == hash;
  }
}
