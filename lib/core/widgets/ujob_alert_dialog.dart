import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/l10n_extensions.dart';
import 'ujob_button.dart';

class UJobAlertDialog extends StatelessWidget {
  final Widget icon;
  final Color iconBgColor;
  final String title;
  final String description;
  final Widget? child;
  final String? cancelText;
  final String? confirmText;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final Color confirmColor;

  const UJobAlertDialog({
    required this.icon,
    required this.title,
    required this.description,
    this.child,
    required this.onConfirm,
    this.cancelText,
    this.confirmText,
    this.iconBgColor = AppColors.error,
    this.confirmColor = AppColors.error,
    VoidCallback? onCancel,
    super.key,
  }) : onCancel = onCancel ?? _defaultOnCancel;

  static void _defaultOnCancel() {}

  @override
  Widget build(BuildContext context) {
    final resolvedCancelText = cancelText ?? context.l10n.cancel;
    final resolvedConfirmText = confirmText ?? context.l10n.confirm;

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: iconBgColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: icon,
            ),
            SizedBox(height: 20.h),
            Text(title, style: AppText.heading3, textAlign: TextAlign.center),
            SizedBox(height: 8.h),
            Text(
              description,
              style: AppText.bodyMedium.copyWith(color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
            if (child != null) ...[SizedBox(height: 20.h), child!],
            SizedBox(height: 28.h),
            Row(
              children: [
                Expanded(
                  child: UJobButton(
                    label: resolvedCancelText,
                    outlined: true,
                    color: AppColors.muted,
                    onTap: () {
                      Navigator.pop(context);
                      if (onCancel != _defaultOnCancel) {
                        onCancel();
                      }
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: UJobButton(
                    label: resolvedConfirmText,
                    color: confirmColor,
                    gradient: LinearGradient(
                      colors: [confirmColor, confirmColor],
                    ),
                    onTap: onConfirm,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
