import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFonts {
  AppFonts._();

  /// Serif font used for headers, big titles, and prominent branding elements (Fraunces).
  static const String headingFont = 'Fraunces';

  /// Sans-serif font used for UI elements, buttons, inputs, and general body text (Poppins).
  static const String bodyFont = 'Poppins';

  /// Helper to create a heading text style (Fraunces)
  static TextStyle heading({
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
    Color? decorationColor,
    double? decorationThickness,
    TextStyle? textStyle,
  }) {
    return GoogleFonts.getFont(
      headingFont,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationThickness: decorationThickness,
      textStyle: textStyle,
    );
  }

  /// Helper to create a body or UI text style (Poppins)
  static TextStyle body({
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
    Color? decorationColor,
    double? decorationThickness,
    TextStyle? textStyle,
  }) {
    return GoogleFonts.getFont(
      bodyFont,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationThickness: decorationThickness,
      textStyle: textStyle,
    );
  }

  /// Backward compatibility for existing code that references AppFonts.style()
  static TextStyle style({
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
    Color? decorationColor,
    double? decorationThickness,
    TextStyle? textStyle,
  }) {
    return body(
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationThickness: decorationThickness,
      textStyle: textStyle,
    );
  }
}
