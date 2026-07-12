import 'package:flutter/material.dart';

/// Paleta de colores extraída del diseño de Figma (pantalla "Inicio").
/// Mantener estos valores centralizados evita repetir hex codes
/// por toda la app y facilita ajustar el theme en un solo lugar.
class AppColors {
  AppColors._();

  // Fondo general de la app (azul muy claro)
  static const Color background = Color(0xFFEAF2FB);

  // Tarjeta de resumen técnico (azul medio)
  static const Color summaryCardStart = Color(0xFF6FA3EE);
  static const Color summaryCardEnd = Color(0xFF5B8DEE);

  // Botón flotante "Nueva tarea"
  static const Color fabPurple = Color(0xFFA88BEE);

  // Barra de navegación inferior
  static const Color navBackground = Color(0xFFFFFFFF);
  static const Color navActive = Color(0xFF5B8DEE);
  static const Color navInactive = Color(0xFF9AA5B1);
  static const Color navActiveBg = Color(0xFFDCE8FB);

  // Prioridades: Baja = Verde, Media = Azul, Alta = Salmón
  static const Color priorityLow = Color(0xFF4CAF7D);
  static const Color priorityLowBg = Color(0xFFDFF5E7);
  static const Color priorityMedium = Color(0xFF4A7FD6);
  static const Color priorityMediumBg = Color(0xFFDCE8FB);
  static const Color priorityHigh = Color(0xFFE0645B);
  static const Color priorityHighBg = Color(0xFFFBDCDC);

  // Estados de tarjeta de tarea
  static const Color pendingStripe = Color(0xFFE0645B); // se sobreescribe según prioridad
  static const Color pendingChipBg = Color(0xFFDCE8FB);
  static const Color pendingChipText = Color(0xFF4A7FD6);

  static const Color completedBg = Color(0xFFDFF5E7);
  static const Color completedCheck = Color(0xFF4CAF7D);

  // Texto
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);

  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFE0645B);
}
