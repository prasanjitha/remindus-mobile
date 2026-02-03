import 'package:flutter/material.dart';
import 'package:remindus/theme/app_colors.dart';

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF242424),
  extensions: const [
    AppColors(
      textPrimary: Color(0xFFFAFAFA),
      textSecondary: Color(0xFFFAFAFA),
      primaryLight: Color(0xFFADCEFF),
      primary: Color(0xFF005DE5),
      bgColor: Color(0xFF242424),
      surfceSecondary: Color(0xFF1E1E1E),
      placeholder: Color(0xFF9E9E9E),
      primaryDark: Color(0xFF005DE5),
      darkRed: Color(0xFFF06B6D),
      lightRed: Color(0xFFFFE0E1),
      primaryRed: Color(0xFFE8171B),
      errorRed: Color(0xFFE8171B),
      primaryLightBlue: Color(0xFFADCEFF),
      inputFieldBackground: Color(0xFF0C0C0C),
      selectionCard: Color(0xFFE0EDFF),
      textMainBtn: Color(0xFF212121),
    ),
  ],
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'Helvetica Now Display',
      fontSize: 32,
      fontWeight: FontWeight.w400,
      height: 1.28,
      color: Color(0xFFFAFAFA),
    ),
    bodyLarge: TextStyle(
      fontFamily: 'Helvetica Now Display',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.40,
      letterSpacing: 0.5,
      color: Color(0xFFFAFAFA),
    ),
    labelLarge: TextStyle(
      fontFamily: 'Helvetica Now Display',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.20,
      letterSpacing: 0.5,
    ),
  ),
  useMaterial3: true,
);
