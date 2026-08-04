import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  /// Backgrounds
  static const Color background = Color(0xFF0C0C0D);      // Deep Black
  static const Color surface = Color(0xFF19191B);         // Elevated Dark Card

  static const Color appBar = background;
  static const Color bottomNavBar = background;

  /// Cards
  static const Color card = Color(0xFF19191B);
  static const Color cardAlt = Color(0xFF141415);

  /// Primary Theme Colors (Logo-matched Orange)
  static const Color primary = Color(0xFFF97316);          // Logo Orange (exact match)
  static const Color primaryLight = Color(0xFFFDBA74);     // Soft Orange Glow
  static const Color primaryLight2 = Color(0xFF2A1B0D);    // Soft dark transparent orange overlay
  static const Color primaryDark = Color(0xFFC2570F);      // Deep Burnt Orange
  static const Color primary10 = Color(0xFF1F150C);        // 10% Opacity Orange

  /// Typography Colors
  static const Color textPrimary = Color(0xFFF5F5F5);      // Logo White (bullseye rings)
  static const Color textSecondary = Color(0xFF9A9A9C);    // Grey
  static const Color textLight = Color(0xFF6B6B6D);        // Muted Grey
  static const Color textOnPrimary = Color(0xFF18181B);    // Logo Black on orange
  static const Color textOnSecondary = Color(0xFFFFFFFF);

  /// Accent / Branding
  static const Color accent = Color(0xFF18181B);           // Logo Black ring accent
  static const Color accentDark = Color(0xFF0C0C0D);
  static const Color accentYellow = Color(0xFFFBBF24);     // Warm highlight
  static const Color labelGreen = Color(0xFF10B981);       // Emerald for success states

  /// Neutral Colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color greyLight = Color(0xFF19191B);
  static const Color grey = Color(0xFF28282A);
  static const Color greyDark = Color(0xFF3E3E40);

  /// Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color errorDark = Color(0xFFB91C1C);
  static const Color warning = Color(0xFFFBBF24);
  static const Color info = Color(0xFF3B82F6);

  /// Transparency / Overlays
  static const Color primaryTransparent = Color(0x80F97316);
  static const Color secondaryTransparent = Color(0x8010B981);
  static const Color cardOverlay = Color(0x33000000);

  /// Form / Inputs
  static const Color inputBorder = Color(0xFF28282A);
  static const Color divider = Color(0xFF28282A);
  static const Color inputBorderFocused = primary;
}