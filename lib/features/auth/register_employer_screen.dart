import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/ujob_button.dart';
import '../../core/widgets/ujob_dropdown_field.dart';
import '../../core/widgets/ujob_terms_agreement.dart';
import '../../core/widgets/ujob_text_field.dart';

import '../../core/utils/l10n_extensions.dart';
import '../../core/widgets/ujob_auth_links.dart';
import '../../core/widgets/ujob_role_switch_card.dart';

class RegisterEmployerScreen extends ConsumerStatefulWidget {
  const RegisterEmployerScreen({super.key});

  @override
  ConsumerState<RegisterEmployerScreen> createState() =>
      _RegisterEmployerScreenState();
}

class _RegisterEmployerScreenState extends ConsumerState<RegisterEmployerScreen>
    with SingleTickerProviderStateMixin {
  int _step = 1;

  // Step 1
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _acceptedTerms = false;

  // Step 2
  final _companyCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  String? _country;

  bool _loading = false;
  String? _error;

  late final AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animCtrl.forward();

    // Rebuild when password changes to update matchValue in confirm field
    _passCtrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    for (final c in [
      _firstCtrl,
      _lastCtrl,
      _emailCtrl,
      _passCtrl,
      _confirmCtrl,
      _companyCtrl,
      _cityCtrl,
      _websiteCtrl,
    ]) {
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
      setState(() => _error = l10n.errorValidWorkEmail);
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
    if (!_acceptedTerms) {
      setState(() => _error = l10n.errorAcceptTerms);
      return;
    }
    setState(() {
      _step = 2;
      _error = null;
    });
    _animCtrl.forward(from: 0);
  }

  void _setTermsAccepted(bool value) {
    setState(() {
      _acceptedTerms = value;
      if (value && _error == context.l10n.errorAcceptTerms) _error = null;
    });
  }

  Future<void> _register() async {
    if (_companyCtrl.text.trim().isEmpty) {
      setState(() => _error = context.l10n.errorCompanyName);
      return;
    }
    if (_cityCtrl.text.trim().isEmpty || _country == null) {
      setState(() => _error = context.l10n.errorCityCountry);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    // Simulate API success
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      setState(() => _loading = false);
      context.go('/otp');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              step: _step,
              total: 2,
              onBack: _step == 1
                  ? () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/role-picker');
                      }
                    }
                  : () => setState(() {
                      _step = 1;
                      _error = null;
                    }),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                layoutBuilder: (currentChild, previousChildren) => Stack(
                  alignment: Alignment.topCenter,
                  children: [...previousChildren, ?currentChild],
                ),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(0.04, 0),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: _step == 1
                    ? _EmpStep1(
                        key: const ValueKey(1),
                        firstCtrl: _firstCtrl,
                        lastCtrl: _lastCtrl,
                        emailCtrl: _emailCtrl,
                        passCtrl: _passCtrl,
                        confirmCtrl: _confirmCtrl,
                        acceptedTerms: _acceptedTerms,
                        onTermsChanged: _setTermsAccepted,
                        error: _error,
                        onContinue: _goStep2,
                        onSignIn: () =>
                            context.go('/login', extra: 'employer'),
                        onOtherRole: () => context.go('/register/seeker'),
                      )
                    : _EmpStep2(
                        key: const ValueKey(2),
                        companyCtrl: _companyCtrl,
                        cityCtrl: _cityCtrl,
                        country: _country,
                        onCountryChanged: (value) =>
                            setState(() => _country = value),
                        websiteCtrl: _websiteCtrl,
                        error: _error,
                        loading: _loading,
                        onRegister: _register,
                        onSignIn: () =>
                            context.go('/login', extra: 'employer'),
                        onOtherRole: () => context.go('/register/seeker'),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmpStep1 extends StatelessWidget {
  final TextEditingController firstCtrl,
      lastCtrl,
      emailCtrl,
      passCtrl,
      confirmCtrl;
  final bool acceptedTerms;
  final ValueChanged<bool> onTermsChanged;
  final String? error;
  final VoidCallback onContinue, onSignIn, onOtherRole;

  const _EmpStep1({
    super.key,
    required this.firstCtrl,
    required this.lastCtrl,
    required this.emailCtrl,
    required this.passCtrl,
    required this.confirmCtrl,
    required this.acceptedTerms,
    required this.onTermsChanged,
    required this.error,
    required this.onContinue,
    required this.onSignIn,
    required this.onOtherRole,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.employerAccountTitle, style: AppText.heading2),
          SizedBox(height: 4.h),
          Text(
            l10n.employerAccountSub,
            style: AppText.small.copyWith(color: AppColors.muted),
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: UJobTextField(
                  label: l10n.firstName,
                  hint: l10n.firstNameHint,
                  controller: firstCtrl,
                  textInputAction: TextInputAction.next,
                  isRequired: true,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: UJobTextField(
                  label: l10n.lastName,
                  hint: l10n.lastNameHint,
                  controller: lastCtrl,
                  textInputAction: TextInputAction.next,
                  isRequired: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          UJobTextField(
            label: l10n.workEmailLabel,
            hint: l10n.workEmailHint,
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            isRequired: true,
            isEmail: true,
          ),
          // Phone field intentionally omitted until website registration requires it.
          SizedBox(height: 16.h),
          UJobTextField(
            label: l10n.password,
            hint: l10n.passwordCreateHint,
            controller: passCtrl,
            isPassword: true,
            textInputAction: TextInputAction.next,
            isRequired: true,
            isSecurePassword: true,
          ),
          SizedBox(height: 16.h),
          UJobTextField(
            label: l10n.confirmPassword,
            hint: l10n.confirmPasswordHint,
            controller: confirmCtrl,
            isPassword: true,
            textInputAction: TextInputAction.done,
            isRequired: true,
            isConfirmPassword: true,
            matchValue: passCtrl.text,
          ),
          SizedBox(height: 12.h),
          UJobTermsAgreement(
            value: acceptedTerms,
            onChanged: onTermsChanged,
            onTermsTap: () => context.push('/terms-and-conditions'),
            onPrivacyTap: () => context.push('/privacy-policy'),
          ),
          if (error != null) ...[SizedBox(height: 16.h), _ErrorBox(error!)],
          SizedBox(height: 24.h),
          UJobButton(label: l10n.continueButton, onTap: onContinue),
          SizedBox(height: 16.h),
          UJobAuthLinks(
            primaryText: l10n.alreadyHaveAccount,
            primaryLinkText: l10n.logIn,
            onPrimaryTap: onSignIn,
          ),
          SizedBox(height: 24.h),
          UJobRoleSwitchCard(
            text: l10n.lookingForJob,
            linkText: l10n.registerAsJobSeeker,
            icon: HugeIcons.strokeRoundedJobSearch,
            onTap: onOtherRole,
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}

class _EmpStep2 extends StatelessWidget {
  final TextEditingController companyCtrl, cityCtrl, websiteCtrl;
  final String? country;
  final ValueChanged<String?> onCountryChanged;
  final String? error;
  final bool loading;
  final VoidCallback onRegister, onSignIn, onOtherRole;

  const _EmpStep2({
    super.key,
    required this.companyCtrl,
    required this.cityCtrl,
    required this.country,
    required this.onCountryChanged,
    required this.websiteCtrl,
    required this.error,
    required this.loading,
    required this.onRegister,
    required this.onSignIn,
    required this.onOtherRole,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.companyDetailsTitle, style: AppText.heading2),
          SizedBox(height: 4.h),
          Text(
            l10n.companyDetailsSub,
            style: AppText.small.copyWith(color: AppColors.muted),
          ),
          SizedBox(height: 24.h),
          UJobTextField(
            label: l10n.companyNameLabel,
            hint: l10n.companyNameHint,
            controller: companyCtrl,
            textInputAction: TextInputAction.next,
            isRequired: true,
          ),
          SizedBox(height: 16.h),
          UJobTextField(
            label: l10n.city,
            hint: l10n.cityHint,
            controller: cityCtrl,
            textInputAction: TextInputAction.next,
            isRequired: true,
          ),
          SizedBox(height: 16.h),
          UJobCountryDropdown(value: country, onChanged: onCountryChanged),
          UJobTextField(
            label: l10n.websiteLabel,
            hint: l10n.websiteHint,
            controller: websiteCtrl,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
          ),
          if (error != null) ...[SizedBox(height: 16.h), _ErrorBox(error!)],
          SizedBox(height: 24.h),
          UJobButton(
            label: l10n.createEmployerAccount,
            onTap: onRegister,
            isLoading: loading,
          ),
          SizedBox(height: 16.h),
          UJobAuthLinks(
            primaryText: l10n.alreadyHaveAccount,
            primaryLinkText: l10n.logIn,
            onPrimaryTap: onSignIn,
          ),
          SizedBox(height: 24.h),
          UJobRoleSwitchCard(
            text: l10n.lookingForJob,
            linkText: l10n.registerAsJobSeeker,
            icon: HugeIcons.strokeRoundedJobSearch,
            onTap: onOtherRole,
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final int step, total;
  final VoidCallback onBack;
  const _TopBar({
    required this.step,
    required this.total,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 4.h),
    child: Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              size: 20.r,
              color: AppColors.text,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Container(
            height: 5.h,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: AppRadius.pill,
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: step / total,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.authGradient,
                  borderRadius: AppRadius.pill,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          '$step/$total',
          style: AppText.small.copyWith(
            color: AppColors.muted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox(this.message);

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(12.r),
    decoration: BoxDecoration(
      color: AppColors.errorBg,
      borderRadius: AppRadius.md,
    ),
    child: Row(
      children: [
        HugeIcon(
          icon: HugeIcons.strokeRoundedAlert01,
          color: AppColors.error,
          size: 16.r,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            message,
            style: AppText.small.copyWith(color: AppColors.error),
          ),
        ),
      ],
    ),
  );
}
