import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'ujob_button.dart';

class UJobAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final Widget? rightWidget;
  final Color? backgroundColor;
  final Color? titleColor;
  final bool showBack;

  const UJobAppBar({
    required this.title,
    this.onBack,
    this.rightWidget,
    this.backgroundColor,
    this.titleColor,
    this.showBack = true,
    super.key,
  });

  @override
  Size get preferredSize => Size.fromHeight(56.h);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: preferredSize.height,
        color: backgroundColor ?? AppColors.surface,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Row(
          children: [
            if (showBack)
              UJobBackButton(onTap: onBack)
            else
              SizedBox(width: 40.r),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: AppText.bodyBold.copyWith(
                  color: titleColor ?? AppColors.text,
                  fontSize: 18.sp,
                ),
              ),
            ),
            if (rightWidget != null)
              rightWidget!
            else
              SizedBox(width: 40.r),
          ],
        ),
      ),
    );
  }
}
