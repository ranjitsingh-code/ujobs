import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class UJobActionCard extends StatelessWidget {
  final List<List<dynamic>> icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  UJobActionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: AppRadius.md,
    child: Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface, 
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1), 
              borderRadius: AppRadius.sm,
            ),
            child: HugeIcon(icon: icon, color: color, size: 22.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Text(title, style: AppText.bodyBold),
                Text(subtitle, style: AppText.small.copyWith(color: AppColors.muted)),
              ],
            ),
          ),
          HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, color: AppColors.muted2, size: 20),
        ],
      ),
    ),
  );
}
