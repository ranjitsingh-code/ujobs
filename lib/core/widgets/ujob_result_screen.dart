import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'ujob_button.dart';

enum ResultType { success, error, warning }

class UJobResultScreen extends StatelessWidget {
  final ResultType type;
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onTap;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryTap;

  const UJobResultScreen({
    required this.type,
    required this.title,
    required this.subtitle,
    this.buttonLabel,
    this.onTap,
    this.secondaryLabel,
    this.onSecondaryTap,
    super.key,
  });

  static List<List<dynamic>> _iconForType(ResultType t) => switch (t) {
    ResultType.success => HugeIcons.strokeRoundedCheckmarkCircle02,
    ResultType.error   => HugeIcons.strokeRoundedCancelCircle,
    ResultType.warning => HugeIcons.strokeRoundedAlert02,
  };

  static const _bgMap = {
    ResultType.success: AppColors.successBg,
    ResultType.error:   AppColors.errorBg,
    ResultType.warning: AppColors.warningBg,
  };

  static const _fgMap = {
    ResultType.success: AppColors.success,
    ResultType.error:   AppColors.error,
    ResultType.warning: AppColors.warning,
  };

  @override
  Widget build(BuildContext context) {
    final icon  = _iconForType(type);
    final bg    = _bgMap[type]!;
    final fg    = _fgMap[type]!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Icon circle
              Container(
                width: 96.r,
                height: 96.r,
                decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                child: HugeIcon(icon: icon, size: 52.r, color: fg),
              ),

              SizedBox(height: 32.h),

              Text(
                title,
                textAlign: TextAlign.center,
                style: AppText.display.copyWith(color: AppColors.text),
              ),

              SizedBox(height: 12.h),

              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: AppText.bodyMd.copyWith(color: AppColors.muted),
              ),

              const Spacer(),

              if (buttonLabel != null)
                UJobButton(
                  label: buttonLabel!,
                  onTap: onTap,
                  color: fg,
                ),

              if (secondaryLabel != null) ...[
                SizedBox(height: 12.h),
                UJobButton(
                  label: secondaryLabel!,
                  onTap: onSecondaryTap,
                  outlined: true,
                  color: fg,
                ),
              ],

              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}
