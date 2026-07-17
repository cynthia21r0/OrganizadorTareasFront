import 'package:flutter/material.dart';

/// Paletas de acento disponibles para personalizar la app.
enum AppAccent {
  azul,
  violeta,
  rosa,
  verde,
  naranja,
  cian,
  indigo,
}

extension AppAccentExtension on AppAccent {
  String get label {
    switch (this) {
      case AppAccent.azul:
        return 'Azul';
      case AppAccent.violeta:
        return 'Violeta';
      case AppAccent.rosa:
        return 'Rosa';
      case AppAccent.verde:
        return 'Verde';
      case AppAccent.naranja:
        return 'Naranja';
      case AppAccent.cian:
        return 'Cian';
      case AppAccent.indigo:
        return 'Índigo';
    }
  }

  /// Color principal del acento (usado como seedColor en Material 3).
  Color get primary {
    switch (this) {
      case AppAccent.azul:
        return const Color(0xFF5B8DEE);
      case AppAccent.violeta:
        return const Color(0xFFA88BEE);
      case AppAccent.rosa:
        return const Color(0xFFE8527A);
      case AppAccent.verde:
        return const Color(0xFF4CAF7D);
      case AppAccent.naranja:
        return const Color(0xFFE08B3A);
      case AppAccent.cian:
        return const Color(0xFF00BCD4);
      case AppAccent.indigo:
        return const Color(0xFF3F51B5);
    }
  }

  /// Color de inicio del gradiente del resumen.
  Color get gradientStart {
    switch (this) {
      case AppAccent.azul:
        return const Color(0xFF6FA3EE);
      case AppAccent.violeta:
        return const Color(0xFFBBA3F5);
      case AppAccent.rosa:
        return const Color(0xFFF08090);
      case AppAccent.verde:
        return const Color(0xFF66C993);
      case AppAccent.naranja:
        return const Color(0xFFF5A55A);
      case AppAccent.cian:
        return const Color(0xFF26D0E2);
      case AppAccent.indigo:
        return const Color(0xFF5C6BC0);
    }
  }
}
