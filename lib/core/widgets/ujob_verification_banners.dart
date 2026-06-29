import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class UJobVerificationPendingBanner extends StatelessWidget {
  const UJobVerificationPendingBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedAlert02,
              color: AppColors.warning,
              size: 24.r,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verification Pending',
                  style: AppText.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Your profile is under review by our team. This usually takes 24-48 hours.',
                  style: AppText.small.copyWith(color: AppColors.warning),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UJobCompanyProfileSetup extends StatelessWidget {
  final VoidCallback onSetup;

  const UJobCompanyProfileSetup({required this.onSetup, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedBuilding03,
                  color: AppColors.white,
                  size: 24.r,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complete Profile',
                      style: AppText.titleSm.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Required to post jobs',
                      style: AppText.small.copyWith(
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          InkWell(
            onTap: onSetup,
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              alignment: Alignment.center,
              child: Text(
                'Setup Company Profile',
                style: AppText.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
