import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/l10n_extensions.dart';

class UJobProfileSetupPrompt extends StatelessWidget {
  final VoidCallback? onSetup;
  final String? title;
  final String? subtitle;
  final String? buttonLabel;
  final Color accentColor;
  final Color backgroundColor;
  final List<List<dynamic>> icon;

  const UJobProfileSetupPrompt({
    this.onSetup,
    this.title,
    this.subtitle,
    this.buttonLabel,
    this.accentColor = AppColors.warning,
    this.backgroundColor = AppColors.warningBg,
    this.icon = HugeIcons.strokeRoundedUserAdd01,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: accentColor.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: HugeIcon(
              icon: icon,
              color: accentColor,
              size: 28.r,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? l10n.completeYourProfile,
                  style: AppText.titleSm.copyWith(color: AppColors.text),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle ?? l10n.completeProfileHelps,
                  style: AppText.small.copyWith(color: AppColors.muted),
                ),
                if (onSetup != null) ...[
                  SizedBox(height: 16.h),
                  FilledButton(
                    onPressed: onSetup,
                    style: FilledButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: AppColors.surface,
                      minimumSize: Size(120.w, 36.h),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(buttonLabel ?? l10n.setupNow),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
