import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class UJobStageStepper extends StatelessWidget {
  final String currentStage;
  final void Function(String)? onStageSelected;

  const UJobStageStepper({
    super.key, 
    required this.currentStage,
    this.onStageSelected,
  });

  final List<String> _stages = const [
    'Applied',
    'Shortlisted',
    'Interview',
    'Offered',
  ];

  @override
  Widget build(BuildContext context) {
    int currentIndex = _stages.indexWhere(
      (s) => s.toLowerCase() == currentStage.toLowerCase(),
    );

    // Fallbacks
    if (currentStage.toLowerCase() == 'hired')
      currentIndex = _stages.length; // all completed
    // If rejected, we don't advance the index, so it stays where it was, but we need to know the 'previous' stage.
    // For simplicity, let's assume if rejected, it just marks the last active stage as rejected.
    // However, the model doesn't store the "rejected at" stage. If it's -1, we'll just put it at 0.
    if (currentIndex == -1 && currentStage.toLowerCase() == 'rejected')
      currentIndex = 0;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'APPLICATION STAGE',
            style: AppText.overline.copyWith(
              color: AppColors.muted,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(_stages.length * 2 - 1, (i) {
              if (i.isEven) {
                final index = i ~/ 2;
                final isCompleted = index < currentIndex;
                final isCurrent = index == currentIndex;
                final isRejected = currentStage.toLowerCase() == 'rejected';

                Color circleColor;
                Color contentColor;

                if (isRejected && isCurrent) {
                  circleColor = AppColors.error;
                  contentColor = Colors.white;
                } else if (isCompleted || isCurrent) {
                  circleColor = AppColors.primary;
                  contentColor = Colors.white;
                } else {
                  circleColor = AppColors.surface;
                  contentColor = AppColors.muted;
                }

                return SizedBox(
                  width: 76.w, // Fixed width to keep alignment symmetrical and allow text wrapping
                  child: GestureDetector(
                    onTap: onStageSelected != null ? () => onStageSelected!(_stages[index]) : null,
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                    children: [
                      Container(
                        width: 32.r,
                        height: 32.r,
                        decoration: BoxDecoration(
                          color: circleColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: (isCompleted || isCurrent)
                                ? circleColor
                                : AppColors.borderLight,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: isCompleted
                              ? HugeIcon(
                                  icon:
                                      HugeIcons.strokeRoundedCheckmarkCircle02,
                                  color: contentColor,
                                  size: 16.r,
                                )
                              : isRejected && isCurrent
                              ? HugeIcon(
                                  icon: HugeIcons.strokeRoundedCancelCircle,
                                  color: contentColor,
                                  size: 16.r,
                                )
                              : Text(
                                  '${index + 1}',
                                  style: AppText.caption.copyWith(
                                    color: contentColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        _stages[index],
                        textAlign: TextAlign.center,
                        style: AppText.small.copyWith(
                          color: (isCompleted || isCurrent)
                              ? AppColors.primary
                              : AppColors.muted,
                          fontWeight: isCurrent
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 11.sp, // slightly smaller to fit well
                        ),
                      ),
                    ],
                  ),
                  ),
                );
              } else {
                final index = i ~/ 2;
                final isCompleted = index < currentIndex;
                return Expanded(
                  child: Container(
                    height: 2.h,
                    margin: EdgeInsets.only(
                      top: 16.r,
                      left: 4.w,
                      right: 4.w,
                    ), // 16.r aligns with center of 32.r circle
                    color: (isCompleted)
                        ? AppColors.primary
                        : AppColors.borderLight,
                  ),
                );
              }
            }),
          ),
        ],
      ),
    );
  }
}
