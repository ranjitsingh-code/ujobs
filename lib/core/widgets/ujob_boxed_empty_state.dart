import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class UJobBoxedEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final dynamic icon;

  const UJobBoxedEmptyState({
    required this.title,
    required this.subtitle,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 48.h, horizontal: 24.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(icon: icon, color: AppColors.muted2, size: 48.r),
          SizedBox(height: 16.h),
          Text(
            title,
            style: AppText.heading3.copyWith(color: AppColors.text2),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: AppText.body.copyWith(color: AppColors.muted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
