import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class UJobStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const UJobStatCard({
    required this.label,
    required this.value,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppRadius.md,
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Text(value, style: AppText.heading2.copyWith(color: color)),
          SizedBox(height: 4.h),
          Text(label, style: AppText.caption.copyWith(color: AppColors.muted)),
        ],
      ),
    ),
  );
}
