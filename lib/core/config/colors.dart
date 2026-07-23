import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ------------------- Backgrounds -------------------
  static const Color background = Color(0xFF09090B);      // Pure Obsidian Carbon
  static const Color surface = Color(0xFF18181B);         // Elevated Neutral Card

  static const Color appBar = background;
  static const Color bottomNavBar = background;

  // ------------------- Cards -------------------
  static const Color card = Color(0xFF18181B);            // Elevated Neutral Card
  static const Color cardAlt = Color(0xFF121214);         // Deep Matte Carbon

  // ------------------- Primary Theme Colors (Bespoke Champagne Gold) -------------------
  static const Color primary = Color(0xFFC5A365);          // Premium Champagne Gold
  static const Color primaryLight = Color(0xFFE2D1B3);     // Light Ivory Gold
  static const Color primaryLight2 = Color(0xFF27231B);    // Soft dark transparent gold overlay
  static const Color primaryDark = Color(0xFF967945);      // Deep Bronze Gold

  // ------------------- Typography Colors -------------------
  static const Color textPrimary = Color(0xFFF5F5F7);      // Soft Apple White
  static const Color textSecondary = Color(0xFF949499);    // Zinc Grey
  static const Color textLight = Color(0xFF71717A);        // Muted Zinc Grey
  static const Color textOnPrimary = Color(0xFF18181B);
  static const Color textOnSecondary = Color(0xFFFFFFFF);

  // ------------------- Accent / Branding -------------------
  static const Color accent = Color(0xFFE11D48);           // Rose Crimson Accent
  static const Color accentDark = Color(0xFFBE123C);       // Crimson Rose Shadow

  // Warm gold for highlights / jewelry accents
  static const Color accentYellow = Color(0xFFD97706);     // Curated Warm Amber

  // Emerald used for positive labels
  static const Color labelGreen = Color(0xFF059669);       // Curated Emerald Green

  // ------------------- Neutral Colors -------------------
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color greyLight = Color(0xFF18181B);
  static const Color grey = Color(0xFF27272A);
  static const Color greyDark = Color(0xFF3F3F46);

  // ------------------- Status Colors -------------------
  static const Color success = Color(0xFF059669);   // Emerald
  static const Color error = Color(0xFFE11D48);     // Crimson
  static const Color errorDark = Color(0xFFBE123C);     // Crimson
  static const Color warning = Color(0xFFD97706);   // Amber
  static const Color info = Color(0xFF3B82F6);      // Muted Blue

  // ------------------- Transparency / Overlays -------------------
  static const Color primaryTransparent = Color(0x80C5A365);
  static const Color secondaryTransparent = Color(0x80059669);
  static const Color cardOverlay = Color(0x33000000);

  // ------------------- Form / Inputs -------------------
  static const Color inputBorder = Color(0xFF27272A);      // Zinc border
  static const Color divider = Color(0xFF27272A);
  static const Color inputBorderFocused = primary;
}
