import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/app_colors.dart';

class UJobAuthHeader extends StatelessWidget {
  final List<List<dynamic>> icon;
  final VoidCallback? onBack;

  const UJobAuthHeader({required this.icon, this.onBack, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (onBack != null) ...[
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedArrowLeft01,
                size: 20.r,
                color: AppColors.text,
              ),
            ),
          ),
          SizedBox(height: 28.h),
        ],
        Container(
          width: 64.r,
          height: 64.r,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: HugeIcon(icon: icon, color: AppColors.primary, size: 30.r),
        ),
      ],
    );
  }
}
