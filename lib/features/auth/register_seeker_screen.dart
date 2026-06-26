import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/ujob_button.dart';
import '../../core/widgets/ujob_terms_agreement.dart';
import '../../core/widgets/ujob_text_field.dart';


import 'package:dio/dio.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/providers/auth_provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../core/utils/l10n_extensions.dart';
import '../../core/utils/api_error_parser.dart';
import '../../core/widgets/ujob_auth_links.dart';
import '../../core/widgets/ujob_role_switch_card.dart';
import '../../core/providers/role_provider.dart';
import '../../core/widgets/ujob_toast.dart';

class RegisterSeekerScreen extends ConsumerStatefulWidget {
  const RegisterSeekerScreen({super.key});

  @override
  ConsumerState<RegisterSeekerScreen> createState() =>
      _RegisterSeekerScreenState();
}

class _RegisterSeekerScreenState extends ConsumerState<RegisterSeekerScreen>
    with SingleTickerProviderStateMixin {
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _acceptedTerms = false;

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
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
    if (!_acceptedTerms) {
      setState(() => _error = l10n.errorAcceptTerms);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    FocusManager.instance.primaryFocus?.unfocus();

    try {
      final dio = ref.read(dioClientProvider).dio;
      final res = await dio.post(
        Ep.registerSeeker,
        data: {
          'first_name': _firstCtrl.text.trim(),
          'last_name': _lastCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'password': _passCtrl.text,
        },
      );

      final rawData = res.data as Map<String, dynamic>;
      if (rawData['success'] == false) {
        if (mounted) {
          setState(() => _loading = false);
        }
        UJobToast.error(context, 'Registration Failed', sub: rawData['error']?['message']?.toString() ?? 'Registration failed.');
        return;
      }

      final data = (rawData['data'] ?? rawData) as Map<String, dynamic>;
      final userId = data['user_id']?.toString() ?? data['id']?.toString() ?? data['user']?['id']?.toString() ?? '';

      UJobToast.success(context, 'Success', sub: 'Registration Successful!');

      if (mounted) {
        setState(() => _loading = false);
        if (data['requires_otp'] == true) {
          context.go('/otp', extra: userId);
        } else {
          final token = data['accessToken']?.toString() ?? '';
          if (token.isNotEmpty) {
            await ref.read(secureStorageProvider).saveTokens(token, '');
            ref.read(activeRoleProvider.notifier).setRole('seeker');
          }
          context.go('/seeker');
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
      final msg = parseApiError(e);
      UJobToast.error(context, 'Error', sub: msg);
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
      UJobToast.error(context, 'Error', sub: 'An unexpected error occurred.');
    }
  }

  void _setTermsAccepted(bool value) {
    setState(() {
      _acceptedTerms = value;
      if (value && _error == context.l10n.errorAcceptTerms) _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => context.canPop()
                      ? context.pop()
                      : context.go('/role-picker'),
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
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.createAccountTitle, style: AppText.heading2),
                    SizedBox(height: 4.h),
                    Text(
                      l10n.createAccountSub,
                      style: AppText.small.copyWith(color: AppColors.muted),
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      children: [
                        Expanded(
                          child: UJobTextField(
                            label: l10n.firstName,
                            hint: l10n.firstNameHint,
                            controller: _firstCtrl,
                            textInputAction: TextInputAction.next,
                            isRequired: true,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: UJobTextField(
                            label: l10n.lastName,
                            hint: l10n.lastNameHint,
                            controller: _lastCtrl,
                            textInputAction: TextInputAction.next,
                            isRequired: true,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    UJobTextField(
                      label: l10n.email,
                      hint: l10n.emailHint,
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      isRequired: true,
                      isEmail: true,
                    ),

                    SizedBox(height: 16.h),
                    UJobTextField(
                      label: l10n.password,
                      hint: l10n.passwordCreateHint,
                      controller: _passCtrl,
                      isPassword: true,
                      textInputAction: TextInputAction.next,
                      isRequired: true,
                      isSecurePassword: true,
                    ),
                    SizedBox(height: 16.h),
                    UJobTextField(
                      label: l10n.confirmPassword,
                      hint: l10n.confirmPasswordHint,
                      controller: _confirmCtrl,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      isRequired: true,
                      isConfirmPassword: true,
                      matchValue: _passCtrl.text,
                    ),
                    SizedBox(height: 12.h),
                    UJobTermsAgreement(
                      value: _acceptedTerms,
                      onChanged: _setTermsAccepted,
                      onTermsTap: () => context.push('/pages/terms'),
                      onPrivacyTap: () => context.push('/pages/privacy-policy'),
                      prefix: l10n.byRegisteringAgree,
                      termsLabel: l10n.terms,
                      privacyLabel: l10n.privacyPolicyWithPeriod,
                    ),
                    if (_error != null) ...[
                      SizedBox(height: 16.h),
                      _ErrorBox(_error!),
                    ],
                    SizedBox(height: 24.h),
                    UJobButton(
                      label: l10n.createAccount,
                      onTap: _register,
                      isLoading: _loading,
                    ),
                    SizedBox(height: 16.h),
                    UJobAuthLinks(
                      primaryText: l10n.alreadyHaveAccount,
                      primaryLinkText: l10n.logIn,
                      onPrimaryTap: () => context.go('/login', extra: 'seeker'),
                    ),
                    SizedBox(height: 24.h),
                    UJobRoleSwitchCard(
                      text: l10n.areYouEmployer,
                      linkText: l10n.registerHere,
                      icon: HugeIcons.strokeRoundedBuilding04,
                      onTap: () => context.go('/register/employer'),
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox(this.message);

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(12.r),
    decoration: BoxDecoration(
      color: AppColors.errorBg,
      borderRadius: BorderRadius.circular(12.r),
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
