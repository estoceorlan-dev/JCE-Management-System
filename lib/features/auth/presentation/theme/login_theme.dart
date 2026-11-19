import 'package:flutter/material.dart';

import '../../../../core/theme/app_radii.dart';

/// Warm brand colors scoped to authentication, derived from the cover artwork.
abstract final class LoginTheme {
  static ThemeData from(ThemeData base) {
    if (base.brightness == Brightness.dark) return base;
    const background = Color(0xFFFFE9C9);
    const text = Color(0xFF39271D);
    const muted = Color(0xFF745B47);
    final scheme = base.colorScheme.copyWith(
      primary: const Color(0xFF784425),
      onPrimary: const Color(0xFFFFF8EF),
      surface: const Color(0xFFFFF6E9),
      onSurface: text,
      onSurfaceVariant: muted,
      outline: const Color(0xFFB69B7E),
      outlineVariant: const Color(0xFFDAC1A2),
    );
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadii.lg),
      borderSide: BorderSide(color: scheme.outlineVariant),
    );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      textTheme: base.textTheme.apply(bodyColor: text, displayColor: text),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        fillColor: scheme.surface,
        hintStyle: base.textTheme.bodyLarge?.copyWith(color: muted),
        suffixIconColor: muted,
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: scheme.primary,
        selectionColor: scheme.primary.withValues(alpha: 0.24),
        selectionHandleColor: scheme.primary,
      ),
    );
  }
}
