import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class UJobMultiChipGroup<T> extends StatelessWidget {
  final List<T> options;
  final List<T> selectedValues;
  final String Function(T) labelBuilder;
  final ValueChanged<List<T>> onChanged;

  const UJobMultiChipGroup({
    required this.options,
    required this.selectedValues,
    required this.labelBuilder,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: options.map((option) {
        final isSelected = selectedValues.contains(option);
        return GestureDetector(
          onTap: () {
            final newSelected = List<T>.from(selectedValues);
            if (isSelected) {
              newSelected.remove(option);
            } else {
              newSelected.add(option);
            }
            onChanged(newSelected);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.borderLight,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedTick01,
                    color: AppColors.primary,
                    size: 16.r,
                  ),
                  SizedBox(width: 4.w),
                ],
                Text(
                  labelBuilder(option),
                  style: AppText.bodyMedium.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.muted2,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
