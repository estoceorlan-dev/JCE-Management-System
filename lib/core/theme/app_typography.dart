import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static const fontFamily = 'Poppins';

  static TextTheme textTheme(Brightness brightness) {
    final textColor = brightness == Brightness.dark
        ? Colors.white
        : AppColors.slate900;
    final mutedColor = brightness == Brightness.dark
        ? AppColors.slate400
        : AppColors.slate600;

    return TextTheme(
      headlineLarge: TextStyle(
        color: textColor,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.15,
      ),
      headlineMedium: TextStyle(
        color: textColor,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.2,
      ),
      titleLarge: TextStyle(
        color: textColor,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.25,
      ),
      titleMedium: TextStyle(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      bodyLarge: TextStyle(color: textColor, fontSize: 14, height: 1.5),
      bodyMedium: TextStyle(color: textColor, fontSize: 13, height: 1.45),
      labelLarge: TextStyle(
        color: textColor,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.25,
      ),
      labelMedium: TextStyle(
        color: mutedColor,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.2,
      ),
    ).apply(fontFamily: fontFamily);
  }
}
