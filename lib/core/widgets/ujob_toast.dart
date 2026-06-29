import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum ToastType { success, error, warning, info }

class UJobToast {
  static void success(BuildContext c, String title, {String sub = ''}) =>
      _show(c, title, sub, ToastType.success);

  static void error(BuildContext c, String title, {String sub = ''}) =>
      _show(c, title, sub, ToastType.error);

  static void warning(BuildContext c, String title, {String sub = ''}) =>
      _show(c, title, sub, ToastType.warning);

  static void info(BuildContext c, String title, {String sub = ''}) =>
      _show(c, title, sub, ToastType.info);

  static void _show(
    BuildContext context,
    String title,
    String sub,
    ToastType type, {
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlayState = Overlay.of(context);
    if (overlayState == null) return;
    
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastOverlay(
        duration: duration,
        onExpired: () {
          try {
            entry.remove();
          } catch (_) {}
        },
        child: _ToastCard(
          title: title,
          sub: sub,
          type: type,
          onClose: () {
            try {
              entry.remove();
            } catch (_) {}
          },
        ),
      ),
    );
    overlayState.insert(entry);
  }
}

class _ToastOverlay extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final VoidCallback onExpired;

  const _ToastOverlay({
    required this.child,
    required this.duration,
    required this.onExpired,
  });

  @override
  State<_ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<_ToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
    reverseDuration: const Duration(milliseconds: 220),
  );

  late final Animation<double> _fade = CurvedAnimation(
    parent: _ac,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );

  late final Animation<Offset> _slide =
      Tween<Offset>(begin: const Offset(0, -0.22), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _ac,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeIn,
        ),
      );

  late final Animation<double> _scale = Tween<double>(
    begin: 0.96,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _ac, curve: Curves.easeOutBack));

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _ac.forward();
    _timer = Timer(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    await _ac.reverse();
    widget.onExpired();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return Positioned(
      top: topInset + 12.h,
      left: 0,
      right: 0,
      child: IgnorePointer(
        ignoring: false,
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: ScaleTransition(
              scale: _scale,
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastCard extends StatelessWidget {
  final String title;
  final String sub;
  final ToastType type;
  final VoidCallback onClose;

  const _ToastCard({
    required this.title,
    required this.sub,
    required this.type,
    required this.onClose,
  });

  static final _specs = {
    ToastType.success: _Spec(
      bg: AppColors.successBg,
      border: const Color(0xFFABEFC6),
      iconBg: const Color(0xFFD1FADF),
      iconFg: AppColors.success,
      icon: HugeIcons.strokeRoundedCheckmarkCircle02,
    ),
    ToastType.error: _Spec(
      bg: AppColors.errorBg,
      border: const Color(0xFFFDA29B),
      iconBg: const Color(0xFFFEE4E2),
      iconFg: AppColors.error,
      icon: HugeIcons.strokeRoundedAlert01,
    ),
    ToastType.warning: _Spec(
      bg: AppColors.warningBg,
      border: const Color(0xFFFEC84B),
      iconBg: const Color(0xFFFEF0C7),
      iconFg: AppColors.warning,
      icon: HugeIcons.strokeRoundedAlert02,
    ),
    ToastType.info: _Spec(
      bg: const Color(0xFFEBF5FF),
      border: const Color(0xFFB2DDFF),
      iconBg: const Color(0xFFD1E9FF),
      iconFg: const Color(0xFF2E90FA),
      icon: HugeIcons.strokeRoundedInformationCircle,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final spec = _specs[type]!;
    return Dismissible(
      key: ValueKey(DateTime.now().microsecondsSinceEpoch),
      direction: DismissDirection.horizontal,
      onDismissed: (_) => onClose(),
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: spec.bg,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: spec.border),
            boxShadow: const [
              BoxShadow(
                blurRadius: 8,
                offset: Offset(0, 2),
                color: Color(0x1A000000),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 32.r,
                height: 32.r,
                decoration: BoxDecoration(
                  color: spec.iconBg,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: HugeIcon(
                  icon: spec.icon,
                  size: 18.r,
                  color: spec.iconFg,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppText.bodyBold.copyWith(color: AppColors.text),
                    ),
                    if (sub.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        sub,
                        style: AppText.bodyMd.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedCancel01,
                  size: 18.r,
                  color: AppColors.muted,
                ),
                onPressed: onClose,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Spec {
  final Color bg, border, iconBg, iconFg;
  final List<List<dynamic>> icon;
  const _Spec({
    required this.bg,
    required this.border,
    required this.iconBg,
    required this.iconFg,
    required this.icon,
  });
}
