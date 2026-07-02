// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/role_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/ujob_auth_header.dart';
import '../../core/widgets/ujob_button.dart';
import '../../core/widgets/ujob_otp_field.dart';
import '../../core/widgets/ujob_toast.dart';
import '../../core/utils/l10n_extensions.dart';

class TwoFactorAuthScreen extends ConsumerStatefulWidget {
  final String userId;
  final String? email;

  const TwoFactorAuthScreen({
    required this.userId,
    this.email,
    super.key,
  });

  @override
  ConsumerState<TwoFactorAuthScreen> createState() =>
      _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends ConsumerState<TwoFactorAuthScreen> {
  String _otp = '';
  bool _loading = false;
  String? _error;
  int _countdown = 59;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _countdown = 59;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_countdown == 0) {
        t.cancel();
        return;
      }
      setState(() => _countdown--);
    });
  }

  String _maskEmail(String email) {
    if (!email.contains('@')) return email;
    final parts = email.split('@');
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 3) return '***@$domain';
    return '${name.substring(0, 2)}***${name.substring(name.length - 1)}@$domain';
  }

  Future<void> _verify() async {
    if (_otp.length < 6) {
      final msg = context.l10n.otpErrorComplete;
      setState(() => _error = msg);
      UJobToast.error(context, context.l10n.twoFactorVerifyTitle, sub: msg);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final (result, errorMsg) = await ref
        .read(authProvider.notifier)
        .verifyOtp(widget.userId, _otp);

    if (!mounted) return;

    if (result == LoginResult.success) {
      UJobToast.success(
        context,
        context.l10n.twoFAEnabledSuccess,
        sub: context.l10n.welcomeBack,
      );
      final role = ref.read(activeRoleProvider);
      context.go(role == 'employer' ? '/employer' : '/seeker');
    } else if (result == LoginResult.locked) {
      setState(() => _loading = false);
      UJobToast.error(
        context,
        context.l10n.accountLockedTitle,
        sub: errorMsg ?? context.l10n.accountLockedDesc,
      );
      if (mounted) context.go('/locked', extra: errorMsg);
    } else if (result == LoginResult.suspended) {
      if (mounted) context.go('/suspended');
    } else {
      final finalError = errorMsg ?? context.l10n.otpErrorInvalid;
      UJobToast.error(
        context,
        context.l10n.twoFactorVerifyTitle,
        sub: finalError,
      );
      setState(() {
        _loading = false;
        _error = finalError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),
              UJobAuthHeader(
                icon: HugeIcons.strokeRoundedShieldUser,
                onBack: () =>
                    context.canPop() ? context.pop() : context.go('/login'),
              ),
              SizedBox(height: 20.h),

              Text(l10n.twoFactorVerifyTitle, style: AppText.heading2),
              SizedBox(height: 6.h),
              Text(
                l10n.twoFactorVerifyDesc,
                style: AppText.body.copyWith(color: AppColors.muted),
              ),
              if (widget.email != null) ...[
                SizedBox(height: 2.h),
                Text(
                  _maskEmail(widget.email!),
                  style: AppText.bodyMd.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              SizedBox(height: 32.h),

              UJobOtpField(
                hasError: _error != null,
                semanticLabel: l10n.twoFactorVerifyTitle,
                onChanged: (value) => setState(() {
                  _otp = value;
                  _error = null;
                }),
                onCompleted: (_) => _verify(),
              ),

              if (_error != null) ...[
                SizedBox(height: 10.h),
                Text(
                  _error!,
                  style: AppText.small.copyWith(color: AppColors.error),
                ),
              ],
              SizedBox(height: 20.h),

              Center(
                child: _countdown > 0
                    ? RichText(
                        text: TextSpan(
                          style: AppText.small.copyWith(color: AppColors.muted),
                          children: [
                            TextSpan(text: l10n.resendCodeIn),
                            TextSpan(
                              text: '${_countdown}s',
                              style: AppText.small.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GestureDetector(
                        onTap: () async {
                          setState(() => _loading = true);
                          final resendError = await ref
                              .read(authProvider.notifier)
                              .resendOtp(widget.userId);
                          if (!mounted) return;
                          setState(() => _loading = false);
                          if (resendError == null) {
                            UJobToast.success(
                              context,
                              l10n.resendCodeLink,
                              sub: 'Verification code resent.',
                            );
                            _startTimer();
                            setState(() => _error = null);
                          } else {
                            UJobToast.error(
                              context,
                              l10n.twoFactorVerifyTitle,
                              sub: resendError,
                            );
                          }
                        },
                        child: Text(
                          l10n.resendCodeLink,
                          style: AppText.small.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
              ),
              SizedBox(height: 24.h),

              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.08),
                  borderRadius: AppRadius.md,
                  border: Border.all(
                    color: AppColors.info.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedInformationCircle,
                      color: AppColors.info,
                      size: 20.r,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        l10n.checkSpamHint,
                        style: AppText.small.copyWith(
                          color: AppColors.text2,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              UJobButton(
                label: l10n.verifyEmail,
                onTap: _verify,
                isLoading: _loading,
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
