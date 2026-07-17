import 'package:flutter/material.dart';
import '../core/storage/secure_storage_service.dart';
import '../core/theme/app_accent.dart';
import '../core/theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  AppAccent _accent = AppAccent.azul;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;
  AppAccent get accent => _accent;

  ThemeData get lightTheme => AppTheme.lightThemeFor(_accent);
  ThemeData get darkTheme => AppTheme.darkThemeFor(_accent);

  /// Carga el tema y el acento guardados al iniciar la app.
  Future<void> loadSavedTheme() async {
    final isDark = await SecureStorageService.instance.readThemeMode();
    final accentName = await SecureStorageService.instance.readAccent();
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    if (accentName != null) {
      _accent = AppAccent.values.firstWhere(
        (a) => a.name == accentName,
        orElse: () => AppAccent.azul,
      );
    }
    notifyListeners();
  }

  /// Alterna entre claro y oscuro, y persiste la elección.
  Future<void> toggle() async {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    await SecureStorageService.instance.saveThemeMode(isDark: isDark);
  }

  /// Cambia el color de acento y persiste la elección.
  Future<void> setAccent(AppAccent accent) async {
    if (_accent == accent) return;
    _accent = accent;
    notifyListeners();
    await SecureStorageService.instance.saveAccent(accent.name);
  }
}
