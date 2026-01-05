import 'package:flutter/material.dart';
import 'package:remindus/theme/app_colors.dart';

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
 extensions: const [
    AppColors(
      textPrimary: Color(0xFFFFFFFF), 
      textSecondary: Color(0xFFE0E0E0),
      primaryLight: Color(0xFF121212),
      primary: Color(0xFF0168FF),
      bgColor: Color(0xFF000000),
      surfceSecondary: Color(0xFF1E1E1E),
    ),
  ],
  useMaterial3: true,
);