import 'package:flutter/material.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';

AppBarTheme appBarTheme = AppBarTheme(
  backgroundColor: AppColors.background,
  foregroundColor: AppColors.textPrimary,
  scrolledUnderElevation: 0,
  elevation: 0,
  centerTitle: true,
  titleTextStyle: AppFonts.heading(
    fontSize: 18,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.bold,
  ),
);

