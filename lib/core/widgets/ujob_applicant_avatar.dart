import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class UJobApplicantAvatar extends StatelessWidget {
  final String initials;
  final Color statusColor;

  const UJobApplicantAvatar({
    required this.initials,
    required this.statusColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 48.r,
          height: 48.r,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            initials,
            style: AppText.bodyMd.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Positioned(
          right: 2.r,
          bottom: 2.r,
          child: Container(
            width: 12.r,
            height: 12.r,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.surface, width: 2.r),
            ),
          ),
        ),
      ],
    );
  }
}
