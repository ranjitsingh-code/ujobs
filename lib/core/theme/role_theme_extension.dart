import 'package:flutter/material.dart';

class RoleThemeExtension extends ThemeExtension<RoleThemeExtension> {
  final Color primary;
  final Color secondary;
  final Color accent;
  final LinearGradient? gradient;

  const RoleThemeExtension({
    required this.primary,
    required this.secondary,
    required this.accent,
    this.gradient,
  });

  @override
  RoleThemeExtension copyWith({
    Color? primary,
    Color? secondary,
    Color? accent,
    LinearGradient? gradient,
  }) {
    return RoleThemeExtension(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      gradient: gradient ?? this.gradient,
    );
  }

  @override
  RoleThemeExtension lerp(ThemeExtension<RoleThemeExtension>? other, double t) {
    if (other is! RoleThemeExtension) return this;
    return RoleThemeExtension(
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      gradient: LinearGradient.lerp(gradient, other.gradient, t),
    );
  }
}
