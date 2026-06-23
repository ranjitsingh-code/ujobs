import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class UJobDashboardSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final Color actionColor;

  const UJobDashboardSectionHeader({
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onActionTap,
    this.actionColor = AppColors.seekPrimary,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppText.heading2.copyWith(color: AppColors.text2),
            ),
            if (subtitle != null) ...[
              SizedBox(height: 4.h),
              Row(
                children: [
                  Container(
                    width: 6.r,
                    height: 6.r,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    subtitle!,
                    style: AppText.small.copyWith(color: AppColors.muted),
                  ),
                ],
              ),
            ],
          ],
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onActionTap,
            child: Text(
              actionLabel!,
              style: AppText.bodyBold.copyWith(color: actionColor),
            ),
          ),
      ],
    );
  }
}
