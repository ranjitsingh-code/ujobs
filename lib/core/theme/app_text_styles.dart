import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppText {
  // ── Type scale (Inter, matches design tokens) ──────────────────────────────
  static TextStyle get display  => GoogleFonts.inter(fontSize: 32.sp, fontWeight: FontWeight.w900, letterSpacing: -1.0, height: 1.1);
  static TextStyle get heading1 => GoogleFonts.inter(fontSize: 26.sp, fontWeight: FontWeight.w800, letterSpacing: -0.8, height: 1.15);
  static TextStyle get heading2 => GoogleFonts.inter(fontSize: 22.sp, fontWeight: FontWeight.w800, letterSpacing: -0.5, height: 1.2);
  static TextStyle get heading3 => GoogleFonts.inter(fontSize: 20.sp, fontWeight: FontWeight.w800, letterSpacing: -0.4, height: 1.25);
  static TextStyle get h3       => heading3;
  static TextStyle get titleMd  => GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w700, letterSpacing: -0.3);
  static TextStyle get titleSm  => GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.w700, letterSpacing: -0.2);
  static TextStyle get bodyBold => GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.w600, letterSpacing: 0.1);
  static TextStyle get bodySemiBold => bodyBold;
  static TextStyle get body     => GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w400, height: 1.6);
  static TextStyle get bodyMd   => GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w500);
  static TextStyle get bodyMedium => bodyMd;
  static TextStyle get small    => GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w500);
  static TextStyle get bodySmall => small;
  static TextStyle get label    => GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w600, letterSpacing: 0.1);
  static TextStyle get labelSm  => GoogleFonts.inter(fontSize: 11.sp, fontWeight: FontWeight.w600, letterSpacing: 0.1);
  static TextStyle get caption  => GoogleFonts.inter(fontSize: 11.sp, fontWeight: FontWeight.w500);
  static TextStyle get overline => GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w700, letterSpacing: 0.5);
  static TextStyle get button   => GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.w600);

  // ── Named semantic styles (reusable across screens) ───────────────────────
  static TextStyle get brandName    => GoogleFonts.inter(fontSize: 20.sp, fontWeight: FontWeight.w800, letterSpacing: -0.5);
  static TextStyle get brandTagline => GoogleFonts.inter(fontSize: 8.sp,  fontWeight: FontWeight.w500, height: 1.2);
  static TextStyle get heroTitle    => GoogleFonts.inter(fontSize: 32.sp, fontWeight: FontWeight.w800, letterSpacing: -0.5, height: 1.15);
  static TextStyle get cardSubtitle => GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w400);
}

class AppSpacing {
  static double get xs  => 4.w;
  static double get sm  => 8.w;
  static double get md  => 12.w;
  static double get lg  => 16.w;
  static double get xl  => 20.w;
  static double get xxl => 24.w;
  static double get xl3 => 32.w;
  static double get xl4 => 40.w;
  static double get xl5 => 48.w;

  static EdgeInsets get pagePad => EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h);
  static EdgeInsets get cardPad => EdgeInsets.all(16.w);
}

class AppRadius {
  static BorderRadius get xs   => BorderRadius.all(Radius.circular(6.r));
  static BorderRadius get sm   => BorderRadius.all(Radius.circular(8.r));
  static BorderRadius get md   => BorderRadius.all(Radius.circular(12.r));
  static BorderRadius get lg   => BorderRadius.all(Radius.circular(14.r));
  static BorderRadius get xl   => BorderRadius.all(Radius.circular(16.r));
  static BorderRadius get xl2  => BorderRadius.all(Radius.circular(20.r));
  static BorderRadius get xl3  => BorderRadius.all(Radius.circular(24.r));
  static BorderRadius get pill => BorderRadius.all(Radius.circular(999.r));
}

class AppShadow {
  static List<BoxShadow> card() => [
        BoxShadow(
          color: AppColors.text.withValues(alpha: 0.05),
          blurRadius: 8.r,
          offset: Offset(0, 2.h),
        ),
      ];

  static List<BoxShadow> cardMd() => [
        BoxShadow(
          color: AppColors.text.withValues(alpha: 0.07),
          blurRadius: 16.r,
          offset: Offset(0, 4.h),
        ),
      ];

  static List<BoxShadow> button([Color? color]) => [
        BoxShadow(
          color: (color ?? AppColors.primary).withValues(alpha: 0.30),
          blurRadius: 14.r,
          offset: Offset(0, 4.h),
        ),
      ];

  static List<BoxShadow> modal() => [
        BoxShadow(
          color: AppColors.text.withValues(alpha: 0.12),
          blurRadius: 24.r,
          offset: Offset(0, 8.h),
        ),
      ];
}
