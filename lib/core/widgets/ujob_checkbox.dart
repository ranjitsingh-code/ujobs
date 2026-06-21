import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class UJobCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? label;
  final String? semanticsLabel;

  const UJobCheckbox({
    required this.value,
    required this.onChanged,
    this.label,
    this.semanticsLabel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: value,
      button: true,
      label: semanticsLabel ?? label,
      child: GestureDetector(
        onTap: () => onChanged(!value),
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 22.r,
              height: 22.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: value ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: value ? AppColors.primary : AppColors.muted2,
                  width: 1.5.r,
                ),
                boxShadow: value
                    ? AppShadow.button(
                        AppColors.primary.withValues(alpha: 0.24),
                      )
                    : null,
              ),
              child: value
                  ? HugeIcon(
                      icon: HugeIcons.strokeRoundedTick01,
                      color: AppColors.surface,
                      size: 15.r,
                    )
                  : null,
            ),
            if (label != null) ...[
              SizedBox(width: 8.w),
              Text(
                label!,
                style: AppText.small.copyWith(color: AppColors.muted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
