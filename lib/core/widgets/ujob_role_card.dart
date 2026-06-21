import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class UJobRoleCard extends StatefulWidget {
  final List<List<dynamic>> icon;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const UJobRoleCard({
    required this.icon,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    this.onTap,
    super.key,
  });

  @override
  State<UJobRoleCard> createState() => _UJobRoleCardState();
}

class _UJobRoleCardState extends State<UJobRoleCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tapCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _tapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _tapCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _tapCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _tapCtrl.forward();

  void _onTapUp(TapUpDetails _) {
    _tapCtrl.reverse();
    if (widget.onTap != null) {
      Future.delayed(const Duration(milliseconds: 150), widget.onTap);
    }
  }

  void _onTapCancel() => _tapCtrl.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _tapCtrl,
        builder: (_, _) => Transform.scale(
          scale: _scale.value,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.text.withValues(
                    alpha: _tapCtrl.isAnimating || _tapCtrl.isCompleted
                        ? 0.02
                        : 0.08,
                  ),
                  blurRadius: _tapCtrl.isAnimating ? 4 : 20,
                  offset: Offset(0, _tapCtrl.isAnimating ? 2 : 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64.r,
                  height: 64.r,
                  decoration: BoxDecoration(
                    color: widget.iconBgColor,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Center(
                    child: HugeIcon(
                      icon: widget.icon,
                      color: AppColors.surface,
                      size: 30.r,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  widget.title,
                  style: AppText.titleMd.copyWith(color: AppColors.text),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 6.h),
                Text(
                  widget.subtitle,
                  style: AppText.cardSubtitle.copyWith(color: AppColors.muted),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
