import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/role_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/l10n_extensions.dart';
import '../../core/widgets/ujob_auth_links.dart';
import '../../core/widgets/ujob_button.dart';
import '../../core/widgets/ujob_checkbox.dart';
import '../../core/widgets/ujob_logo.dart';
import '../../core/widgets/ujob_text_field.dart';
import '../../core/widgets/ujob_toast.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String initialRole;
  const LoginScreen({this.initialRole = 'seeker', super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  late String _role;
  bool _rememberMe = false;
  bool _loading = false;

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
    _seqCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _cardFade = Tween(begin: 0.0, end: 1.0).animate(_iv(0, 600));
    _cardSlide = Tween(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(_iv(0, 600));
    _emailFade = Tween(begin: 0.0, end: 1.0).animate(_iv(200, 500));
    _passwordFade = Tween(begin: 0.0, end: 1.0).animate(_iv(300, 600));
    _actionsFade = Tween(begin: 0.0, end: 1.0).animate(_iv(400, 700));
    _bottomFade = Tween(begin: 0.0, end: 1.0).animate(_iv(500, 800));

    _emailCtrl.addListener(() {
      if (_emailError != null) setState(() => _emailError = null);
    });
    _passwordCtrl.addListener(() {
      if (_passError != null) setState(() => _passError = null);
    });

    _loadRememberedData();
    _seqCtrl.forward();
  }

  Future<void> _loadRememberedData() async {
    final storage = ref.read(secureStorageProvider);
    final email = await storage.getRememberedEmail();
    final password = await storage.getRememberedPassword();
    if (email != null && password != null) {
      if (mounted) {
        setState(() {
          _emailCtrl.text = email;
          _passwordCtrl.text = password;
          _rememberMe = true;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _emailCtrl.text = _role == 'employer'
              ? 'nexoviasolutions@gmail.com'
              : 'mdazadhossain95@gmail.com';
          _passwordCtrl.text = 'Azad613051@';
        });
      }
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _seqCtrl.dispose();
    super.dispose();
  }

  String? _emailError;
  String? _passError;

  void _login() async {
    final emailEmpty = _emailCtrl.text.trim().isEmpty;
    final passEmpty = _passwordCtrl.text.isEmpty;

    if (emailEmpty || passEmpty) {
      setState(() {
        _emailError = emailEmpty ? context.l10n.errorEnterEmail : null;
        _passError = passEmpty ? context.l10n.errorRequiredField : null;
      });
      return;
    }

    if (_emailError != null || _passError != null) {
      setState(() {
        _emailError = null;
        _passError = null;
      });
    }

    // Dismiss keyboard
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() => _loading = true);
    final (result, userId) = await ref
        .read(authProvider.notifier)
        .login(_emailCtrl.text.trim(), _passwordCtrl.text, _role);
        
    if (mounted) setState(() => _loading = false);

    if (!mounted) return;

    switch (result) {
      case LoginResult.success:
        UJobToast.success(
          context,
          'Login Successful',
          sub: 'Welcome back!',
        );
        final storage = ref.read(secureStorageProvider);
        if (_rememberMe) {
          await storage.saveRememberMe(_emailCtrl.text.trim(), _passwordCtrl.text);
        } else {
          await storage.clearRememberMe();
        }
        
        if (_role == 'employer') {
          context.go('/employer');
        } else {
          context.go('/seeker');
        }
        break;

      case LoginResult.requiresOtp:
        if (mounted) {
          context.push('/otp', extra: userId);
        }
        break;

      case LoginResult.invalidCredentials:
        setState(() {
          _passError = 'Invalid email or password';
          _emailError = 'Invalid email or password';
        });
        break;

      case LoginResult.suspended:
        if (mounted) context.go('/suspended');
        break;

      case LoginResult.locked:
        UJobToast.error(context, 'Account Locked', sub: userId ?? 'Too many failed attempts.');
        if (mounted) context.go('/locked', extra: userId);
        break;

      case LoginResult.error:
        UJobToast.error(context, 'Login Failed', sub: userId ?? 'A network error occurred. Please try again.');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                      Color.lerp(
                        AppColors.primaryDark,
                        AppColors.primaryDeep,
                        t,
                      )!,
                      Color.lerp(AppColors.primary, AppColors.primaryDark, t)!,
                      Color.lerp(
                        AppColors.primaryAccent,
                        AppColors.primary,
                        t,
                      )!,
                    ],
                  ),
                ),
                padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 56.h),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),
                      UJobLogo(variant: LogoVariant.color, height: 60.h),
                      SizedBox(height: 24.h),
                      Text(
                        l10n.welcomeBack,
                        style: AppText.heading1.copyWith(
                          color: AppColors.surface,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, anim) =>
                            FadeTransition(opacity: anim, child: child),
                        child: Text(
                          _role == 'employer'
                              ? l10n.signInAsEmployer
                              : l10n.loginSubtitle,
                          key: ValueKey(_role),
                          style: AppText.body.copyWith(
                            color: AppColors.surface.withValues(alpha: 0.75),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // White card overlapping header
            Transform.translate(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SlidingTabs(
                            selected: _role,
                            onChanged: (r) {
                              setState(() {
                                _role = r;
                                final currentEmail = _emailCtrl.text.trim();
                                if (currentEmail.isEmpty ||
                                    currentEmail == 'mdazadhossain95@gmail.com' ||
                                    currentEmail == 'nexoviasolutions@gmail.com' ||
                                    currentEmail == 'john.doe@example.com') {
                                  _emailCtrl.text = r == 'employer'
                                      ? 'nexoviasolutions@gmail.com'
                                      : 'mdazadhossain95@gmail.com';
                                  _passwordCtrl.text = 'Azad613051@';
                                }
                              });
                            },
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
                              errorText: _emailError,
                              isRequired: true,
                              isEmail: true,
                            ),
                          ),
                          SizedBox(height: 16.h),

                          FadeTransition(
                            opacity: _passwordFade,
                            child: UJobTextField(
                              label: l10n.passwordLabel,
                              hint: l10n.passwordHint,
                              controller: _passwordCtrl,
                              isPassword: true,
                              textInputAction: TextInputAction.done,
                              errorText: _passError,
                              isRequired: true,
                            ),
                          ),

                          FadeTransition(
                            opacity: _actionsFade,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 12.h),
                                Row(
                                  children: [
                                    UJobCheckbox(
                                      value: _rememberMe,
                                      onChanged: (value) =>
                                          setState(() => _rememberMe = value),
                                      label: l10n.rememberMe,
                                    ),
                                    const Spacer(),
                                    GestureDetector(
                                      onTap: () =>
                                          context.push('/forgot-password'),
                                      child: Text(
                                        l10n.forgotPassword,
                                        style: AppText.label.copyWith(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16.h),
                                UJobButton(label: l10n.logIn, onTap: _login, isLoading: _loading),
                              ],
                            ),
                          ),
                          SizedBox(height: 16.h),

                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                child: Text(
                                  l10n.orContinueWith,
                                  style: AppText.small.copyWith(
                                    color: AppColors.muted,
                                  ),
                                ),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          FadeTransition(
                            opacity: _bottomFade,
                            child: UJobAuthLinks(
                              primaryText: l10n.dontHaveAccount,
                              primaryLinkText: l10n.signUpFree,
                              onPrimaryTap: () => context.push(
                                _role == 'employer'
                                    ? '/register/employer'
                                    : '/register/seeker',
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
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
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.muted,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
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
        },
      ),
    );
  }
}
