import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  /// Backgrounds
  static const Color background = Color(0xFF0B0B0C);
  static const Color surface = Color(0xFF171719);

  static const Color appBar = background;
  static const Color bottomNavBar = background;

  /// Cards
  static const Color card = Color(0xFF171719);
  static const Color cardAlt = Color(0xFF131314);

  /// Primary Brand Colors (Logo Matched)
  static const Color primary = Color(0xFFFB9704);
  static const Color primaryLight = Color(0xFFFFBE4A);
  static const Color primaryLight2 = Color(0xFF2C1B05);
  static const Color primaryDark = Color(0xFFD67D00);
  static const Color primary10 = Color(0xFF211505);
  
  /// Podium Colors
  static const Color bronze = Color(0xFFCD7F32);

  /// Typography
  static const Color textPrimary = Color(0xFFF7F7F7);
  static const Color textSecondary = Color(0xFFA0A0A3);
  static const Color textLight = Color(0xFF727276);

  static const Color textOnPrimary = Color(0xFF161616);
  static const Color textOnSecondary = Color(0xFFFFFFFF);

  /// Accent
  static const Color accent = Color(0xFF18181B);
  static const Color accentDark = Color(0xFF0C0C0D);

  static const Color accentYellow = Color(0xFFFFC247);
  static const Color labelGreen = Color(0xFF10B981);

  /// Neutral
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  static const Color greyLight = Color(0xFF1B1B1D);
  static const Color grey = Color(0xFF2A2A2D);
  static const Color greyDark = Color(0xFF444447);

  /// Status
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color errorDark = Color(0xFFB91C1C);
  static const Color warning = Color(0xFFFFC247);
  static const Color info = Color(0xFF3B82F6);

  /// Transparency
  static const Color primaryTransparent = Color(0x80FB9704);
  static const Color secondaryTransparent = Color(0x8010B981);
  static const Color cardOverlay = Color(0x33000000);

  /// Form
  static const Color inputBorder = Color(0xFF2A2A2D);
  static const Color divider = Color(0xFF2A2A2D);
  static const Color inputBorderFocused = primary;
}
