import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Warm, editorial palette: rose clay accents on a soft cream background.
abstract final class Glow {
  static const bg = Color(0xFFFBF7F4);
  static const surface = Colors.white;
  static const ink = Color(0xFF2B2024);
  static const inkSoft = Color(0xFF7A6B6F);
  static const rose = Color(0xFFB5656B);
  static const roseDark = Color(0xFF8E4A50);
  static const roseSoft = Color(0xFFF4E1DF);
  static const sage = Color(0xFF6F8F7C);
  static const sageSoft = Color(0xFFE2ECE5);
  static const gold = Color(0xFFC9A227);
  static const line = Color(0xFFEDE3DE);

  static const heroGradient = LinearGradient(
    colors: [Color(0xFFB5656B), Color(0xFFD4927A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const avatarColors = [
    [Color(0xFFD4927A), Color(0xFFB5656B)],
    [Color(0xFF8FA998), Color(0xFF6F8F7C)],
    [Color(0xFFC9A227), Color(0xFFD4927A)],
    [Color(0xFF9C8AA5), Color(0xFF7A6B8F)],
  ];

  static const serif = 'DMSerifDisplay';

  static ThemeData theme() {
    const scheme = ColorScheme.light(
      primary: rose,
      onPrimary: Colors.white,
      secondary: sage,
      surface: surface,
      onSurface: ink,
      error: Color(0xFFC2413B),
      outline: line,
    );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme, fontFamily: 'DMSans', scaffoldBackgroundColor: bg);
    final rounded = RoundedRectangleBorder(borderRadius: BorderRadius.circular(18));
    const btnText = TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w700, fontSize: 16);
    return base.copyWith(
      textTheme: base.textTheme.apply(bodyColor: ink, displayColor: ink),
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        foregroundColor: ink,
        elevation: 0,
        titleTextStyle: TextStyle(fontFamily: serif, fontSize: 26, color: ink),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56), shape: rounded, textStyle: btnText),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: rounded,
          textStyle: btnText,
          foregroundColor: ink,
          side: const BorderSide(color: line, width: 1.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: line)),
        enabledBorder:
            OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: line)),
        focusedBorder:
            OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: rose, width: 1.6)),
        hintStyle: const TextStyle(color: inkSoft),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: surface,
        selectedColor: ink,
        side: BorderSide(color: line),
        shape: StadiumBorder(),
        showCheckmark: false,
        labelStyle: TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w600, color: ink),
        secondaryLabelStyle: TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w600, color: Colors.white),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ink,
        shape: rounded,
        contentTextStyle: const TextStyle(fontFamily: 'DMSans', color: Colors.white, fontWeight: FontWeight.w600),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? ink : surface),
          foregroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? Colors.white : ink),
          side: const WidgetStatePropertyAll(BorderSide(color: line)),
          textStyle: const WidgetStatePropertyAll(TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w700)),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: roseSoft,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(color: line, thickness: 1, space: 1),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
      }),
    );
  }
}
