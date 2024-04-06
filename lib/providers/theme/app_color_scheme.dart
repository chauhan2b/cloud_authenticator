import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_color_scheme.g.dart';

@riverpod
class AppColorScheme extends _$AppColorScheme {
  @override
  void build() {
    // nothing to do
  }

  ThemeData lightColorScheme(ColorScheme? lightColorScheme) {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: lightColorScheme,
      fontFamily: GoogleFonts.poppins().fontFamily,
    );
  }

  ThemeData darkColorScheme(ColorScheme? darkColorScheme) {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: darkColorScheme,
      fontFamily: GoogleFonts.poppins().fontFamily,
    );
  }

  ThemeData defaultLightColorScheme() {
    return ThemeData(
      brightness: Brightness.light,
      fontFamily: GoogleFonts.poppins().fontFamily,
    );
  }

  ThemeData defaultDarkColorScheme() {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: GoogleFonts.poppins().fontFamily,
    );
  }
}
