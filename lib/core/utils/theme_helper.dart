import 'package:flutter/material.dart';

/// Helper para obtener colores según el tema actual (claro/oscuro)
/// TODOS los widgets deben usar esto en lugar de colores hardcoded
class ThemeHelper {
  final BuildContext context;
  final bool isDark;

  ThemeHelper(this.context) : isDark = Theme.of(context).brightness == Brightness.dark;

  // ===========================
  // COLORES DE FONDO
  // ===========================
  Color get scaffoldBackground => isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5);
  Color get cardBackground => isDark ? const Color(0xFF1E1E1E) : Colors.white;
  Color get surfaceColor => isDark ? const Color(0xFF2C2C2C) : Colors.grey[100]!;
  Color get inputFillColor => isDark ? const Color(0xFF2C2C2C) : Colors.grey[100]!;

  // ===========================
  // COLORES DE TEXTO
  // ===========================
  Color get textPrimary => isDark ? Colors.white : const Color(0xFF212121);
  Color get textSecondary => isDark ? Colors.grey[400]! : Colors.grey[600]!;
  Color get textHint => isDark ? Colors.grey[500]! : Colors.grey[400]!;

  // ===========================
  // COLORES DE BORDES
  // ===========================
  Color get borderColor => isDark ? Colors.grey[700]! : Colors.grey[300]!;
  Color get dividerColor => isDark ? Colors.grey[800]! : Colors.grey[200]!;

  // ===========================
  // COLORES DE ACENTO (NO CAMBIAN)
  // ===========================
  Color get primary => const Color(0xFF2196F3);
  Color get primaryDark => const Color(0xFF1976D2);
  Color get success => const Color(0xFF4CAF50);
  Color get error => const Color(0xFFE53935);
  Color get warning => const Color(0xFFFF9800);
  Color get info => const Color(0xFF607D8B);

  // ===========================
  // COLORES CON OPACIDAD
  // ===========================
  Color primaryWithOpacity(double opacity) => primary.withOpacity(opacity);
  Color successWithOpacity(double opacity) => success.withOpacity(opacity);
  Color errorWithOpacity(double opacity) => error.withOpacity(opacity);
  Color warningWithOpacity(double opacity) => warning.withOpacity(opacity);

  // ===========================
  // COLORES DE ICONOS
  // ===========================
  Color get iconColor => isDark ? Colors.grey[400]! : Colors.grey[600]!;
  Color get iconColorLight => isDark ? Colors.grey[500]! : Colors.grey[500]!;

  // ===========================
  // OVERLAY (para diálogos, modales)
  // ===========================
  Color get overlayColor => isDark 
      ? Colors.black.withOpacity(0.7) 
      : Colors.black.withOpacity(0.5);

  // ===========================
  // SOMBRAS (más suaves en modo oscuro)
  // ===========================
  List<BoxShadow> get cardShadow => isDark 
      ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ]
      : [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ];

  // ===========================
  // HELPER PARA APPBAR
  // ===========================
  Color get appBarBackground => isDark ? const Color(0xFF1E1E1E) : const Color(0xFF2196F3);
  Color get appBarForeground => Colors.white; // Siempre blanco

  // ===========================
  // HELPER PARA BOTONES
  // ===========================
  Color get buttonPrimary => const Color(0xFF4CAF50);
  Color get buttonSecondary => const Color(0xFF2196F3);
  Color get buttonDanger => const Color(0xFFE53935);

  // ===========================
  // ESTADOS (sin cambios)
  // ===========================
  Color get successLight => const Color(0xFF66BB6A);
  Color get errorLight => const Color(0xFFE57373);
  Color get warningLight => const Color(0xFFFFB74D);
}