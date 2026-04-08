// lib/utils/constants.dart
import 'package:flutter/material.dart';

class AppConstants {
  // ─── BASE URL ────────────────────────────────────────────────────────────────
  // Untuk emulator Android gunakan 10.0.2.2, untuk device fisik ganti ke IP lokal
  // static const String baseUrl = 'http://10.0.2.2:5000';
  static const String baseUrl = "http://localhost:5000";
  // static const String baseUrl = 'http://192.168.x.x:5000'; // device fisik

  // ─── ENDPOINTS ───────────────────────────────────────────────────────────────
  static const String loginUrl       = '$baseUrl/login';
  static const String logoutUrl      = '$baseUrl/logout';
  static const String meUrl          = '$baseUrl/me';
  static const String usersUrl       = '$baseUrl/users';
  static const String beritasUrl     = '$baseUrl/beritas';
  static const String agendasUrl     = '$baseUrl/agendas';
  static const String kategoriUrl    = '$baseUrl/kategori';
  static const String tagUrl         = '$baseUrl/tag';
  static const String anggotas       = '$baseUrl/anggotas';

  // ─── APP INFO ────────────────────────────────────────────────────────────────
  static const String appName      = 'P3M Admin';
  static const String appSubtitle  = 'Pusat Penelitian & Pengabdian Masyarakat';

  // ─── COOKIE KEY ──────────────────────────────────────────────────────────────
  static const String sessionCookieKey = 'p3m_session';
}

class AppColors {
  // Primary palette — deep navy/teal inspired
  static const Color primary        = Color(0xFF1A3C5E);
  static const Color primaryLight   = Color(0xFF2D6A9F);
  static const Color primaryDark    = Color(0xFF0F2439);
  static const Color accent         = Color(0xFF00B4D8);
  static const Color accentLight    = Color(0xFF90E0EF);

  // Status colors
  static const Color verified       = Color(0xFF2E7D32);
  static const Color verifiedBg     = Color(0xFFE8F5E9);
  static const Color pending        = Color(0xFFF57C00);
  static const Color pendingBg      = Color(0xFFFFF3E0);
  static const Color rejected       = Color(0xFFC62828);
  static const Color rejectedBg     = Color(0xFFFFEBEE);

  // Neutral
  static const Color background     = Color(0xFFF5F7FA);
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color border         = Color(0xFFE8ECF0);
  static const Color textPrimary    = Color(0xFF1A2332);
  static const Color textSecondary  = Color(0xFF6B7A8D);
  static const Color textHint       = Color(0xFFADB5C0);

  // Dashboard stat card colors
  static const Color cardBlue       = Color(0xFF1565C0);
  static const Color cardGreen      = Color(0xFF2E7D32);
  static const Color cardAmber      = Color(0xFFF57C00);
  static const Color cardRed        = Color(0xFFC62828);
}

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      hintStyle: const TextStyle(
        color: AppColors.textHint,
        fontSize: 14,
        fontFamily: 'Poppins',
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
  );
}