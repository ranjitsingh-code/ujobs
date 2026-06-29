import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/role_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ujob_auth_header.dart';
import '../../../core/widgets/ujob_button.dart';
import '../../../core/widgets/ujob_toast.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/utils/l10n_extensions.dart';

class ChangeEmailOtpVerifyScreen extends ConsumerStatefulWidget {
  final String? email;
  const ChangeEmailOtpVerifyScreen({this.email, super.key});

  @override
  ConsumerState<ChangeEmailOtpVerifyScreen> createState() => _ChangeEmailOtpVerifyScreenState();
}

class _ChangeEmailOtpVerifyScreenState extends ConsumerState<ChangeEmailOtpVerifyScreen>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _ctrs = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _foci = List.generate(6, (_) => FocusNode());

  bool _loading = false;
  String? _error;
  int _countdown = 59;
  Timer? _timer;

  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _ctrs) {
      c.dispose();
    }
    for (final f in _foci) {
      f.dispose();
    }
    _shakeCtrl.dispose();
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

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      // Handle paste of full OTP
      final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.length >= 6) {
        for (int i = 0; i < 6; i++) {
          _ctrs[i].text = digits[i];
        }
        _foci[5].requestFocus();
        setState(() {});
        return;
      }
      _ctrs[index].text = value.substring(value.length - 1);
    }
    if (value.isNotEmpty && index < 5) {
      _foci[index + 1].requestFocus();
    } else if (index == 5 && value.isNotEmpty) {
      // Last digit entered, trigger verification but keep keyboard
      _verify();
    }
    setState(() => _error = null);
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_ctrs[index].text.isEmpty && index > 0) {
        _foci[index - 1].requestFocus();
        _ctrs[index - 1].clear();
      }
    }
  }

  String get _otp => _ctrs.map((c) => c.text).join();

  String _maskEmail(String email) {
    if (!email.contains('@')) return email;
    final parts = email.split('@');
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 3) return '***@$domain';
    return '${name.substring(0, 2)}***${name.substring(name.length - 1)}@$domain';
  }

  void _skipToApp() {
    final role = ref.read(activeRoleProvider);
    context.go(role == 'employer' ? '/employer' : '/seeker');
  }

  Future<void> _verify() async {
    if (_loading) return;
    if (_otp.length < 6) {
      final msg = context.l10n.otpErrorComplete;
      setState(() => _error = msg);
      UJobToast.error(context, 'Invalid OTP', sub: msg);
      _shakeCtrl.forward(from: 0);
      return;
    }
    
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final isEmployer = ref.read(activeRoleProvider) == 'employer';
      final res = await ref.read(dioClientProvider).dio.post(
        isEmployer ? Ep.empEmailVerifyOtp : Ep.seekEmailVerifyOtp,
        data: {'code': _otp},
      );

      final msg = res.data?['message']?.toString() ?? 
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
      final msg = e.response?.data?['error']?['message'] ?? 
                  e.response?.data?['message'] ?? 
                  'Invalid or expired OTP';
      UJobToast.error(context, 'Verification Failed', sub: msg);
      setState(() {
        _loading = false;
        _error = msg;
      });
      _shakeCtrl.forward(from: 0);
    } catch (_) {
      if (!mounted) return;
      final msg = context.l10n.error;
      UJobToast.error(context, 'Verification Failed', sub: msg);
      setState(() {
        _loading = false;
        _error = msg;
      });
      _shakeCtrl.forward(from: 0);
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
              AnimatedBuilder(
                animation: _shakeAnim,
                builder: (_, child) => Transform.translate(
                  offset: Offset(_shakeAnim.value, 0),
                  child: child,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    6,
                    (i) => _OtpBox(
                      controller: _ctrs[i],
                      focusNode: _foci[i],
                      autofocus: i == 0,
                      hasValue: _ctrs[i].text.isNotEmpty,
                      hasError: _error != null,
                      onChanged: (v) => _onDigitChanged(i, v),
                      onKeyEvent: (e) => _onKeyEvent(i, e),
                    ),
                  ),
                ),
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
                          UJobToast.info(context, 'Request New Code', sub: 'Please request a new code from the settings page.');
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
                  border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
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
  State<_SuccessCountdownDialog> createState() => _SuccessCountdownDialogState();
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

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasValue, hasError, autofocus;
  final ValueChanged<String> onChanged;
  final ValueChanged<KeyEvent> onKeyEvent;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.hasValue,
    required this.hasError,
    this.autofocus = false,
    required this.onChanged,
    required this.onKeyEvent,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 50.r,
    height: 60.r,
    child: KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: onKeyEvent,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [LengthLimitingTextInputFormatter(1)],
        style: AppText.heading2.copyWith(
          color: AppColors.text,
          fontWeight: FontWeight.w700,
        ),
        onChanged: onChanged,
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: hasError
              ? AppColors.errorBg
              : hasValue
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.bg,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(
              color: hasError ? AppColors.error : AppColors.border,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(
              color: hasError ? AppColors.error : AppColors.primary,
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        ),
      ),
    ),
  );
}
