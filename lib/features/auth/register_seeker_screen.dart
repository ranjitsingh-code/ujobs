import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/role_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/ujob_button.dart';
import '../../core/widgets/ujob_text_field.dart';

import '../../core/utils/l10n_extensions.dart';

class RegisterSeekerScreen extends ConsumerStatefulWidget {
  const RegisterSeekerScreen({super.key});

  @override
  ConsumerState<RegisterSeekerScreen> createState() => _RegisterSeekerScreenState();
}

class _RegisterSeekerScreenState extends ConsumerState<RegisterSeekerScreen>
    with SingleTickerProviderStateMixin {
  int _step = 1;

  // Step 1 controllers
  final _firstCtrl   = TextEditingController();
  final _lastCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();

  // Step 2 controllers
  final _titleCtrl    = TextEditingController();
  final _locationCtrl = TextEditingController();
  String _experience  = '';

  bool _loading = false;
  String? _error;

  late final AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    for (final c in [_firstCtrl, _lastCtrl, _emailCtrl, _phoneCtrl, _passCtrl, _confirmCtrl, _titleCtrl, _locationCtrl]) {
      c.dispose();
    }
    _animCtrl.dispose();
    super.dispose();
  }

  void _goStep2() {
    final l10n = context.l10n;
    if (_firstCtrl.text.trim().isEmpty || _lastCtrl.text.trim().isEmpty) {
      setState(() => _error = l10n.errorFirstLast);
      return;
    }
    if (_emailCtrl.text.trim().isEmpty || !_emailCtrl.text.contains('@')) {
      setState(() => _error = l10n.errorValidEmail);
      return;
    }
    if (_passCtrl.text.length < 8) {
      setState(() => _error = l10n.errorPasswordLength);
      return;
    }
    if (_passCtrl.text != _confirmCtrl.text) {
      setState(() => _error = l10n.errorPasswordMatch);
      return;
    }
    setState(() { _step = 2; _error = null; });
    _animCtrl.forward(from: 0);
  }

  Future<void> _register() async {
    final l10n = context.l10n;
    setState(() { _loading = true; _error = null; });
    try {
      final dio = ref.read(dioClientProvider).dio;
      final res = await dio.post(Ep.registerSeeker, data: {
        'first_name': _firstCtrl.text.trim(),
        'last_name':  _lastCtrl.text.trim(),
        'email':      _emailCtrl.text.trim(),
        'phone':      _phoneCtrl.text.trim(),
        'password':   _passCtrl.text,
      });

      final data = (res.data['data'] ?? res.data) as Map<String, dynamic>;
      final accessToken  = data['accessToken']  as String? ?? '';
      final refreshToken = data['refreshToken'] as String? ?? '';
      if (accessToken.isNotEmpty) {
        await ref.read(secureStorageProvider).saveTokens(accessToken, refreshToken);
        await ref.read(secureStorageProvider).saveRole('job_seeker');
        ref.read(activeRoleProvider.notifier).setRole('job_seeker');
        ref.invalidate(authProvider);
      }
      if (mounted) context.go('/otp');
    } catch (_) {
      if (mounted) setState(() => _error = l10n.errorRegistrationFailed);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(children: [
          // Top bar
          _TopBar(step: _step, total: 2, onBack: _step == 1 ? () => context.pop() : () => setState(() { _step = 1; _error = null; })),
          // Content
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween(begin: const Offset(0.04, 0), end: Offset.zero).animate(anim),
                  child: child,
                ),
              ),
              child: _step == 1
                  ? _Step1(
                      key: const ValueKey(1),
                      firstCtrl: _firstCtrl,
                      lastCtrl: _lastCtrl,
                      emailCtrl: _emailCtrl,
                      phoneCtrl: _phoneCtrl,
                      passCtrl: _passCtrl,
                      confirmCtrl: _confirmCtrl,
                      error: _error,
                      onContinue: _goStep2,
                      onSignIn: () => context.go('/login'),
                    )
                  : _Step2(
                      key: const ValueKey(2),
                      titleCtrl: _titleCtrl,
                      locationCtrl: _locationCtrl,
                      experience: _experience,
                      onExperienceChanged: (v) => setState(() => _experience = v),
                      error: _error,
                      loading: _loading,
                      onRegister: _register,
                      onSignIn: () => context.go('/login'),
                    ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final int step, total;
  final VoidCallback onBack;
  const _TopBar({required this.step, required this.total, required this.onBack});

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 36.r, height: 36.r,
              decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(10.r)),
              child: HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, size: 20.r, color: AppColors.text),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: ClipRRect(
              borderRadius: AppRadius.pill,
              child: LinearProgressIndicator(
                value: step / total,
                minHeight: 5.h,
                color: AppColors.primary,
                backgroundColor: AppColors.border,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Text('$step/$total', style: AppText.small.copyWith(color: AppColors.muted, fontWeight: FontWeight.w500)),
        ]),
      );
}

class _Step1 extends StatelessWidget {
  final TextEditingController firstCtrl, lastCtrl, emailCtrl, phoneCtrl, passCtrl, confirmCtrl;
  final String? error;
  final VoidCallback onContinue, onSignIn;

