import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'ujob_button.dart';

class UJobAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? customTitle;
  final VoidCallback? onBack;
  final Widget? rightWidget;
  final Color? backgroundColor;
  final Color? titleColor;
  final bool showBack;
  final PreferredSizeWidget? bottom;

  const UJobAppBar({
    required this.title,
    this.customTitle,
    this.onBack,
    this.rightWidget,
    this.backgroundColor,
    this.titleColor,
    this.showBack = true,
    this.bottom,
    super.key,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(56.h + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 56.h,
            color: backgroundColor ?? AppColors.surface,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: showBack
                      ? UJobBackButton(onTap: onBack)
                      : SizedBox(width: 40.r),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 48.w),
                  child: customTitle ??
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.bodyBold.copyWith(
                          color: titleColor ?? AppColors.text,
                          fontSize: 18.sp,
                        ),
                      ),
                ),
                if (rightWidget != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: rightWidget!,
                  ),
              ],
            ),
          ),
          ?bottom,
        ],
      ),
    );
  }
}
