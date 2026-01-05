import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color textPrimary;
  final Color textSecondary;
  final Color primaryLight;
  final Color primary;
  final Color bgColor;
  final Color surfceSecondary;
  final Color? placeholder;
  final Color? primaryDark;

  const AppColors({required this.textPrimary, required this.textSecondary, required this.primaryLight, required this.primary, required this.bgColor, required this.surfceSecondary, this.placeholder, this.primaryDark});

  @override
  AppColors copyWith({Color? textPrimary, Color? textSecondary, Color? primaryLight, Color? primary, Color? bgColor, Color? surfceSecondary, Color? placeholder, Color? primaryDark}) {
    return AppColors(
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      primaryLight: primaryLight ?? this.primaryLight,
      primary: primary ?? this.primary, 
      bgColor: bgColor ?? this.bgColor,
      surfceSecondary: surfceSecondary ?? this.surfceSecondary,
      placeholder: placeholder ?? this.placeholder,
      primaryDark: primaryDark ?? this.primaryDark,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      bgColor: Color.lerp(bgColor, other.bgColor, t)!,
      surfceSecondary: Color.lerp(surfceSecondary, other.surfceSecondary, t)!,
      placeholder: Color.lerp(placeholder, other.placeholder, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t),
    );
  }
}

// --- මෙන්න මේ කෑල්ල තමයි වැඩේ ලේසි කරන්නේ ---
extension AppThemeExtension on BuildContext {
  // දැන් context.appColors කිව්වම current theme එකේ පාටවල් ටික ලැබෙනවා
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}