  const _Step1({
    super.key,
    required this.firstCtrl,
    required this.lastCtrl,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.passCtrl,
    required this.confirmCtrl,
    required this.error,
    required this.onContinue,
    required this.onSignIn,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(height: 8.h),
        Text(l10n.createAccountTitle, style: AppText.heading2),
        SizedBox(height: 4.h),
        Text(l10n.createAccountSub, style: AppText.small.copyWith(color: AppColors.muted)),
        SizedBox(height: 24.h),
        // Name row
        Row(children: [
          Expanded(child: UJobTextField(label: l10n.firstName, hint: l10n.firstNameHint, controller: firstCtrl, textInputAction: TextInputAction.next)),
          SizedBox(width: 12.w),
          Expanded(child: UJobTextField(label: l10n.lastName, hint: l10n.lastNameHint, controller: lastCtrl, textInputAction: TextInputAction.next)),
        ]),
        UJobTextField(label: l10n.email, hint: l10n.emailHint, controller: emailCtrl, keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next),
        UJobTextField(label: l10n.phone, hint: l10n.phoneHint, controller: phoneCtrl, keyboardType: TextInputType.phone, textInputAction: TextInputAction.next),
        UJobTextField(
          label: l10n.password,
          hint: l10n.passwordCreateHint,
          controller: passCtrl,
          isPassword: true,
          textInputAction: TextInputAction.next,
        ),
        UJobTextField(
          label: l10n.confirmPassword,
          hint: l10n.confirmPasswordHint,
          controller: confirmCtrl,
          isPassword: true,
          textInputAction: TextInputAction.done,
        ),
        if (error != null) ...[
          _ErrorBox(error!),
          SizedBox(height: 8.h),
        ],
        UJobButton(label: l10n.continueButton, onTap: onContinue),
        SizedBox(height: 16.h),
        _SignInLink(onTap: onSignIn),
        SizedBox(height: 16.h),
      ]),
    );
  }
}

class _Step2 extends StatelessWidget {
  final TextEditingController titleCtrl, locationCtrl;
  final String experience;
  final ValueChanged<String> onExperienceChanged;
  final String? error;
  final bool loading;
  final VoidCallback onRegister, onSignIn;

  const _Step2({
    super.key,
    required this.titleCtrl,
    required this.locationCtrl,
    required this.experience,
    required this.onExperienceChanged,
    required this.error,
    required this.loading,
    required this.onRegister,
    required this.onSignIn,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(height: 8.h),
        Text(l10n.profileBackgroundTitle, style: AppText.heading2),
        SizedBox(height: 4.h),
        Text(l10n.profileBackgroundSub, style: AppText.small.copyWith(color: AppColors.muted)),
        SizedBox(height: 24.h),
        UJobTextField(label: l10n.jobTitleLabel, hint: l10n.jobTitleHint, controller: titleCtrl, textInputAction: TextInputAction.next),
        UJobTextField(label: l10n.locationLabel, hint: l10n.locationHint, controller: locationCtrl, textInputAction: TextInputAction.done),
        // Experience dropdown
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l10n.experienceLabel, style: AppText.label.copyWith(color: AppColors.muted)),
          SizedBox(height: 6.h),
          Container(
            height: 52.h,
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(12.r),
            ),
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: experience.isEmpty ? null : experience,
                hint: Text(l10n.selectPlaceholder, style: AppText.body.copyWith(color: AppColors.muted2)),
                isExpanded: true,
                icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowDown01, color: AppColors.muted, size: 20),
                style: AppText.body,
                items: [
                  (l10n.exp1Year, '< 1 year'),
                  (l10n.exp12Years, '1–2 years'),
                  (l10n.exp35Years, '3–5 years'),
                  (l10n.exp610Years, '6–10 years'),
                  (l10n.exp10PlusYears, '10+ years'),
                ]
                    .map((e) => DropdownMenuItem(value: e.$2, child: Text(e.$1)))
                    .toList(),
                onChanged: (v) => v != null ? onExperienceChanged(v) : null,
              ),
            ),
          ),
          SizedBox(height: 16.h),
        ]),
        if (error != null) ...[
          _ErrorBox(error!),
          SizedBox(height: 8.h),
        ],
        UJobButton(label: l10n.createAccount, onTap: onRegister, isLoading: loading),
        SizedBox(height: 16.h),
        _SignInLink(onTap: onSignIn),
        SizedBox(height: 16.h),
      ]),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox(this.message);

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(color: AppColors.errorBg, borderRadius: AppRadius.md),
        child: Row(children: [
          HugeIcon(icon: HugeIcons.strokeRoundedAlert01, color: AppColors.error, size: 16.r),
          SizedBox(width: 8.w),
          Expanded(child: Text(message, style: AppText.small.copyWith(color: AppColors.error))),
        ]),
      );
}

class _SignInLink extends StatelessWidget {
  final VoidCallback onTap;
  const _SignInLink({required this.onTap});

  @override
  Widget build(BuildContext context) => Center(
        child: GestureDetector(
          onTap: onTap,
          child: RichText(
            text: TextSpan(
              style: AppText.small.copyWith(color: AppColors.muted),
              children: [
                TextSpan(text: context.l10n.haveAccount),
                TextSpan(text: context.l10n.signInLink, style: AppText.small.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      );
}
