import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/providers/onboarding_provider.dart';
import '../../core/providers/role_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/l10n_extensions.dart';
import '../../core/widgets/ujob_button.dart';
import '../../l10n/app_localizations.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _page = 0;

  late final AnimationController _entryCtrl;
  late final Animation<double> _entryFade;
  late final Animation<Offset> _entrySlide;

  List<_Slide> _getSlides(AppLocalizations l10n) => [
    _Slide(
      gradient: const [AppColors.onboardBlueStart, AppColors.onboardBlueEnd],
      accent: AppColors.primary,
      icon: HugeIcons.strokeRoundedSearch01,
      illustrationType: 0,
      title: l10n.onboardingSlide1Title,
      sub: l10n.onboardingSlide1Sub,
    ),
    _Slide(
      gradient: const [AppColors.purpleBg, AppColors.onboardPurpleEnd],
      accent: AppColors.purple,
      icon: HugeIcons.strokeRoundedBriefcase01,
      illustrationType: 1,
      title: l10n.onboardingSlide2Title,
      sub: l10n.onboardingSlide2Sub,
    ),
    _Slide(
      gradient: const [AppColors.successBg, AppColors.onboardGreenEnd],
      accent: AppColors.success,
      icon: HugeIcons.strokeRoundedSparkles,
      illustrationType: 2,
      title: l10n.onboardingSlide3Title,
      sub: l10n.onboardingSlide3Sub,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _entryFade = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));
    _entrySlide = Tween(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  Future<void> _markSeenAndGo() async {
    await ref.read(secureStorageProvider).saveOnboardingSeen();
    ref.invalidate(onboardingSeenProvider);
    if (mounted) context.go('/role-picker');
  }

  void _next(int slideCount) {
    if (_page < slideCount - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _markSeenAndGo();
    }
  }

  void _skip() => _markSeenAndGo();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final slides = _getSlides(l10n);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _entryFade,
          child: SlideTransition(
            position: _entrySlide,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 16.h,
                  ),
                  child: Row(
                    children: [
                      Row(
                        children: List.generate(
                          slides.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: EdgeInsets.only(right: 6.w),
                            width: i == _page ? 24.w : 8.w,
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: i == _page
                                  ? slides[_page].accent
                                  : AppColors.border,
                              borderRadius: AppRadius.pill,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      UJobTextButton(
                        label: l10n.skip,
                        onTap: _skip,
                        color: AppColors.muted,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageCtrl,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemCount: slides.length,
                    itemBuilder: (context, i) => _SlideView(slide: slides[i]),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                  child: UJobButton(
                    label: _page < slides.length - 1
                        ? l10n.continueButton
                        : l10n.getStarted,
                    onTap: () => _next(slides.length),
                    color: slides[_page].accent,
                    gradient: LinearGradient(
                      colors: [
                        slides[_page].accent.withValues(alpha: 0.85),
                        slides[_page].accent,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    icon: null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Slide {
  final List<Color> gradient;
  final Color accent;
  final List<List<dynamic>> icon;
  final int illustrationType;
  final String title;
  final String sub;

  const _Slide({
    required this.gradient,
    required this.accent,
    required this.icon,
    required this.illustrationType,
    required this.title,
    required this.sub,
  });
}

class _SlideView extends StatefulWidget {
  final _Slide slide;
  const _SlideView({required this.slide});

  @override
  State<_SlideView> createState() => _SlideViewState();
}

class _SlideViewState extends State<_SlideView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fade = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _slide = Tween(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _fade,
    child: SlideTransition(
      position: _slide,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.slide.gradient,
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: _IllustrationWidget(
                  type: widget.slide.illustrationType,
                  accent: widget.slide.accent,
                ),
              ),
            ),
            SizedBox(height: 28.h),
            Text(
              widget.slide.title,
              style: AppText.heading1.copyWith(
                letterSpacing: -0.8,
                height: 1.15,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              widget.slide.sub,
              style: AppText.body.copyWith(color: AppColors.muted),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    ),
  );
}

class _IllustrationWidget extends StatefulWidget {
  final int type;
  final Color accent;
  const _IllustrationWidget({required this.type, required this.accent});

  @override
  State<_IllustrationWidget> createState() => _IllustrationWidgetState();
}

class _IllustrationWidgetState extends State<_IllustrationWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatCtrl;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _floatCtrl,
    builder: (_, _) => Padding(
      padding: EdgeInsets.all(32.r),
      child: Transform.translate(
        offset: Offset(0, math.sin(_floatCtrl.value * math.pi) * 8.h),
        child: switch (widget.type) {
          0 => _JobSearchIllustration(accent: widget.accent),
          1 => _HireIllustration(accent: widget.accent),
          _ => _AIIllustration(accent: widget.accent),
        },
      ),
    ),
  );
}

class _JobSearchIllustration extends StatelessWidget {
  final Color accent;
  const _JobSearchIllustration({required this.accent});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: AppShadow.cardMd(),
        ),
        child: Row(
          children: [
            SizedBox(width: 14.w),
            HugeIcon(
              icon: HugeIcons.strokeRoundedSearch01,
              color: accent,
              size: 18.r,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Container(
                height: 10.h,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: AppRadius.pill,
                ),
              ),
            ),
            SizedBox(width: 14.w),
          ],
        ),
      ),
      SizedBox(height: 14.h),
      ..._mockJobs(accent),
    ],
  );

  List<Widget> _mockJobs(Color accent) {
    final jobs = [
      (AppColors.error, 'A', '47 applicants'),
      (AppColors.purple, 'S', '89 applicants'),
      (AppColors.success, 'V', '123 applicants'),
    ];
    return jobs.map((j) {
      final (color, letter, count) = j;
      return Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: AppShadow.card(),
        ),
        child: Row(
          children: [
            Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(9.r),
              ),
              child: Center(
                child: Text(
                  letter,
                  style: AppText.bodyBold.copyWith(color: AppColors.surface),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 9.h,
                    width: 100.w,
                    decoration: BoxDecoration(
                      color: AppColors.text2.withValues(alpha: 0.7),
                      borderRadius: AppRadius.pill,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Container(
                    height: 7.h,
                    width: 70.w,
                    decoration: BoxDecoration(
                      color: AppColors.muted2,
                      borderRadius: AppRadius.pill,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                borderRadius: AppRadius.pill,
              ),
              child: Text(
                count.split(' ')[0],
                style: AppText.labelSm.copyWith(color: accent),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

class _HireIllustration extends StatelessWidget {
  final Color accent;
  const _HireIllustration({required this.accent});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: AppShadow.cardMd(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: AppRadius.pill,
                  ),
                  child: Text(
                    '+ Post Job',
                    style: AppText.label.copyWith(color: accent),
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: AppRadius.pill,
                  ),
                  child: Text(
                    'Applicants',
                    style: AppText.label.copyWith(color: AppColors.text2),
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Text(
              'Recent Applicants',
              style: AppText.small.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 10.h),
            Row(
              children: ['SC', 'AH', 'MG', 'JK'].asMap().entries.map((e) {
                const colors = [
                  AppColors.primary,
                  AppColors.purple,
                  AppColors.success,
                  AppColors.warning,
                ];
                return Transform.translate(
                  offset: Offset(-(e.key * 8.w), 0),
                  child: Container(
                    width: 36.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      color: colors[e.key % colors.length],
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        e.value,
                        style: AppText.labelSm.copyWith(
                          color: AppColors.surface,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      SizedBox(height: 12.h),
      Row(
        children: [
          _StatMini(value: '47', label: context.l10n.activeJobs, color: accent),
          SizedBox(width: 10.w),
          _StatMini(
            value: '124',
            label: context.l10n.applicants,
            color: accent,
          ),
          SizedBox(width: 10.w),
          _StatMini(value: '18', label: context.l10n.thisWeek, color: accent),
        ],
      ),
    ],
  );
}

class _StatMini extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatMini({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: AppShadow.card(),
      ),
      child: Column(
        children: [
          Text(value, style: AppText.heading3.copyWith(color: color)),
          Text(
            label,
            style: AppText.overline.copyWith(
              color: AppColors.muted,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class _AIIllustration extends StatelessWidget {
  final Color accent;
  const _AIIllustration({required this.accent});

  static const _salaryBars = [0.45, 0.62, 0.55, 0.78, 0.70, 0.90];

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      // AI Match score card
      Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: AppShadow.cardMd(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32.r,
                  height: 32.r,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(9.r),
                  ),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedSparkles,
                    size: 16.r,
                    color: accent,
                  ),
                ),
                SizedBox(width: 8.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Match Score',
                      style: AppText.labelSm.copyWith(color: AppColors.muted),
                    ),
                    Text(
                      '98% Compatible',
                      style: AppText.small.copyWith(
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.10),
                    borderRadius: AppRadius.pill,
                  ),
                  child: Text(
                    'Live',
                    style: AppText.overline.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            ClipRRect(
              borderRadius: AppRadius.pill,
              child: LinearProgressIndicator(
                value: 0.98,
                minHeight: 7.h,
                color: accent,
                backgroundColor: accent.withValues(alpha: 0.12),
              ),
            ),
            SizedBox(height: 10.h),
            // Pill tags
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: [
                _Tag(label: context.l10n.personalised, accent: accent),
                _Tag(label: context.l10n.realtime, accent: accent),
                _Tag(label: context.l10n.updatedDaily, accent: accent),
              ],
            ),
          ],
        ),
      ),
      SizedBox(height: 10.h),
      // Salary insights mini chart
      Container(
        padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 10.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: AppShadow.card(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Salary Insights',
                  style: AppText.small.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  '+18% avg',
                  style: AppText.labelSm.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            SizedBox(
              height: 36.h,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _salaryBars.asMap().entries.map((e) {
                  final isLast = e.key == _salaryBars.length - 1;
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 2.w),
                      height: 36.h * e.value,
                      decoration: BoxDecoration(
                        color: isLast
                            ? accent
                            : accent.withValues(alpha: 0.25 + e.key * 0.08),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(4.r),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _Tag extends StatelessWidget {
  final String label;
  final Color accent;
  const _Tag({required this.label, required this.accent});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
    decoration: BoxDecoration(
      color: accent.withValues(alpha: 0.10),
      borderRadius: AppRadius.pill,
    ),
    child: Text(
      label,
      style: AppText.overline.copyWith(
        color: accent,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
