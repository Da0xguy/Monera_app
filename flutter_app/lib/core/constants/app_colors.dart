// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Pure Black & Dark Obsidian Backgrounds
  static const Color background = Color(0xFF030712);      // Pitch obsidian black
  static const Color surface = Color(0xFF070E1E);         // Deep blue-black slate
  static const Color surfaceElevated = Color(0xFF0D172E); // Elevated midnight blue
  static const Color surfaceCard = Color(0xFF111E3B);     // Card slate container
  
  // Electric & Cyber Blue Brand Accents
  static const Color primaryBlue = Color(0xFF0077B6);     // Core Monad Blue
  static const Color electricBlue = Color(0xFF00B4D8);    // Vivid Electric Blue
  static const Color lightBlue = Color(0xFF90E0EF);       // Soft Cyan Glow
  static const Color deepNavy = Color(0xFF03045E);        // Midnight Indigo
  static const Color cobaltBlue = Color(0xFF1D4ED8);      // Bold Cobalt
  
  // Functional Accents
  static const Color emeraldGreen = Color(0xFF10B981);    // Settlement & Success
  static const Color amberWarning = Color(0xFFF59E0B);    // Pending & Warnings
  static const Color crimsonRed = Color(0xFFEF4444);      // Frozen & Reversals
  static const Color textPrimary = Color(0xFFF8FAFC);     // High contrast off-white
  static const Color textSecondary = Color(0xFF94A3B8);   // Muted slate
  static const Color textTertiary = Color(0xFF64748B);    // Dim labels
  
  // Borders & Dividers
  static const Color borderSubtle = Color(0xFF1E293B);
  static const Color borderGlow = Color(0xFF1E40AF);

  // Gradients
  static const LinearGradient balanceCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0C2340), // Deep oceanic midnight
      Color(0xFF030A18), // Pitch obsidian black
    ],
  );

  static const LinearGradient virtualCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1D4ED8), // Vibrant Royal Cobalt
      Color(0xFF03045E), // Deepest Navy
    ],
  );

  static const LinearGradient frozenCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E293B),
      Color(0xFF0F172A),
    ],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF0077B6),
      Color(0xFF00B4D8),
    ],
  );
}
