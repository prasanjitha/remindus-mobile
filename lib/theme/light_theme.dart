import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:remindus/theme/app_colors.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFE0EDFF),
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF0168FF),
    onPrimary: Colors.white,
    secondary: Color(0xFFADCEFF),
    onSecondary: Color(0xFF212121),
    surface: Colors.white,
    onSurface: Color(0xFF212121),
    error: Color(0xFFE8171B),
    onError: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  ),
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
      darkRed: Color(0xFFF06B6D),
      lightRed: Color(0xFFFFE0E1),
      primaryRed: Color(0xFFE8171B),
      errorRed: Color(0xFFE8171B),
      primaryLightBlue: Color(0xFFADCEFF),
      inputFieldBackground: Color(0xFFFFFFFF),
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
