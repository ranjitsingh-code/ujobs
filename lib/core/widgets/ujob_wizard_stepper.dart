import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class UJobWizardStepper extends StatelessWidget {
  final int currentStep;
  final List<String> steps;

  const UJobWizardStepper({
    required this.currentStep,
    required this.steps,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // currentStep is 0-indexed
    final stepNumber = currentStep + 1;
    final totalSteps = steps.length;
    final title = steps[currentStep];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                title,
                style: AppText.heading3.copyWith(color: AppColors.text),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 16.w),
            Text(
              '$stepNumber / $totalSteps',
              style: AppText.small.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              height: 6.h,
              width: constraints.maxWidth,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(3.r),
              ),
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                width: constraints.maxWidth * (stepNumber / totalSteps),
                height: 6.h,
                decoration: BoxDecoration(
                  gradient: AppColors.authGradient,
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
