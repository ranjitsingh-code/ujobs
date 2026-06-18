import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/l10n_extensions.dart';
import '../../core/widgets/ujob_button.dart';
import '../../core/widgets/ujob_logo.dart';
import '../../core/widgets/ujob_text_field.dart';

class LoginScreen extends StatefulWidget {
  final String initialRole;
  const LoginScreen({this.initialRole = 'seeker', super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  late String _role;

  late final AnimationController _seqCtrl;
  late final Animation<double> _cardFade;
  late final Animation<Offset> _cardSlide;
  late final Animation<double> _emailFade;
  late final Animation<double> _passwordFade;
  late final Animation<double> _actionsFade;
  late final Animation<double> _bottomFade;

  static const double _ms = 900;

  CurvedAnimation _iv(double start, double end) => CurvedAnimation(
    parent: _seqCtrl,
    curve: Interval(start / _ms, end / _ms, curve: Curves.easeOutCubic),
  );

  @override
  void initState() {
    super.initState();
    _role = widget.initialRole;
    _seqCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _cardFade     = Tween(begin: 0.0, end: 1.0).animate(_iv(0, 600));
    _cardSlide    = Tween(begin: const Offset(0, 0.18), end: Offset.zero).animate(_iv(0, 600));
    _emailFade    = Tween(begin: 0.0, end: 1.0).animate(_iv(200, 500));
    _passwordFade = Tween(begin: 0.0, end: 1.0).animate(_iv(300, 600));
    _actionsFade  = Tween(begin: 0.0, end: 1.0).animate(_iv(400, 700));
    _bottomFade   = Tween(begin: 0.0, end: 1.0).animate(_iv(500, 800));
    _seqCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _seqCtrl.dispose();
    super.dispose();
  }

  void _login() {
    // TODO: wire API when UI sign-off complete
    if (_role == 'employer') {
      context.go('/employer');
    } else {
      context.go('/seeker');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        // Header gradient shifts darker for employer
        TweenAnimationBuilder<double>(
          tween: Tween(end: _role == 'employer' ? 1.0 : 0.0),
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          builder: (context, t, _) => Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(AppColors.primaryDark,   AppColors.primaryDeep, t)!,
                  Color.lerp(AppColors.primary,       AppColors.primaryDark, t)!,
                  Color.lerp(AppColors.primaryAccent, AppColors.primary,     t)!,
                ],
              ),
            ),
            padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 56.h),
            child: SafeArea(
              bottom: false,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(height: 20.h),
                UJobLogo(variant: LogoVariant.color, height: 60.h),
                SizedBox(height: 24.h),
                Text(l10n.welcomeBack,
                    style: AppText.heading1.copyWith(color: AppColors.surface)),
                SizedBox(height: 4.h),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, anim) =>
                      FadeTransition(opacity: anim, child: child),
                  child: Text(
                    _role == 'employer'
                        ? 'Sign in as an Employer'
                        : l10n.loginSubtitle,
                    key: ValueKey(_role),
                    style: AppText.body.copyWith(
                        color: AppColors.surface.withValues(alpha: 0.75)),
                  ),
                ),
              ]),
            ),
          ),
        ),

        // White card overlapping header
        Expanded(
          child: SingleChildScrollView(
            child: Transform.translate(
              offset: Offset(0, -20.h),
              child: Padding(
                padding: EdgeInsets.only(bottom: 24.h),
                child: FadeTransition(
                  opacity: _cardFade,
                  child: SlideTransition(
                    position: _cardSlide,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.w),
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: AppShadow.modal(),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _SlidingTabs(
                          selected: _role,
                          onChanged: (r) => setState(() => _role = r),
                          labels: [l10n.jobSeekerTab, l10n.employerTab],
                          values: const ['seeker', 'employer'],
                        ),
                        SizedBox(height: 20.h),

                        FadeTransition(
                          opacity: _emailFade,
                          child: UJobTextField(
                            label: l10n.emailLabel,
                            hint: l10n.emailHint,
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                          ),
                        ),

                        FadeTransition(
                          opacity: _passwordFade,
                          child: UJobTextField(
                            label: l10n.passwordLabel,
                            hint: l10n.passwordHint,
                            controller: _passwordCtrl,
                            isPassword: true,
                            textInputAction: TextInputAction.done,
                          ),
                        ),

                        FadeTransition(
                          opacity: _actionsFade,
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => context.push('/forgot-password'),
                                style: TextButton.styleFrom(
                                  minimumSize: Size.zero,
                                  padding: EdgeInsets.symmetric(vertical: 4.h),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(l10n.forgotPassword,
                                    style: AppText.label.copyWith(color: AppColors.primary)),
                              ),
                            ),
                            SizedBox(height: 16.h),
                            UJobButton(label: l10n.signIn, onTap: _login),
                          ]),
                        ),
                        SizedBox(height: 20.h),

                        FadeTransition(
                          opacity: _bottomFade,
                          child: Center(
                            child: TextButton(
                              onPressed: () => context.push(
                                _role == 'employer'
                                    ? '/register/employer'
                                    : '/register/seeker',
                              ),
                              style: TextButton.styleFrom(
                                minimumSize: Size.zero,
                                padding: EdgeInsets.symmetric(vertical: 4.h),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: RichText(
                                text: TextSpan(
                                  style: AppText.small.copyWith(color: AppColors.muted),
                                  children: [
                                    TextSpan(text: l10n.dontHaveAccount),
                                    TextSpan(
                                      text: l10n.createAccountLink,
                                      style: AppText.small.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// Sliding pill tab switcher — pill moves via AnimatedPositioned
class _SlidingTabs extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  final List<String> labels;
  final List<String> values;

  const _SlidingTabs({
    required this.selected,
    required this.onChanged,
    required this.labels,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.h,
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        final pillW = constraints.maxWidth / values.length;
        final idx = values.indexOf(selected);
        return Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              left: idx * pillW,
              top: 0,
              bottom: 0,
              width: pillW,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(9.r),
                  boxShadow: AppShadow.card(),
                ),
              ),
            ),
            Row(
              children: List.generate(values.length, (i) {
                final isSelected = values[i] == selected;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged(values[i]),
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: AppText.label.copyWith(
                          color: isSelected ? AppColors.primary : AppColors.muted,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        child: Text(labels[i]),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      }),
    );
  }
}
