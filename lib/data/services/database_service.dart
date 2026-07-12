import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Servicio único (singleton) que administra la conexión a SQLite.
/// Toda la app comparte esta misma instancia de base de datos.
class DatabaseService {
  DatabaseService._internal();
  static final DatabaseService instance = DatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'gestor_tareas.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password_hash TEXT NOT NULL,
            role TEXT NOT NULL DEFAULT 'member'
          )
        ''');

        await db.execute('''
          CREATE TABLE tasks (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT,
            due_date TEXT NOT NULL,
            priority TEXT NOT NULL DEFAULT 'media',
            status TEXT NOT NULL DEFAULT 'pendiente',
            assigned_to_id TEXT NOT NULL,
            created_by_id TEXT NOT NULL,
            FOREIGN KEY (assigned_to_id) REFERENCES users (id),
            FOREIGN KEY (created_by_id) REFERENCES users (id)
          )
        ''');
      },
    );
  }
}
