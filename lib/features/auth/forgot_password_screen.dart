import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/ujob_auth_header.dart';
import '../../core/widgets/ujob_button.dart';
import '../../core/widgets/ujob_text_field.dart';

import '../../core/utils/l10n_extensions.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  bool _sent = false;
  String? _error;

  late final AnimationController _successCtrl;
  late final Animation<double> _successScale;
  late final Animation<double> _successFade;

  @override
  void initState() {
    super.initState();
    _successCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _successScale = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successCtrl,
        curve: const Cubic(0.34, 1.56, 0.64, 1.0),
      ),
    );
    _successFade = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _successCtrl, curve: Curves.easeOut));

    _emailCtrl.addListener(() {
      if (_error != null) setState(() => _error = null);
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _successCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final email = _emailCtrl.text.trim();

    if (email.isEmpty || _error != null) {
      if (email.isEmpty) setState(() => _error = l10n.errorEnterEmail);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    // Mock API call for UI testing
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _loading = false;
        _sent = true;
      });
      _successCtrl.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
            child: _sent
                ? _SuccessView(
                    key: const ValueKey('success'),
                    email: _emailCtrl.text.trim(),
                    onBack: () => context.go('/login'),
                    ctrl: _successCtrl,
                    scale: _successScale,
                    fade: _successFade,
                  )
                : _FormView(
                    key: const ValueKey('form'),
                    emailCtrl: _emailCtrl,
                    error: _error,
                    loading: _loading,
                    onBack: () => context.pop(),
                    onSubmit: _submit,
                  ),
          ),
        ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  final TextEditingController emailCtrl;
  final String? error;
  final bool loading;
  final VoidCallback onBack, onSubmit;

  const _FormView({
    super.key,
    required this.emailCtrl,
    required this.error,
    required this.loading,
    required this.onBack,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.h),
        UJobAuthHeader(icon: HugeIcons.strokeRoundedLockKey, onBack: onBack),
        SizedBox(height: 20.h),
        Text(l10n.resetPasswordTitle, style: AppText.heading2),
        SizedBox(height: 6.h),
        Text(
          l10n.resetPasswordSub,
          style: AppText.body.copyWith(color: AppColors.muted),
        ),
        SizedBox(height: 28.h),
        UJobTextField(
          label: l10n.email,
          hint: l10n.emailHint,
          controller: emailCtrl,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          errorText: error,
          isRequired: true,
          isEmail: true,
        ),
        SizedBox(height: 12.h),
        UJobButton(
          label: l10n.sendResetLink,
          onTap: onSubmit,
          isLoading: loading,
        ),
        SizedBox(height: 24.h),
      ],
    );
  }
}

class _SuccessView extends StatelessWidget {
  final String email;
  final VoidCallback onBack;
  final AnimationController ctrl;
  final Animation<double> scale, fade;

  const _SuccessView({
    super.key,
    required this.email,
    required this.onBack,
    required this.ctrl,
    required this.scale,
    required this.fade,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FadeTransition(
      opacity: fade,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 64.h),
          // Animated success icon
          ScaleTransition(
            scale: scale,
            child: Container(
              width: 88.r,
              height: 88.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.successBg,
                shape: BoxShape.circle,
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedMailOpen01,
                color: AppColors.success,
                size: 44.r,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            l10n.checkInboxTitle,
            style: AppText.heading2,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.resetSentSub,
            style: AppText.body.copyWith(color: AppColors.muted),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            email,
            style: AppText.bodyBold.copyWith(color: AppColors.text),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.spamCheckSub,
            style: AppText.small.copyWith(color: AppColors.muted2),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 36.h),
          UJobButton(label: l10n.backToSignIn, onTap: onBack),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}
