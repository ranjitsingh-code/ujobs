import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/role_provider.dart';
import '../../../core/providers/cms_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/ujob_validator.dart';
import '../../../core/widgets/ujob_app_bar.dart';
import '../../../core/widgets/ujob_alert_dialog.dart';
import '../../../core/utils/l10n_extensions.dart';
import '../../../core/widgets/ujob_button.dart';
import '../../../core/widgets/ujob_phone_number_field.dart';
import '../../../core/widgets/ujob_radio_card.dart';
import '../../../core/widgets/ujob_text_field.dart';
import '../../../core/widgets/ujob_toast.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Shared States
  bool _twoFa = false;
  bool _allowNotifications = true;
  String _visibilityMode = 'public';

  // Notifications - Employer email
  bool _emailNewJobApplication = true;
  bool _emailCandidateMessage = true;
  bool _emailInterviewResponse = true;
  bool _emailMarketing = false;

  // Notifications - Seeker email
  bool _emailJobRecommendations = true;
  bool _emailApplicationUpdates = true;
  bool _emailMessages = true;

  // Privacy & Preferences
  bool _profileVisible = true;
  bool _showSalaryExpectations = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final role = ref.watch(activeRoleProvider);
    final isEmployer = role == 'employer';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isEmployer
          ? null
          : UJobAppBar(
              title: l10n.settings,
              showBack: true,
              backgroundColor: AppColors.background,
            ),
      body: SafeArea(
        top: isEmployer,
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 120.h),
          children: [
            // ================= SECURITY =================
            _SectionTitle('SECURITY'),
            _SectionContainer(
              children: [
                _NavTile(
                  label: l10n.changePassword,
                  subtitle: isEmployer
                      ? l10n.employerChangePasswordSubtitle
                      : l10n.seekerChangePasswordSubtitle,
                  onTap: () => _showChangePasswordSheet(context),
                ),
                _NavTile(
                  label: isEmployer
                      ? l10n.changeEmail
                      : l10n.changeEmailAddress,
                  subtitle: l10n.changeEmailSubtitle,
                  onTap: () => _showChangeFieldSheet(
                    context: context,
                    title: isEmployer
                        ? l10n.changeEmail
                        : l10n.changeEmailAddress,
                    fieldLabel: l10n.newEmailAddress,
                    buttonLabel: l10n.sendVerificationCode,
                    type: TextInputType.emailAddress,
                  ),
                ),
                _NavTile(
                  label: l10n.changePhone,
                  subtitle: l10n.changePhoneSubtitle,
                  onTap: () => _showChangeFieldSheet(
                    context: context,
                    title: l10n.changePhone,
                    fieldLabel: l10n.phone,
                    buttonLabel: l10n.save,
                    type: TextInputType.phone,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.twoFactorAuth,
                        style: AppText.bodyBold.copyWith(color: AppColors.text),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        l10n.twoFactorAuthSubtitle,
                        style: AppText.small.copyWith(color: AppColors.muted),
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: AppRadius.sm,
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _twoFa
                                        ? l10n.statusEnabled
                                        : l10n.statusDisabled,
                                    style: AppText.bodyBold.copyWith(
                                      color: _twoFa
                                          ? AppColors.success
                                          : AppColors.muted,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    l10n.authenticatorAppLabel,
                                    style: AppText.small.copyWith(
                                      color: AppColors.text,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _twoFa,
                              onChanged: (v) => _onToggle2FA(v),
                              activeTrackColor: AppColors.primary,
                              inactiveTrackColor: AppColors.borderLight,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // ================= NOTIFICATIONS =================
            _SectionTitle('NOTIFICATIONS'),
            _SectionContainer(
              children: [
                _NavTile(
                  label: l10n.emailNotifications,
                  subtitle: l10n.emailNotificationsSubtitle,
                  showArrow: false,
                  showBorder: true,
                  onTap: () {},
                ),
                if (isEmployer) ...[
                  _ToggleTile(
                    label: l10n.newJobApplication,
                    subtitle: l10n.newJobApplicationSubtitle,
                    value: _emailNewJobApplication,
                    onChanged: (v) =>
                        setState(() => _emailNewJobApplication = v),
                  ),
                  _ToggleTile(
                    label: l10n.candidateMessages,
                    subtitle: l10n.candidateMessagesSubtitle,
                    value: _emailCandidateMessage,
                    onChanged: (v) =>
                        setState(() => _emailCandidateMessage = v),
                  ),
                  _ToggleTile(
                    label: l10n.interviewResponses,
                    subtitle: l10n.interviewResponsesSubtitle,
                    value: _emailInterviewResponse,
                    onChanged: (v) =>
                        setState(() => _emailInterviewResponse = v),
                  ),
                  _ToggleTile(
                    label: l10n.marketingEmails,
                    subtitle: l10n.marketingEmailsSubtitle,
                    value: _emailMarketing,
                    onChanged: (v) => setState(() => _emailMarketing = v),
                  ),
                ] else ...[
                  _ToggleTile(
                    label: l10n.jobRecommendations,
                    value: _emailJobRecommendations,
                    onChanged: (v) =>
                        setState(() => _emailJobRecommendations = v),
                  ),
                  _ToggleTile(
                    label: l10n.applicationUpdates,
                    value: _emailApplicationUpdates,
                    onChanged: (v) =>
                        setState(() => _emailApplicationUpdates = v),
                  ),
                  _ToggleTile(
                    label: l10n.messages,
                    value: _emailMessages,
                    onChanged: (v) => setState(() => _emailMessages = v),
                  ),
                ],
                _ToggleTile(
                  label: l10n.allowNotifications,
                  subtitle: l10n.allowNotificationsSubtitle,
                  value: _allowNotifications,
                  onChanged: (v) => setState(() => _allowNotifications = v),
                  showBorder: false,
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // ================= PRIVACY =================
            _SectionTitle(l10n.privacySection),
            if (isEmployer) ...[
              _SectionContainer(
                children: [
                  _NavTile(
                    label: l10n.companyProfileVisibility,
                    subtitle: 'Control who can see your company profile',
                    showArrow: false,
                    showBorder: false,
                    onTap: () {},
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0),
                child: UJobRadioCard(
                  title: l10n.publicProfile,
                  subtitle: l10n.publicProfileSubtitle,
                  value: 'public',
                  groupValue: _visibilityMode,
                  onChanged: (v) => setState(() => _visibilityMode = v),
                ),
              ),
            ] else ...[
              _SectionContainer(
                children: [
                  _ToggleTile(
                    label: l10n.profileVisibility,
                    subtitle: l10n.profileVisibilitySubtitle,
                    value: _profileVisible,
                    onChanged: (v) => setState(() => _profileVisible = v),
                    showBorder: true,
                  ),
                  _ToggleTile(
                    label: l10n.showSalaryExpectations,
                    subtitle: l10n.showSalaryExpectationsSubtitle,
                    value: _showSalaryExpectations,
                    onChanged: (v) =>
                        setState(() => _showSalaryExpectations = v),
                    showBorder: false,
                  ),
                ],
              ),
            ],

            SizedBox(height: 24.h),

            if (isEmployer) ...[
              // ================= ACCOUNT DATA =================
              _SectionTitle('ACCOUNT DATA'),
              _SectionContainer(
                children: [
                  _NavTile(
                    label: l10n.downloadAccountData,
                    subtitle: l10n.downloadAccountDataSubtitle,
                    showArrow: false,
                    showBorder: false,
                    onTap: () {},
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              _SectionContainer(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
                    child: Text(
                      l10n.exportDataDesc,
                      style: AppText.small.copyWith(color: AppColors.muted),
                    ),
                  ),
                  _NavTile(
                    label: l10n.exportJobsCsv,
                    onTap: () {},
                  ),
                  _NavTile(
                    label: l10n.exportApplicantsCsv,
                    onTap: () {},
                    showBorder: false,
                  ),
                ],
              ),
              SizedBox(height: 24.h),
            ],

            // ================= ABOUT & SUPPORT =================
            _SectionTitle('ABOUT & SUPPORT'),
            _SectionContainer(
              children: [
                ref.watch(cmsPagesListProvider).when(
                  data: (pages) {
                    return Column(
                      children: pages.asMap().entries.map((entry) {
                        final isLast = entry.key == pages.length - 1;
                        return _NavTile(
                          label: entry.value.title,
                          onTap: () => context.push('/pages/${entry.value.slug}'),
                          showBorder: !isLast,
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, _) => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Failed to load pages.'),
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // ================= ACCOUNT =================
            _SectionTitle(isEmployer ? 'DELETE ACCOUNT' : 'ACCOUNT'),
            _SectionContainer(
              children: [
                _NavTile(
                  label: l10n.deleteAccount,
                  subtitle: l10n.deleteAccountSubtitle,
                  textColor: AppColors.error,
                  showArrow: false,
                  onTap: () => _showDeleteDialog(context),
                  showBorder: !isEmployer,
                ),
                if (!isEmployer)
                  _NavTile(
                    label: l10n.signOut,
                    subtitle: 'Sign out of your account on this device',
                    textColor: AppColors.error,
                    showArrow: false,
                    showBorder: false,
                    onTap: () => _showSignOutDialog(context),
                  ),
              ],
            ),

            if (isEmployer) ...[
              SizedBox(height: 24.h),
              _SectionContainer(
                children: [
                  _NavTile(
                    label: l10n.signOut,
                    subtitle: 'Log out of this session',
                    textColor: AppColors.error,
                    showArrow: false,
                    showBorder: false,
                    onTap: () => _showSignOutDialog(context),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- Helpers ---

  Future<void> _showChangePasswordSheet(BuildContext context) async {
    final l10n = context.l10n;
    final isEmployer = ref.read(activeRoleProvider) == 'employer';
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    String? currentError;
    String? newError;
    String? confirmError;
    String? submitError;
    var loading = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            Future<void> submit() async {
              final current = currentCtrl.text.trim();
              final next = newCtrl.text.trim();
              final confirm = confirmCtrl.text.trim();
              final nextError = UJobValidator.validate(
                context: sheetContext,
                value: next,
                isPassword: true,
              );

              setSheetState(() {
                currentError = current.isEmpty ? l10n.errorRequiredField : null;
                newError = nextError;
                confirmError = confirm.isEmpty
                    ? l10n.errorRequiredField
                    : confirm != next
                    ? l10n.errorPasswordMismatch
                    : null;
                submitError = null;
              });

              if (currentError != null ||
                  newError != null ||
                  confirmError != null) {
                return;
              }

              setSheetState(() => loading = true);

              try {
                await ref
                    .read(dioClientProvider)
                    .dio
                    .patch(
                      isEmployer ? Ep.empPassword : Ep.seekPassword,
                      data: {
                        'current_password': current,
                        'new_password': next,
                        'password_confirmation': confirm,
                      },
                    );

                if (!sheetContext.mounted) return;
                Navigator.pop(sheetContext);
                if (mounted) {
                  UJobToast.success(context, l10n.passwordUpdatedSuccess);
                }
              } catch (_) {
                if (!sheetContext.mounted) return;
                setSheetState(() {
                  loading = false;
                  submitError = l10n.error;
                });
              }
            }

            return _SettingsSheet(
              title: l10n.changePassword,
              subtitle: isEmployer
                  ? l10n.employerChangePasswordSubtitle
                  : l10n.seekerChangePasswordSubtitle,
              children: [
                UJobTextField(
                  label: l10n.currentPassword,
                  hint: isEmployer ? null : l10n.currentPasswordHint,
                  controller: currentCtrl,
                  errorText: currentError,
                  isPassword: true,
                  textInputAction: TextInputAction.next,
                  isRequired: true,
                ),
                SizedBox(height: 16.h),
                UJobTextField(
                  label: l10n.newPassword,
                  hint: isEmployer ? null : l10n.newPasswordHint,
                  controller: newCtrl,
                  errorText: newError,
                  isPassword: true,
                  textInputAction: TextInputAction.next,
                  isRequired: true,
                  isSecurePassword: true,
                ),
                SizedBox(height: 16.h),
                UJobTextField(
                  label: l10n.confirmNewPassword,
                  hint: isEmployer ? null : l10n.confirmNewPasswordHint,
                  controller: confirmCtrl,
                  errorText: confirmError,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  isRequired: true,
                  isConfirmPassword: true,
                  matchValue: newCtrl.text,
                ),
                if (submitError != null) ...[
                  SizedBox(height: 12.h),
                  _SettingsErrorBanner(submitError!),
                ],
                SizedBox(height: 24.h),
                UJobButton(
                  label: isEmployer ? l10n.updatePassword : l10n.changePassword,
                  onTap: submit,
                  isLoading: loading,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showChangeFieldSheet({
    required BuildContext context,
    required String title,
    required String fieldLabel,
    required String buttonLabel,
    required TextInputType type,
  }) async {
    final l10n = context.l10n;
    final controller = TextEditingController();
    final passwordCtrl = TextEditingController();
    final isEmail = type == TextInputType.emailAddress;
    final isPhone = type == TextInputType.phone;
    final isEmployer = ref.read(activeRoleProvider) == 'employer';
    final currentUser = ref.read(authProvider).valueOrNull;
    final currentEmail =
        currentUser?.email ??
        (isEmployer
            ? 'nexoviasolutions@gmail.com'
            : 'mdazadhossain95@gmail.com');
    final fieldKey = isEmail ? 'email' : 'phone';
    final successMessage = isEmail
        ? l10n.verificationCodeSent
        : l10n.phoneUpdatedSuccess;

    String? fieldError;
    String? countryCode = '+44';
    String? passwordError;
    String? submitError;
    var loading = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            Future<void> submit() async {
              final value = controller.text.trim();
              final phoneValue = isPhone ? '$countryCode$value' : value;
              final error = UJobValidator.validate(
                context: sheetContext,
                value: isPhone ? value : phoneValue,
                isEmail: isEmail,
                isPhone: isPhone,
              );

              setSheetState(() {
                fieldError = error;
                passwordError = isEmail && passwordCtrl.text.trim().isEmpty
                    ? l10n.errorRequiredField
                    : null;
                submitError = null;
              });

              if (fieldError != null || passwordError != null) {
                return;
              }

              setSheetState(() => loading = true);

              try {
                await ref
                    .read(dioClientProvider)
                    .dio
                    .patch(
                      isEmployer ? Ep.empSettings : Ep.seekSettings,
                      data: {
                        fieldKey: phoneValue,
                        if (isEmail) 'current_password': passwordCtrl.text,
                      },
                    );

                if (!sheetContext.mounted) return;
                Navigator.pop(sheetContext);
                if (mounted) {
                  if (isEmail) {
                    context.push('/otp', extra: {'email': value});
                  } else {
                    UJobToast.success(context, successMessage);
                  }
                }
              } catch (_) {
                if (!sheetContext.mounted) return;
                setSheetState(() {
                  loading = false;
                  submitError = l10n.error;
                });
              }
            }

            return _SettingsSheet(
              title: title,
              children: [
                if (isEmail) ...[
                  Text(
                    l10n.currentValue(currentEmail),
                    style: AppText.body.copyWith(color: AppColors.muted),
                  ),
                  SizedBox(height: 20.h),
                ],
                if (isPhone) ...[
                  UJobPhoneNumberField(
                    label: fieldLabel,
                    controller: controller,
                    initialDialCode: countryCode ?? '+44',
                    onCountryCodeChanged: (value) {
                      setSheetState(() => countryCode = value);
                    },
                    errorText: fieldError,
                    hint: l10n.localPhoneNumberHint,
                  ),
                ] else ...[
                  UJobTextField(
                    label: fieldLabel,
                    hint: isEmail && !isEmployer ? currentEmail : null,
                    controller: controller,
                    keyboardType: type,
                    textInputAction: TextInputAction.done,
                    errorText: fieldError,
                    isRequired: true,
                    isEmail: isEmail,
                  ),
                ],
                if (isEmail) ...[
                  SizedBox(height: 16.h),
                  UJobTextField(
                    label: isEmployer
                        ? l10n.currentPasswordVerification
                        : l10n.currentPassword,
                    hint: isEmployer ? null : l10n.passwordMaskHint,
                    controller: passwordCtrl,
                    textInputAction: TextInputAction.done,
                    errorText: passwordError,
                    isRequired: true,
                    isPassword: true,
                  ),
                  if (!isEmployer) ...[
                    SizedBox(height: 6.h),
                    Text(
                      l10n.requiredToVerifyYou,
                      style: AppText.small.copyWith(color: AppColors.muted),
                    ),
                  ],
                ],
                if (submitError != null) ...[
                  SizedBox(height: 12.h),
                  _SettingsErrorBanner(submitError!),
                ],
                SizedBox(height: 24.h),
                UJobButton(
                  label: buttonLabel,
                  onTap: submit,
                  isLoading: loading,
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _onToggle2FA(bool enable) {
    _show2FAConfirmSheet(context, enable: enable);
  }

  Future<void> _show2FAConfirmSheet(
    BuildContext context, {
    required bool enable,
  }) async {
    final l10n = context.l10n;
    final isEmployer = ref.read(activeRoleProvider) == 'employer';
    final passwordCtrl = TextEditingController();

    String? passwordError;
    String? submitError;
    var loading = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            Future<void> submit() async {
              final password = passwordCtrl.text.trim();
              setSheetState(() {
                passwordError =
                    password.isEmpty ? l10n.errorRequiredField : null;
                submitError = null;
              });
              if (passwordError != null) return;

              setSheetState(() => loading = true);
              try {
                await ref.read(dioClientProvider).dio.patch(
                  isEmployer ? Ep.emp2FA : Ep.seek2FA,
                  data: {'enabled': enable, 'current_password': password},
                );
                if (!sheetContext.mounted) return;
                Navigator.pop(sheetContext);
                if (mounted) {
                  setState(() => _twoFa = enable);
                  UJobToast.success(
                    context,
                    enable ? l10n.twoFAEnabledSuccess : l10n.twoFADisabledSuccess,
                  );
                }
              } catch (_) {
                if (!sheetContext.mounted) return;
                setSheetState(() {
                  loading = false;
                  submitError = l10n.error;
                });
              }
            }

            return _SettingsSheet(
              title: enable ? l10n.confirm2FAEnable : l10n.confirm2FADisable,
              subtitle: enable
                  ? l10n.enable2FADescription
                  : l10n.disable2FADescription,
              children: [
                UJobTextField(
                  label: l10n.currentPassword,
                  hint: l10n.passwordMaskHint,
                  controller: passwordCtrl,
                  errorText: passwordError,
                  isPassword: true,
                  isRequired: true,
                  textInputAction: TextInputAction.done,
                ),
                if (submitError != null) ...[
                  SizedBox(height: 12.h),
                  _SettingsErrorBanner(submitError!),
                ],
                SizedBox(height: 24.h),
                UJobButton(
                  label: enable ? l10n.confirm2FAEnable : l10n.confirm2FADisable,
                  onTap: submit,
                  isLoading: loading,
                ),
              ],
            );
          },
        );
      },
    );
  }



  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => UJobAlertDialog(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedAlert02,
          color: AppColors.error,
          size: 32.r,
        ),
        iconBgColor: AppColors.error,
        title: context.l10n.deleteAccount,
        description: context.l10n.deleteAccountDescription,
        confirmText: context.l10n.delete,
        confirmColor: AppColors.error,
        cancelText: context.l10n.cancel,
        onConfirm: () => Navigator.pop(ctx),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => UJobAlertDialog(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedLogout01,
          color: AppColors.error,
          size: 32.r,
        ),
        iconBgColor: AppColors.error,
        title: context.l10n.signOut,
        description: context.l10n.signOutConfirmation,
        confirmText: context.l10n.signOut,
        confirmColor: AppColors.error,
        cancelText: context.l10n.cancel,
        onConfirm: () {
          Navigator.pop(ctx);
          _signOut(context);
        },
      ),
    );
  }

  void _signOut(BuildContext context) {
    ref.read(authProvider.notifier).logout();
    context.go('/role-picker');
  }
}

class _SettingsSheet extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;

  const _SettingsSheet({
    required this.title,
    this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20.w,
          20.h,
          20.w,
          MediaQuery.of(context).viewInsets.bottom + 24.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: AppText.heading2)),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedCancel01,
                    color: AppColors.text,
                    size: 22.r,
                  ),
                ),
              ],
            ),
            if (subtitle != null) ...[
              SizedBox(height: 4.h),
              Text(
                subtitle!,
                style: AppText.body.copyWith(color: AppColors.muted),
              ),
            ],
            SizedBox(height: 20.h),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _SettingsErrorBanner extends StatelessWidget {
  final String message;

  const _SettingsErrorBanner(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
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
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
      child: Text(
        title,
        style: AppText.small.copyWith(
          color: AppColors.muted,
          letterSpacing: 1,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SectionContainer extends StatelessWidget {
  final List<Widget> children;
  const _SectionContainer({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(children: children),
    );
  }
}

class _NavTile extends StatelessWidget {
  final String label;
  final String? subtitle;
  final Color? textColor;
  final VoidCallback onTap;
  final bool showBorder;
  final bool showArrow;

  const _NavTile({
    required this.label,
    this.subtitle,
    this.textColor,
    required this.onTap,
    this.showBorder = true,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 16.w, 16.h),
        decoration: BoxDecoration(
          border: showBorder
              ? Border(bottom: BorderSide(color: AppColors.borderLight))
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppText.bodyBold.copyWith(
                      color: textColor ?? AppColors.text,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      subtitle!,
                      style: AppText.small.copyWith(color: AppColors.muted),
                    ),
                  ],
                ],
              ),
            ),
            if (showArrow)
              HugeIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                color: AppColors.muted,
                size: 20.r,
              ),
          ],
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showBorder;

  const _ToggleTile({
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primary; // Or seeker primary if needed

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 16.w, 16.h),
      decoration: BoxDecoration(
        border: showBorder
            ? Border(bottom: BorderSide(color: AppColors.borderLight))
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppText.bodyBold.copyWith(color: AppColors.text),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    subtitle!,
                    style: AppText.small.copyWith(color: AppColors.muted),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: primaryColor,
            inactiveTrackColor: AppColors.borderLight,
          ),
        ],
      ),
    );
  }
}
