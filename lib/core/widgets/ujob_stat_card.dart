import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class UJobStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String? trend;

  const UJobStatCard({
    required this.label,
    required this.value,
    required this.color,
    this.trend,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.small.copyWith(color: AppColors.muted)),
          SizedBox(height: 8.h),
          Row(
            children: [
              Text(value, style: AppText.heading2.copyWith(color: color)),
              if (trend != null) ...[
                SizedBox(width: 8.w),
                Text(trend!, style: AppText.labelSm.copyWith(color: AppColors.success)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
