import 'package:flutter/material.dart';
import 'package:remindus/theme/app_colors.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFE0EDFF), 
extensions: const [
    AppColors(
      textPrimary: Color(0xFF212121),
      textSecondary: Color(0xFF242424),
      primaryLight: Color(0xFFE0EDFF),
      primary: Color(0xFF0168FF),
      bgColor: Color(0xFFFFFFFF),
        surfceSecondary: Color(0xFFF0F0F0),
      placeholder: Color(0xFF525252),
      primaryDark: Color(0xFF005DE5),
    ),
  ],
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'Helvetica Now Display',
      fontSize: 32,
      fontWeight: FontWeight.w400,
      height: 1.28,
      color: Color(0xFF212121),
    ),
    bodyLarge: TextStyle(
      fontFamily: 'Helvetica Now Display',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.40,
      letterSpacing: 0.5,
      color: Color(0xFF242424),
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