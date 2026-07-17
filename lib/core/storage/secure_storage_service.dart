import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService._();
  static final SecureStorageService instance = SecureStorageService._();

  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _themeKey = 'is_dark_mode';
  static const _accentKey = 'accent_color';

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> deleteToken() => _storage.delete(key: _tokenKey);

  Future<void> saveThemeMode({required bool isDark}) =>
      _storage.write(key: _themeKey, value: isDark ? '1' : '0');

  Future<bool> readThemeMode() async {
    final val = await _storage.read(key: _themeKey);
    return val == '1';
  }

  Future<void> saveAccent(String accentName) =>
      _storage.write(key: _accentKey, value: accentName);

  Future<String?> readAccent() => _storage.read(key: _accentKey);
}