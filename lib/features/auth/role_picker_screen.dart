import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;
import 'package:hugeicons/hugeicons.dart';
import 'package:ujobs_app/core/theme/app_colors.dart';
import 'package:ujobs_app/core/theme/app_text_styles.dart';
import '../../core/utils/l10n_extensions.dart';
import '../../core/widgets/ujob_button.dart';
import '../../core/widgets/ujob_logo.dart';

class RolePickerScreen extends StatefulWidget {
  final VoidCallback? onJobSeeker;
  final VoidCallback? onEmployer;
  final VoidCallback? onSignIn;

  const RolePickerScreen({
    super.key,
    this.onJobSeeker,
    this.onEmployer,
    this.onSignIn,
  });

  @override
  State<RolePickerScreen> createState() => _RolePickerScreenState();
}

class _RolePickerScreenState extends State<RolePickerScreen>
    with TickerProviderStateMixin {
  late final AnimationController _enterCtrl;

  // Header
  late final Animation<double> _headerFade;
  late final Animation<double> _headerSlide;

  // Job Seeker Card (Left)
  late final Animation<double> _seekerFade;
  late final Animation<double> _seekerSlide;

  // Employer Card (Right)
  late final Animation<double> _employerFade;
  late final Animation<double> _employerSlide;

  // Bottom Section
  late final Animation<double> _bottomFade;
  late final Animation<double> _bottomSlide;

  static const double _totalMs = 1100;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    // MAIN ENTRANCE ANIMATION CONTROLLER
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    CurvedAnimation interval(double startMs, double endMs) =>
        CurvedAnimation(
          parent: _enterCtrl,
          curve: Interval(
            startMs / _totalMs,
            endMs / _totalMs,
            curve: Curves.easeOutCubic, // smoother deceleration
          ),
        );

    // 1. Header (100ms → 500ms)
    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(interval(100, 500));
    _headerSlide = Tween<double>(begin: -20.0, end: 0.0).animate(interval(100, 500));

    // 2. Job Seeker Card Z-Axis Entry (300ms → 750ms)
    _seekerFade = Tween<double>(begin: 0.0, end: 1.0).animate(interval(300, 750));
    _seekerSlide = Tween<double>(begin: 30.0, end: 0.0).animate(interval(300, 750));

    // 3. Employer Card Z-Axis Entry (400ms → 850ms)
    _employerFade = Tween<double>(begin: 0.0, end: 1.0).animate(interval(400, 850));
    _employerSlide = Tween<double>(begin: 30.0, end: 0.0).animate(interval(400, 850));

    // 4. Bottom Text & Button (600ms → 1100ms)
    _bottomFade = Tween<double>(begin: 0.0, end: 1.0).animate(interval(600, 1100));
    _bottomSlide = Tween<double>(begin: 40.0, end: 0.0).animate(interval(600, 1100));

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _enterCtrl.forward();
    });
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Determine screen height to dynamically size the blue background
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: AnimatedBuilder(
        animation: _enterCtrl,
        builder: (context, child) {
          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // ── 1. The Blue Gradient Background & Ambient Ring ──
              Positioned(
                top: 0, left: 0, right: 0,
                height: screenHeight * 0.44,
                child: const _BlueBackgroundWithRing(),
              ),

              // ── 2. The Main Content Layer ──
              Padding(
                padding: EdgeInsets.only(top: topPadding + 20.h),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            // --- Header Section ---
                            Opacity(
                              opacity: _headerFade.value,
                              child: Transform.translate(
                                offset: Offset(0, _headerSlide.value),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          UJobLogo(variant: LogoVariant.color, height: 88.r),
                                        ],
                                      ),
                                      SizedBox(height: 24.h),
                                      Text(
                                        l10n.rolePickerTagline,
                                        style: AppText.heroTitle.copyWith(color: AppColors.surface),
                                      ),
                                      SizedBox(height: 12.h),
                                      Text(
                                        l10n.rolePickerSubtitle,
                                        style: AppText.body.copyWith(
                                          color: AppColors.surface.withValues(alpha: 0.9),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 40.h),
                            // --- Cards Section ---
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Opacity(
                                      opacity: _seekerFade.value,
                                      child: Transform.translate(
                                        offset: Offset(-_seekerSlide.value, 0),
                                        child: _InteractiveRoleCard(
                                          icon: HugeIcons.strokeRoundedJobSearch,
                                          iconBgColor: AppColors.primaryAccent,
                                          title: l10n.jobSeekerTab,
                                          subtitle: l10n.roleJobSeekerSub,
                                          onTap: widget.onJobSeeker,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: Opacity(
                                      opacity: _employerFade.value,
                                      child: Transform.translate(
                                        offset: Offset(_employerSlide.value, 0),
                                        child: _InteractiveRoleCard(
                                          icon: HugeIcons.strokeRoundedBuilding04,
                                          iconBgColor: AppColors.primaryDark,
                                          title: l10n.employerTab,
                                          subtitle: l10n.roleEmployerSub,
                                          onTap: widget.onEmployer,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // --- Bottom Section (Fixed) ---
                    Opacity(
                      opacity: _bottomFade.value,
                      child: Transform.translate(
                        offset: Offset(0, _bottomSlide.value),
                        child: _BottomSection(onSignIn: widget.onSignIn),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// The Blue Background with the Continuous Ambient Rotating Ring
// ─────────────────────────────────────────────────────────────────────────────
class _BlueBackgroundWithRing extends StatefulWidget {
  const _BlueBackgroundWithRing();

  @override
  State<_BlueBackgroundWithRing> createState() => _BlueBackgroundWithRingState();
}

class _BlueBackgroundWithRingState extends State<_BlueBackgroundWithRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinCtrl;

  @override
  void initState() {
    super.initState();
    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40), // Very slow, ambient rotation
    )..repeat();
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0EA5C9), // Bright Cyan
            Color(0xFF0891B2), // Mid Teal
            Color(0xFF0E7490), // Deeper Teal
          ],
        ),
      ),
      child: Stack(
        children: [
          // The faint circular decoration floating in the top right
          Positioned(
            top: -100.h,
            right: -80.w,
            child: AnimatedBuilder(
              animation: _spinCtrl,
              builder: (_, child) {
                return Transform.rotate(
                  angle: _spinCtrl.value * 2.0 * math.pi,
                  child: child,
                );
              },
              child: Container(
                width: 300.r,
                height: 300.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.surface.withValues(alpha: 0.06), // Very subtle
                    width: 2.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Interactive Role Card (With Tactile "Squish" Effect)
// ─────────────────────────────────────────────────────────────────────────────
class _InteractiveRoleCard extends StatefulWidget {
  final List<List<dynamic>> icon;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _InteractiveRoleCard({
    required this.icon,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  State<_InteractiveRoleCard> createState() => _InteractiveRoleCardState();
}

class _InteractiveRoleCardState extends State<_InteractiveRoleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _tapCtrl;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _tapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _tapCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _tapCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) => _tapCtrl.forward();
  
  void _onTapUp(TapUpDetails details) {
    _tapCtrl.reverse();
    if (widget.onTap != null) {
      // Slight delay so the user sees the button bounce back before navigating
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
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.text.withValues(alpha:
                      _tapCtrl.isAnimating || _tapCtrl.isCompleted ? 0.02 : 0.08
                    ),
                    blurRadius: _tapCtrl.isAnimating ? 4 : 20,
                    offset: Offset(0, _tapCtrl.isAnimating ? 2 : 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
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
                  // Title
                  Text(
                    widget.title,
                    style: AppText.titleMd.copyWith(color: AppColors.text),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6.h),
                  // Subtitle
                  Text(
                    widget.subtitle,
                    style: AppText.cardSubtitle.copyWith(color: AppColors.muted),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Section
// ─────────────────────────────────────────────────────────────────────────────
class _BottomSection extends StatelessWidget {
  final VoidCallback? onSignIn;

  const _BottomSection({this.onSignIn});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 24.w,
        right: 24.w,
        bottom: bottomPadding + 24.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.alreadyHaveAccount.trim(),
            style: AppText.body.copyWith(color: AppColors.muted),
          ),
          SizedBox(height: 16.h),
          UJobButton(
            label: l10n.signIn,
            onTap: onSignIn,
            outlined: true,
          ),
        ],
      ),
    );
  }
}