import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class AuthRepository {
  final _db = DatabaseService.instance;
  final _uuid = const Uuid();

  /// Registro (CREATE). El primer usuario registrado en la app
  /// queda como 'admin' (gestiona a la familia); los siguientes,
  /// como 'member'.
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final db = await _db.database;

    final existing = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
    );
    if (existing.isNotEmpty) {
      throw Exception('Ya existe una cuenta con ese correo');
    }

    final countResult = await db.rawQuery('SELECT COUNT(*) as total FROM users');
    final isFirstUser = (countResult.first['total'] as int) == 0;

    final user = UserModel(
      id: _uuid.v4(),
      name: name.trim(),
      email: email.trim().toLowerCase(),
      passwordHash: AuthService.hashPassword(password),
      role: isFirstUser ? UserRole.admin : UserRole.member,
    );

    await db.insert('users', user.toMap());
    return user;
  }

  /// Login (READ + verificación)
  Future<UserModel> login({required String email, required String password}) async {
    final db = await _db.database;
    final results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
    );

    if (results.isEmpty) {
      throw Exception('No existe una cuenta con ese correo');
    }

    final user = UserModel.fromMap(results.first);
    final valid = AuthService.verifyPassword(password, user.passwordHash);
    if (!valid) {
      throw Exception('Contraseña incorrecta');
    }
    return user;
  }

  /// Lista todos los miembros de la familia (READ)
  Future<List<UserModel>> getAllUsers() async {
    final db = await _db.database;
    final results = await db.query('users', orderBy: 'name ASC');
    return results.map((m) => UserModel.fromMap(m)).toList();
  }

  /// Actualiza datos de un usuario (UPDATE)
  Future<void> updateUser(UserModel user) async {
    final db = await _db.database;
    await db.update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  /// Elimina un usuario (DELETE)
  Future<void> deleteUser(String id) async {
    final db = await _db.database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}
