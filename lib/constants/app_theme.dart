// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

class AppTheme {
  static const Color lacRed = Color(0xFF8B1515);        // Đỏ son phong cách sơn mài
  static const Color lacDarkRed = Color(0xFF580A0A);    // Đỏ sẫm
  static const Color dongGold = Color(0xFFC59B27);      // Vàng đồng cổ
  static const Color paperBg = Color(0xFFFCF8F2);       // Giấy điệp truyền thống
  static const Color cardBg = Color(0xFFFFFDF9);        // Trắng giấy lụa
  static const Color inkBlack = Color(0xFF2B2621);      // Mực tàu / Đen xám cổ
  static const Color subtleBorder = Color(0xFFE6DBCB);  // Đường viền chỉ gấm

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: paperBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: lacRed,
        primary: lacRed,
        secondary: dongGold,
        surface: cardBg,
        onSurface: inkBlack,
      ),
      fontFamily: 'serif',
      appBarTheme: const AppBarTheme(
        backgroundColor: lacDarkRed,
        foregroundColor: Color(0xFFFFFDF9),
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Color(0xFFFFFDF9),
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'serif',
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: subtleBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lacRed,
          foregroundColor: const Color(0xFFFFFDF9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: const BorderSide(color: dongGold),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'serif'),
        ),
      ),
    );
  }
}
