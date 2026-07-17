import 'package:flutter/material.dart';
import '../core/storage/secure_storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  /// Llama esto al inicio de la app para restaurar la preferencia guardada.
  Future<void> loadSavedTheme() async {
    final isDark = await SecureStorageService.instance.readThemeMode();
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  /// Alterna entre claro y oscuro, y persiste la elección.
  Future<void> toggle() async {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    await SecureStorageService.instance.saveThemeMode(isDark: isDark);
  }
}
