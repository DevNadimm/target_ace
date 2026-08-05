import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/shared/themes/app_bar_theme.dart';
import 'package:target_ace/core/shared/themes/elevated_button_theme.dart';
import 'package:target_ace/core/shared/themes/input_decoration_theme.dart';
import 'package:target_ace/core/shared/themes/outline_button_theme.dart';

ThemeData theme = ThemeData(
  scaffoldBackgroundColor: AppColors.background,
  brightness: Brightness.dark,
  primaryColor: AppColors.primary,
  fontFamily: AppFonts.bodyFont,
  textTheme: GoogleFonts.getTextTheme(AppFonts.bodyFont, ThemeData.dark().textTheme),
  colorScheme: ColorScheme.dark(
    primary: AppColors.primary,
    onPrimary: AppColors.textOnPrimary,
    surface: AppColors.card,
    onSurface: AppColors.textPrimary,
  ),
  appBarTheme: appBarTheme,
  elevatedButtonTheme: elevatedButtonTheme,
  outlinedButtonTheme: outlinedButtonTheme,
  inputDecorationTheme: inputDecorationTheme,
);