import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum SnackType { success, error, warning, info }

class UJobSnackBar {
  static void success(BuildContext c, String title, {String message = ''}) =>
      _show(c, title, message, SnackType.success);

  static void error(BuildContext c, String title, {String message = ''}) =>
      _show(c, title, message, SnackType.error);

  static void warning(BuildContext c, String title, {String message = ''}) =>
      _show(c, title, message, SnackType.warning);

  static void info(BuildContext c, String title, {String message = ''}) =>
      _show(c, title, message, SnackType.info);

  static void _show(
    BuildContext context,
    String title,
    String message,
    SnackType type, {
    Duration duration = const Duration(seconds: 3),
  }) {
    final bottom = MediaQuery.of(context).padding.bottom;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          behavior: SnackBarBehavior.floating,
          dismissDirection: DismissDirection.horizontal,
          elevation: 0,
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.zero,
          margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, bottom + 16.h),
          content: _SnackCard(title: title, message: message, type: type),
        ),
      );
  }
}

class _SnackCard extends StatelessWidget {
  final String title;
  final String message;
  final SnackType type;

  const _SnackCard({
    required this.title,
    required this.message,
    required this.type,
  });

  static final _specs = {
    SnackType.success: _Spec(
      bg: AppColors.successBg,
      border: const Color(0xFFABEFC6),
      iconBg: const Color(0xFFD1FADF),
      iconFg: AppColors.success,
      icon: HugeIcons.strokeRoundedCheckmarkCircle02,
    ),
    SnackType.error: _Spec(
      bg: AppColors.errorBg,
      border: const Color(0xFFFDA29B),
      iconBg: const Color(0xFFFEE4E2),
      iconFg: AppColors.error,
      icon: HugeIcons.strokeRoundedAlert01,
    ),
    SnackType.warning: _Spec(
      bg: AppColors.warningBg,
      border: const Color(0xFFFEC84B),
      iconBg: const Color(0xFFFEF0C7),
      iconFg: AppColors.warning,
      icon: HugeIcons.strokeRoundedAlert02,
    ),
    SnackType.info: _Spec(
      bg: const Color(0xFFEBF5FF),
      border: const Color(0xFFB2DDFF),
      iconBg: const Color(0xFFD1E9FF),
      iconFg: const Color(0xFF2E90FA),
      icon: HugeIcons.strokeRoundedInformationCircle,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final spec = _specs[type]!;
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: spec.bg,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: spec.border),
          boxShadow: const [
            BoxShadow(
              blurRadius: 8,
              offset: Offset(0, 2),
              color: Color(0x1A000000),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28.r,
              height: 28.r,
              decoration: BoxDecoration(
                color: spec.iconBg,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: HugeIcon(icon: spec.icon, size: 16.r, color: spec.iconFg),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppText.bodyBold.copyWith(color: AppColors.text),
                  ),
                  if (message.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      message,
                      style: AppText.bodyMd.copyWith(color: AppColors.muted),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedCancel01,
                size: 18.r,
                color: AppColors.muted,
              ),
              onPressed: () =>
                  ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Spec {
  final Color bg, border, iconBg, iconFg;
  final List<List<dynamic>> icon;
  const _Spec({
    required this.bg,
    required this.border,
    required this.iconBg,
    required this.iconFg,
    required this.icon,
  });
}
