import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class UJobRecentJobItem extends StatelessWidget {
  final String title;
  final String iconLetter;
  final Color iconColor;
  final String postedDate;
  final String applicantCount;
  final VoidCallback onTap;

  const UJobRecentJobItem({
    required this.title,
    required this.iconLetter,
    required this.iconColor,
    required this.postedDate,
    required this.applicantCount,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Container(
              width: 48.r,
              height: 48.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                iconLetter,
                style: AppText.heading2.copyWith(color: iconColor),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.label.copyWith(fontWeight: FontWeight.w700)),
                  SizedBox(height: 4.h),
                  Text(postedDate, style: AppText.small.copyWith(color: AppColors.muted)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  applicantCount,
                  style: AppText.label.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
                Text('Apps', style: AppText.overline.copyWith(color: AppColors.muted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
