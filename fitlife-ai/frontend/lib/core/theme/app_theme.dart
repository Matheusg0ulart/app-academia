import 'package:flutter/material.dart';

class AppTheme {
  // Cores principais da marca (Fitness + Saúde + Tecnologia)
  static const Color primaryColor = Color(0xFF00E676); // Verde Esmeralda vibrante
  static const Color primaryDark = Color(0xFF00B248);
  static const Color darkBackground = Color(0xFF12181B); // Slate Escuro elegante
  static const Color cardDarkBackground = Color(0xFF1E262C);
  static const Color textPrimaryLight = Color(0xFFF5F7FA);

  /// Tema Escuro Principal (Material 3)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: Color(0xFF00E5FF), // Ciano Tecnológico
        surface: cardDarkBackground,
        onSurface: textPrimaryLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimaryLight,
        ),
      ),
      cardTheme: CardTheme(
        color: cardDarkBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.black,
          elevation: 3,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
