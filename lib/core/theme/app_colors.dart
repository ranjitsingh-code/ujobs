import 'package:flutter/material.dart';

class AppColors {
  // ── Brand primary (cyan scale) ─────────────────────────────────────────────
  static const primary = Color(0xFF0891B2);
  static const primaryDark = Color(0xFF0C4A6E);
  static const primaryDeep = Color(0xFF071E2E);
  static const primaryLight = Color(0xFFF0F9FF);
  static const primaryMid = Color(0xFFBAE6FD);
  static const primaryAccent = Color(0xFF0EA5E9);
  static const primarySky = Color(0xFF38BDF8); // sky-400, splash palette B
  static const primaryCloud = Color(0xFFE0F2FE); // sky-100, splash palette B

  // ── Role aliases ───────────────────────────────────────────────────────────
  // Both roles use the same cyan brand. Employer uses darker shade for headers.
  static const empPrimary = primaryDark;
  static const empPrimaryDark = primaryDeep;
  static const empSecondary = primary;
  static const empSurface = primaryLight;
  static const empAccent = primaryAccent;
  static const seekPrimary = primary;
  static const seekPrimaryDark = primaryDark;
  static const seekSecondary = primaryAccent;
  static const seekSurface = primaryLight;
  static const seekAccent = primaryAccent;

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const success = Color(0xFF10B981);
  static const successBg = Color(0xFFECFDF5);
  static const warning = Color(0xFFF59E0B);
  static const warningBg = Color(0xFFFFFBEB);
  static const error = Color(0xFFEF4444);
  static const errorBg = Color(0xFFFEF2F2);
  static const danger = error;
  static const dangerBg = errorBg;
  static const purple = Color(0xFF8B5CF6);
  static const purpleBg = Color(0xFFF5F3FF);
  static const info = Color(0xFF3B82F6);

  // ── Onboarding slide card backgrounds ─────────────────────────────────────
  static const onboardBlueStart = Color(0xFFEFF6FF); // blue-50
  static const onboardBlueEnd = Color(0xFFDBEAFE); // blue-100
  static const onboardPurpleEnd = Color(0xFFEDE9FE); // violet-100
  static const onboardGreenEnd = Color(0xFFD1FAE5); // emerald-100

  // ── Neutrals ───────────────────────────────────────────────────────────────
  static const bg = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const borderLight = Color(0xFFF1F5F9);
  static const border = Color(0xFFE2E8F0);
  static const muted2 = Color(0xFF64748B); // Slate 500 (was 400)
  static const muted = Color(0xFF475569); // Slate 600 (was 500)
  static const text2 = Color(0xFF334155);
  static const text = Color(0xFF0F172A);

  // ── Backward-compat aliases ────────────────────────────────────────────────
  static const background = bg;
  static const dark = text;
  static const white = surface;
  static const grey100 = borderLight;
  static const grey400 = muted2;
  static const grey600 = muted;
  static const grey900 = text;
  static const successLight = successBg;
  static const errorLight = errorBg;
  static const warningLight = warningBg;

  // ── Dark mode surfaces ─────────────────────────────────────────────────────
  static const empDarkBg = Color(0xFF071E2E);
  static const empDarkSurface = Color(0xFF0C2A3E);
  static const seekDarkBg = Color(0xFF071E2E);
  static const seekDarkSurface = Color(0xFF0C2A3E);
  static const darkCard = Color(0xFF1E293B);
  static const darkInputFill = Color(0xFF1E2A38);
  static const darkText = Color(0xFFF1F5F9);
  static const darkSubtext = Color(0xFF94A3B8);
  static const darkDivider = Color(0xFF334155);

  // ── Application stage colors ───────────────────────────────────────────────
  static const stageApplied = Color(0xFF3B82F6);
  static const stageReviewed = Color(0xFF06B6D4);
  static const stageShortlisted = Color(0xFF8B5CF6);
  static const stageInterviewed = Color(0xFFF59E0B);
  static const stageOffered = Color(0xFF10B981);
  static const stageRejected = Color(0xFFEF4444);
  static const stageWithdrawn = Color(0xFF94A3B8);

  // ── Gradient helpers ───────────────────────────────────────────────────────
  static const authGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primaryAccent, primary, primaryDark],
  );

  static const splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDeep, primaryDark, primary, primaryAccent],
  );
}
