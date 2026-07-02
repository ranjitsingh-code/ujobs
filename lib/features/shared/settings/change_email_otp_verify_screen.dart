import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/role_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ujob_auth_header.dart';
import '../../../core/widgets/ujob_button.dart';
import '../../../core/widgets/ujob_otp_field.dart';
import '../../../core/widgets/ujob_toast.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/utils/l10n_extensions.dart';

class ChangeEmailOtpVerifyScreen extends ConsumerStatefulWidget {
  final String? email;
  const ChangeEmailOtpVerifyScreen({this.email, super.key});

  @override
  ConsumerState<ChangeEmailOtpVerifyScreen> createState() =>
      _ChangeEmailOtpVerifyScreenState();
}

class _ChangeEmailOtpVerifyScreenState
    extends ConsumerState<ChangeEmailOtpVerifyScreen> {
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
    if (_loading) return;
    if (_otp.length < 6) {
      final msg = context.l10n.otpErrorComplete;
      setState(() => _error = msg);
      UJobToast.error(context, 'Invalid OTP', sub: msg);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final isEmployer = ref.read(activeRoleProvider) == 'employer';
      final res = await ref
          .read(dioClientProvider)
          .dio
          .post(
            isEmployer ? Ep.empEmailVerifyOtp : Ep.seekEmailVerifyOtp,
            data: {'code': _otp},
          );

      final msg =
          res.data?['message']?.toString() ??
          'Your email has been changed successfully. Please log in with your new email.';

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => PopScope(
          canPop: false,
          child: _SuccessCountdownDialog(message: msg),
        ),
      );

      if (!mounted) return;
      ref.read(authProvider.notifier).logout();
    } on DioException catch (e) {
      if (!mounted) return;
      final msg =
          e.response?.data?['error']?['message'] ??
          e.response?.data?['message'] ??
          'Invalid or expired OTP';
      UJobToast.error(context, 'Verification Failed', sub: msg);
      setState(() {
        _loading = false;
        _error = msg;
      });
    } catch (_) {
      if (!mounted) return;
      final msg = context.l10n.error;
      UJobToast.error(context, 'Verification Failed', sub: msg);
      setState(() {
        _loading = false;
        _error = msg;
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
                icon: HugeIcons.strokeRoundedMail01,
                onBack: () => context.pop(),
              ),
              SizedBox(height: 20.h),

              Text(l10n.checkEmailTitle, style: AppText.heading2),
              SizedBox(height: 6.h),
              Text(
                l10n.otpSubtitle,
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

              // OTP boxes
              UJobOtpField(
                hasError: _error != null,
                semanticLabel: l10n.otpVerification,
                onChanged: (value) => setState(() {
                  _otp = value;
                  _error = null;
                }),
                onCompleted: (_) => _verify(),
              ),

              // Error
              if (_error != null) ...[
                SizedBox(height: 10.h),
                Text(
                  _error!,
                  style: AppText.small.copyWith(color: AppColors.error),
                ),
              ],
              SizedBox(height: 20.h),

              // Resend countdown
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
                        onTap: () {
                          UJobToast.info(
                            context,
                            'Request New Code',
                            sub:
                                'Please request a new code from the settings page.',
                          );
                          context.pop();
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

class _SuccessCountdownDialog extends StatefulWidget {
  final String message;
  const _SuccessCountdownDialog({required this.message});

  @override
  State<_SuccessCountdownDialog> createState() =>
      _SuccessCountdownDialogState();
}

class _SuccessCountdownDialogState extends State<_SuccessCountdownDialog> {
  int _seconds = 3;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _seconds--;
      });
      if (_seconds <= 0) {
        timer.cancel();
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      backgroundColor: AppColors.surface,
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedCheckmarkBadge01,
              color: AppColors.primary,
              size: 48.r,
            ),
            SizedBox(height: 16.h),
            Text(
              'Email Changed',
              style: AppText.heading3,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              widget.message,
              style: AppText.bodyMedium.copyWith(color: AppColors.text2),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            Text(
              'Redirecting to login in $_seconds...',
              style: AppText.small.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
