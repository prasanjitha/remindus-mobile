import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  static const String _themeKey = 'theme_mode';

  ThemeCubit() : super(const ThemeState(themeMode: ThemeMode.system)) {
    _loadTheme();
  }

  // Load theme preference from storage
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeIndex = prefs.getInt(_themeKey) ?? 0;

      final themeMode = ThemeMode.values[themeModeIndex];
      emit(ThemeState(themeMode: themeMode));
    } catch (e) {
      // If there's an error, keep the default system theme
      emit(const ThemeState(themeMode: ThemeMode.system));
    }
  }

  // Set theme mode and persist to storage
  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, mode.index);
      emit(ThemeState(themeMode: mode));
    } catch (e) {
      // If there's an error saving, at least update the UI
      emit(ThemeState(themeMode: mode));
    }
  }

  // Convenience methods for setting specific modes
  Future<void> setSystemTheme() => setThemeMode(ThemeMode.system);
  Future<void> setLightTheme() => setThemeMode(ThemeMode.light);
  Future<void> setDarkTheme() => setThemeMode(ThemeMode.dark);
}
