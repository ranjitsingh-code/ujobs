import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'role_theme_extension.dart';

class AppTheme {
  // ── Light themes ──────────────────────────────────────────────────────────

  static ThemeData employerTheme() => _build(
    primary: AppColors.empPrimary,
    scaffoldBg: AppColors.bg,
    inputFill: AppColors.borderLight,
    cardColor: AppColors.surface,
    brightness: Brightness.light,
    extension: const RoleThemeExtension(
      primary: AppColors.empPrimary,
      secondary: AppColors.empSecondary,
      accent: AppColors.empAccent,
    ),
  );

  static ThemeData seekerTheme() => _build(
    primary: AppColors.seekPrimary,
    scaffoldBg: AppColors.bg,
    inputFill: AppColors.borderLight,
    cardColor: AppColors.surface,
    brightness: Brightness.light,
    extension: const RoleThemeExtension(
      primary: AppColors.seekPrimary,
      secondary: AppColors.seekSecondary,
      accent: AppColors.seekAccent,
    ),
  );

  // ── Dark themes ───────────────────────────────────────────────────────────

  static ThemeData employerDarkTheme() => _build(
    primary: AppColors.empPrimary,
    scaffoldBg: AppColors.empDarkBg,
    inputFill: AppColors.darkInputFill,
    cardColor: AppColors.empDarkSurface,
    brightness: Brightness.dark,
    extension: const RoleThemeExtension(
      primary: AppColors.empPrimary,
      secondary: AppColors.empSecondary,
      accent: AppColors.empAccent,
    ),
  );

  static ThemeData seekerDarkTheme() => _build(
    primary: AppColors.seekPrimary,
    scaffoldBg: AppColors.seekDarkBg,
    inputFill: AppColors.darkInputFill,
    cardColor: AppColors.seekDarkSurface,
    brightness: Brightness.dark,
    extension: const RoleThemeExtension(
      primary: AppColors.seekPrimary,
      secondary: AppColors.seekSecondary,
      accent: AppColors.seekAccent,
    ),
  );

  // ── Builder ───────────────────────────────────────────────────────────────

  static ThemeData _build({
    required Color primary,
    required Color scaffoldBg,
    required Color inputFill,
    required Color cardColor,
    required Brightness brightness,
    required RoleThemeExtension extension,
  }) {
    final isDark = brightness == Brightness.dark;
    final onSurface = isDark ? AppColors.darkText : AppColors.text;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      extensions: [extension],
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: extension.secondary,
        surface: scaffoldBg,
        brightness: brightness,
      ),
      scaffoldBackgroundColor: scaffoldBg,
      cardColor: cardColor,

      textTheme: GoogleFonts.interTextTheme(
        brightness == Brightness.dark
            ? ThemeData.dark().textTheme
            : ThemeData.light().textTheme,
      ).apply(bodyColor: onSurface, displayColor: onSurface),

      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
        iconTheme: IconThemeData(color: onSurface),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: primary,
        unselectedItemColor: isDark ? AppColors.darkSubtext : AppColors.muted2,
        backgroundColor: cardColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: AppColors.surface,
          minimumSize: Size(double.infinity, 54.h),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
          elevation: 0,
          textStyle: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: Size(double.infinity, 54.h),
          side: BorderSide(color: primary.withValues(alpha: 0.5), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
          textStyle: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkInputFill : AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: AppRadius.lg,
          borderSide: BorderSide(
            color: isDark ? AppColors.darkDivider : AppColors.border,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.lg,
          borderSide: BorderSide(
            color: isDark ? AppColors.darkDivider : AppColors.border,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.lg,
          borderSide: BorderSide(color: primary, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        hintStyle: GoogleFonts.inter(
          fontSize: 15.sp,
          color: isDark ? AppColors.darkSubtext : AppColors.muted2,
        ),
      ),

      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xl),
        shadowColor: Colors.black.withValues(alpha: 0.05),
      ),
    );
  }
}
