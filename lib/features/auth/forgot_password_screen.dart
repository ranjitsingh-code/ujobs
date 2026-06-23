import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:dio/dio.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/ujob_auth_header.dart';
import '../../core/widgets/ujob_button.dart';
import '../../core/widgets/ujob_text_field.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

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

  final _codeCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _newPassCtrl.dispose();
    _successCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
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

    FocusManager.instance.primaryFocus?.unfocus();

    try {
      final dio = ref.read(dioClientProvider).dio;
      await dio.post(
        Ep.forgotPasswordRequest,
        data: {'email': email},
      );
      
      if (mounted) {
        setState(() {
          _loading = false;
          _sent = true;
        });
        _successCtrl.forward();
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.response?.data is Map 
              ? (e.response!.data['error']?['message'] ?? 'A network error occurred.') 
              : 'A network error occurred.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'An unexpected error occurred.';
        });
      }
    }
  }

  Future<void> _submitReset() async {
    final email = _emailCtrl.text.trim();
    final code = _codeCtrl.text.trim();
    final newPass = _newPassCtrl.text;

    if (code.isEmpty || newPass.isEmpty) {
      EasyLoading.showError(context.l10n.errorRequiredField);
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    EasyLoading.show(status: 'Resetting Password...');

    try {
      final dio = ref.read(dioClientProvider).dio;
      final res = await dio.post(
        Ep.forgotPasswordReset,
        data: {
          'email': email,
          'code': code,
          'new_password': newPass,
        },
      );

      final rawData = res.data as Map<String, dynamic>;
      if (rawData['success'] == false) {
        EasyLoading.showError(rawData['error']?['message']?.toString() ?? 'Failed to reset password.');
        return;
      }

      EasyLoading.showSuccess('Password reset successfully!');
      if (mounted) {
        context.go('/login');
      }
    } on DioException catch (e) {
      final msg = e.response?.data is Map 
          ? (e.response!.data['error']?['message'] ?? 'A network error occurred.') 
          : 'A network error occurred.';
      EasyLoading.showError(msg);
    } catch (e) {
      EasyLoading.showError('An unexpected error occurred.');
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
                ? _ResetView(
                    key: const ValueKey('reset'),
                    email: _emailCtrl.text.trim(),
                    codeCtrl: _codeCtrl,
                    newPassCtrl: _newPassCtrl,
                    onBack: () => setState(() => _sent = false),
                    onSubmit: _submitReset,
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
                    onSubmit: _submitRequest,
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

class _ResetView extends StatelessWidget {
  final String email;
  final TextEditingController codeCtrl, newPassCtrl;
  final VoidCallback onBack, onSubmit;
  final AnimationController ctrl;
  final Animation<double> scale, fade;

  const _ResetView({
    super.key,
    required this.email,
    required this.codeCtrl,
    required this.newPassCtrl,
    required this.onBack,
    required this.onSubmit,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          UJobAuthHeader(icon: HugeIcons.strokeRoundedMailOpen01, onBack: onBack),
          SizedBox(height: 20.h),
          Text('Enter Reset Code', style: AppText.heading2),
          SizedBox(height: 6.h),
          Text(
            'We sent a 6-digit code to $email',
            style: AppText.body.copyWith(color: AppColors.muted),
          ),
          SizedBox(height: 28.h),
          UJobTextField(
            label: 'Reset Code',
            hint: 'Enter 6-digit code',
            controller: codeCtrl,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            isRequired: true,
          ),
          SizedBox(height: 16.h),
          UJobTextField(
            label: 'New Password',
            hint: 'Enter new password',
            controller: newPassCtrl,
            isPassword: true,
            textInputAction: TextInputAction.done,
            isRequired: true,
          ),
          SizedBox(height: 24.h),
          UJobButton(label: 'Reset Password', onTap: onSubmit),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}
