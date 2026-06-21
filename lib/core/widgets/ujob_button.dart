import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class UJobButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool outlined;
  final double? height;
  final Widget? icon;
  final Color? color;
  final LinearGradient? gradient;
  final TextStyle? textStyle;

  const UJobButton({
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.outlined = false,
    this.height,
    this.icon,
    this.color,
    this.gradient,
    this.textStyle,
    super.key,
  });

  @override
  State<UJobButton> createState() => _UJobButtonState();
}

class _UJobButtonState extends State<UJobButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );
    _scale = Tween(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  // Listener (not GestureDetector) avoids gesture arena conflicts with inner ElevatedButton
  void _onDown(PointerDownEvent _) {
    if (widget.onTap != null && !widget.isLoading) _scaleCtrl.forward();
  }
  void _onUp(PointerUpEvent _) => _scaleCtrl.reverse();
  void _onCancel(PointerCancelEvent _) => _scaleCtrl.reverse();

  @override
  Widget build(BuildContext context) {
    final h = (widget.height ?? 52).h;
    final bg = widget.color ?? AppColors.primary;

    final Widget button;
    if (widget.outlined) {
      button = SizedBox(
        width: double.infinity,
        height: h,
        child: OutlinedButton(
          onPressed: widget.isLoading ? null : widget.onTap,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: bg),
            foregroundColor: bg,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
          ),
          child: _child(color: bg),
        ),
      );
    } else {
      final enabled = widget.onTap != null && !widget.isLoading;
      button = SizedBox(
        width: double.infinity,
        height: h,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: enabled
                ? (widget.gradient ?? LinearGradient(
                    colors: [bg, AppColors.primaryDark],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ))
                : null,
            color: enabled ? null : AppColors.muted2,
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: enabled ? AppShadow.button(bg) : null,
          ),
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: AppColors.surface,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              minimumSize: Size(double.infinity, h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
              elevation: 0,
            ),
            child: _child(),
          ),
        ),
      );
    }

    return Listener(
      onPointerDown: _onDown,
      onPointerUp: _onUp,
      onPointerCancel: _onCancel,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: button,
      ),
    );
  }

  Widget _child({Color? color}) {
    if (widget.isLoading) {
      return SizedBox(
        width: 20.r,
        height: 20.r,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: color ?? AppColors.surface,
        ),
      );
    }
    final style = (widget.textStyle ?? AppText.button).copyWith(color: color ?? AppColors.surface);
    if (widget.icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center, 
        children: [
          widget.icon!,
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              widget.label, 
              style: style,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      );
    }
    return Text(widget.label, style: style);
  }
}

class UJobTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color? color;
  final TextStyle? style;

  const UJobTextButton({
    required this.label,
    this.onTap,
    this.color,
    this.style,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: style ??
            AppText.bodyBold.copyWith(
              color: color ?? AppColors.primary,
              decoration: TextDecoration.none,
            ),
      ),
    );
  }
}

class UJobBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? bgColor;

  const UJobBackButton({this.onTap, this.iconColor, this.bgColor, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.of(context).pop(),
      child: Container(
        width: 40.r,
        height: 40.r,
        decoration: BoxDecoration(
          color: bgColor ?? AppColors.borderLight,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: HugeIcon(
          icon: HugeIcons.strokeRoundedArrowLeft01,
          size: 18.r,
          color: iconColor ?? AppColors.text,
        ),
      ),
    );
  }
}
