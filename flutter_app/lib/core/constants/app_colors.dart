// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Client-approved palette
  static const Color darkGreen = Color(0xFF063D2E);
  static const Color lime = Color(0xFFB7FF3B);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static const Color background = darkGreen;
  static const Color surface = Color(0xFF0B4A3F);
  static const Color surfaceElevated = Color(0xFF114D42);
  static const Color surfaceCard = Color(0xFF1D5C52);

  static const Color primaryAccent = lime;
  static const Color primaryBlue = lime;
  static const Color electricBlue = lime;
  static const Color lightBlue = Color(0xFFD9FF99);
  static const Color deepNavy = darkGreen;
  static const Color cobaltBlue = Color(0xFF6BB667);

  static const Color emeraldGreen = lime;
  static const Color amberWarning = Color(0xFFE8FF7A);
  static const Color crimsonRed = Color(0xFFDD4B39);
  static const Color textPrimary = white;
  static const Color textSecondary = Color(0xFFDBE5E1);
  static const Color textTertiary = Color(0xFF9AAFA6);

  static const Color borderSubtle = Color(0xFF295B52);
  static const Color borderGlow = lime;

  static const LinearGradient balanceCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0B4A3F),
      Color(0xFF063D2E),
    ],
  );

  static const LinearGradient virtualCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFB7FF3B),
      Color(0xFF77C98E),
    ],
  );

  static const LinearGradient frozenCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1F4A42),
      Color(0xFF0E3B35),
    ],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFB7FF3B),
      Color(0xFFE4FF88),
    ],
  );
}
