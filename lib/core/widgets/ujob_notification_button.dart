import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../features/shared/notifications/notifications_screen.dart';

class UJobNotificationButton extends ConsumerWidget {
  final VoidCallback onTap;
  final Color borderColor;

  const UJobNotificationButton({
    required this.onTap,
    required this.borderColor,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(notifsProvider).where((n) => !n.isRead).length;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onTap,
          tooltip: 'Notifications',
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface.withValues(alpha: 0.12),
            fixedSize: Size(44.r, 44.r),
          ),
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedNotification01,
            color: AppColors.surface,
            size: 23,
          ),
        ),
        if (unreadCount > 0)
          Positioned(
            right: -1.w,
            top: -3.h,
            child: Container(
              width: 20.r,
              height: 20.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 2),
              ),
              child: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: AppText.caption.copyWith(
                  color: AppColors.surface,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
