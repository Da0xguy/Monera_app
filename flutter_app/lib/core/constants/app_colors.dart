// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Brand palette
  static const Color darkGreen = Color(0xFF063D2E);
  static const Color lime = Color(0xFFB7FF3B);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Screen-matched modern light background and surface system
  static const Color background = Color(0xFFF5F6F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFF8FAFC);
  static const Color surfaceCard = Color(0xFFFFFFFF);

  // Accents & interactive colors
  static const Color primaryAccent = darkGreen;
  static const Color primaryBlue = darkGreen;
  static const Color electricBlue = darkGreen;
  static const Color lightBlue = Color(0xFF10B981);
  static const Color deepNavy = darkGreen;
  static const Color cobaltBlue = Color(0xFF0F5132);

  // Functional Status
  static const Color emeraldGreen = Color(0xFF10B981);
  static const Color amberWarning = Color(0xFFD97706);
  static const Color crimsonRed = Color(0xFFDC2626);

  // Typography for light background
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);

  // Borders & Dividers
  static const Color borderSubtle = Color(0xFFE2E8F0);
  static const Color borderGlow = Color(0xFFCBD5E1);

  // Total Balance Card: Deep obsidian with subtle emerald sheen
  static const LinearGradient balanceCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF141E1A),
      Color(0xFF07120E),
    ],
  );

  static const LinearGradient virtualCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF063D2E),
      Color(0xFF0B5943),
    ],
  );

  static const LinearGradient frozenCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF64748B),
      Color(0xFF475569),
    ],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF063D2E),
      Color(0xFF0B5943),
    ],
  );
}
