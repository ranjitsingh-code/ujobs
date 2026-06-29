import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/feature_flags_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/router/app_router.dart';
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
import '../../employer/settings/employer_settings_provider.dart';
import '../../seeker/settings/seeker_settings_provider.dart';


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

  // Additional Employer Prefs
  bool _notifSecurity = true;
  bool _notifBrowser = false;
  bool _showEmailToCandidates = false;
  bool _showPhoneToCandidates = false;
  String _language = 'en';
  String _timezone = 'UTC';
  String _dateFormat = 'DD/MM/YYYY';

  bool _hasInitializedPrefs = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).valueOrNull;
      if (user != null) {
        setState(() {
          _twoFa = user.twoFactorEnabled;
        });
      }
    });
  }

  Future<void> _updateEmployerPref(String key, dynamic value) async {
    try {
      // The local setState inside the ToggleTile's onChanged has already updated the UI instantly.
      // We just quietly sync the change to the backend here without rebuilding the entire screen!
      await ref.read(employerSettingsServiceProvider).updatePreferences({key: value});
      
      if (mounted) {
        UJobToast.success(
          context, 
          'Update Successful',
          sub: 'Your preferences have been successfully updated.'
        );
      }
    } catch (_) {
      if (mounted) {
        UJobToast.error(
          context, 
          'Update Failed',
          sub: 'Failed to update preference. Please try again.'
        );
      }
      // If we wanted to revert local state on failure, we could re-read from the provider
      // but for now, we just show the error toast.
    }
  }

  Future<void> _updateSeekerPref(String key, dynamic value) async {
    try {
      await ref.read(seekerSettingsServiceProvider).updatePreferences({key: value});
      if (mounted) {
        UJobToast.success(
          context, 
          'Update Successful',
          sub: 'Your preferences have been successfully updated.'
        );
      }
    } catch (_) {
      if (mounted) {
        UJobToast.error(
          context, 
          'Update Failed',
          sub: 'Failed to update preference. Please try again.'
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final role = ref.watch(activeRoleProvider);
    final isEmployer = role == 'employer';
    final featureFlagsAsync = ref.watch(featureFlagsProvider);
    final featureFlags = featureFlagsAsync.valueOrNull;

    if (isEmployer) {
      final settingsAsync = ref.watch(employerSettingsProvider);
      if (settingsAsync.isLoading) {
         return Scaffold(
           backgroundColor: AppColors.background,
           appBar: UJobAppBar(title: l10n.settings, showBack: true, backgroundColor: AppColors.background),
           body: const Center(child: CircularProgressIndicator()),
         );
      } else if (settingsAsync.hasValue && !_hasInitializedPrefs) {
         final prefs = settingsAsync.value!.prefs;
         WidgetsBinding.instance.addPostFrameCallback((_) {
           if (mounted) {
             setState(() {
               _emailNewJobApplication = prefs.notifNewApplication;
               _emailCandidateMessage = prefs.notifMessages;
               _emailInterviewResponse = prefs.notifInterview;
               _emailMarketing = prefs.notifMarketing;
               _visibilityMode = prefs.companyProfilePublic ? 'public' : 'private';
               
               _notifSecurity = prefs.notifSecurity;
               _notifBrowser = prefs.notifBrowser;
               _showEmailToCandidates = prefs.showEmailToCandidates;
               _showPhoneToCandidates = prefs.showPhoneToCandidates;
               _language = prefs.language;
               _timezone = prefs.timezone;
               _dateFormat = prefs.dateFormat;
               
               // Read 2FA from settings user payload if available
               final userPayload = settingsAsync.value!.user;
               if (userPayload.containsKey('two_factor_enabled') || userPayload.containsKey('two_factor_authentication')) {
                 _twoFa = (userPayload['two_factor_enabled'] ?? userPayload['two_factor_authentication']) == true;
               }

               _hasInitializedPrefs = true;
             });
           }
         });
      }
    } else {
      final settingsAsync = ref.watch(seekerSettingsProvider);
      if (settingsAsync.isLoading) {
         return Scaffold(
           backgroundColor: AppColors.background,
           appBar: UJobAppBar(title: l10n.settings, showBack: true, backgroundColor: AppColors.background),
           body: const Center(child: CircularProgressIndicator()),
         );
      } else if (settingsAsync.hasValue && !_hasInitializedPrefs) {
         final prefs = settingsAsync.value!.prefs;
         WidgetsBinding.instance.addPostFrameCallback((_) {
           if (mounted) {
             setState(() {
               _emailNewJobApplication = prefs.notifNewApplication;
               _emailCandidateMessage = prefs.notifMessages;
               _emailInterviewResponse = prefs.notifInterview;
               _emailMarketing = prefs.notifMarketing;
               
               _notifSecurity = prefs.notifSecurity;
               _notifBrowser = prefs.notifBrowser;
               
               _profileVisible = prefs.companyProfilePublic;
               _showEmailToCandidates = prefs.showEmailToCandidates;
               _showPhoneToCandidates = prefs.showPhoneToCandidates;
               
               _language = prefs.language;
               _timezone = prefs.timezone;
               _dateFormat = prefs.dateFormat;
               
               final userPayload = settingsAsync.value!.user;
               if (userPayload.containsKey('two_factor_enabled') || userPayload.containsKey('two_factor_authentication')) {
                 _twoFa = (userPayload['two_factor_enabled'] ?? userPayload['two_factor_authentication']) == true;
               }

               _hasInitializedPrefs = true;
             });
           }
         });
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: UJobAppBar(
        title: l10n.settings,
        showBack: true,
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        top: false,
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
                /*
                _NavTile(
                  label: l10n.auditLog,
                  subtitle: l10n.auditLogSubtitle,
                  showBorder: false,
                  onTap: () {
                    if (isEmployer) {
                      context.push('/employer/settings/audit-log');
                    } else {
                      context.push('/seeker/settings/audit-log');
                    }
                  },
                ),
                */
              ],
            ),

            if (isEmployer && featureFlags?.plansWallet == true) ...[
              SizedBox(height: 24.h),
              _SectionTitle('BILLING'),
              _SectionContainer(
                children: [
                  _NavTile(
                    label: l10n.walletAndBilling,
                    subtitle: 'Manage balance and view payment history',
                    showBorder: false,
                    onTap: () {
                      context.push('/employer/wallet');
                    },
                  ),
                ],
              ),
            ],

            SizedBox(height: 24.h),

            // ================= NOTIFICATIONS =================
            _SectionTitle('NOTIFICATIONS'),
            _SectionContainer(
              children: [
                /*
                if (isEmployer) ...[
                  _ToggleTile(
                    label: l10n.newJobApplication,
                    subtitle: l10n.newJobApplicationSubtitle,
                    value: _emailNewJobApplication,
                    onChanged: (v) {
                        setState(() => _emailNewJobApplication = v);
                        _updateEmployerPref('notif_new_application', v);
                    },
                  ),
                  if (featureFlags?.chat == true)
                    _ToggleTile(
                      label: l10n.candidateMessages,
                      subtitle: l10n.candidateMessagesSubtitle,
                      value: _emailCandidateMessage,
                      onChanged: (v) {
                          setState(() => _emailCandidateMessage = v);
                          _updateEmployerPref('notif_messages', v);
                      },
                    ),
                  _ToggleTile(
                    label: l10n.interviewResponses,
                    subtitle: l10n.interviewResponsesSubtitle,
                    value: _emailInterviewResponse,
                    onChanged: (v) {
                        setState(() => _emailInterviewResponse = v);
                        _updateEmployerPref('notif_interview', v);
                    },
                  ),
                  _ToggleTile(
                    label: 'Security Alerts',
                    subtitle: 'Login attempts and password changes',
                    value: _notifSecurity,
                    onChanged: (v) {
                       setState(() => _notifSecurity = v);
                       _updateEmployerPref('notif_security', v);
                    },
                  ),
                  _ToggleTile(
                    label: l10n.marketingEmails,
                    subtitle: l10n.marketingEmailsSubtitle,
                    value: _emailMarketing,
                    onChanged: (v) {
                       setState(() => _emailMarketing = v);
                       _updateEmployerPref('notif_marketing', v);
                    },
                  ),
                  _ToggleTile(
                    label: 'Push Notifications',
                    subtitle: 'Receive notifications on this device',
                    value: _notifBrowser,
                    onChanged: (v) {
                       setState(() => _notifBrowser = v);
                       _updateEmployerPref('notif_browser', v);
                    },
                  ),
                ] else ...[
                  _ToggleTile(
                    label: l10n.applicationUpdates,
                    value: _emailNewJobApplication,
                    onChanged: (v) {
                        setState(() => _emailNewJobApplication = v);
                        _updateSeekerPref('notif_new_application', v);
                    },
                  ),
                  _ToggleTile(
                    label: l10n.messages,
                    value: _emailCandidateMessage,
                    onChanged: (v) {
                        setState(() => _emailCandidateMessage = v);
                        _updateSeekerPref('notif_messages', v);
                    },
                  ),
                  _ToggleTile(
                    label: l10n.interviewResponses,
                    value: _emailInterviewResponse,
                    onChanged: (v) {
                        setState(() => _emailInterviewResponse = v);
                        _updateSeekerPref('notif_interview', v);
                    },
                  ),
                  _ToggleTile(
                    label: 'Security Alerts',
                    subtitle: 'Login attempts and password changes',
                    value: _notifSecurity,
                    onChanged: (v) {
                       setState(() => _notifSecurity = v);
                       _updateSeekerPref('notif_security', v);
                    },
                  ),
                  _ToggleTile(
                    label: l10n.marketingEmails,
                    subtitle: l10n.marketingEmailsSubtitle,
                    value: _emailMarketing,
                    onChanged: (v) {
                       setState(() => _emailMarketing = v);
                       _updateSeekerPref('notif_marketing', v);
                    },
                  ),
                  _ToggleTile(
                    label: 'Push Notifications',
                    subtitle: 'Receive notifications on this device',
                    value: _notifBrowser,
                    onChanged: (v) {
                       setState(() => _notifBrowser = v);
                       _updateSeekerPref('notif_browser', v);
                    },
                  ),
                ],
                */
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

            /*
            // ================= PRIVACY =================
            _SectionTitle(l10n.privacySection),
            if (isEmployer) ...[
              _SectionContainer(
                children: [
                  _ToggleTile(
                    label: l10n.publicProfile,
                    subtitle: l10n.publicProfileSubtitle,
                    value: _visibilityMode == 'public',
                    onChanged: (v) {
                       setState(() => _visibilityMode = v ? 'public' : 'private');
                       _updateEmployerPref('company_profile_public', v);
                    },
                  ),
                  _ToggleTile(
                    label: 'Show Email to Candidates',
                    subtitle: 'Display email on public profile',
                    value: _showEmailToCandidates,
                    onChanged: (v) {
                       setState(() => _showEmailToCandidates = v);
                       _updateEmployerPref('show_email_to_candidates', v);
                    },
                  ),
                  _ToggleTile(
                    label: 'Show Phone to Candidates',
                    subtitle: 'Display phone on public profile',
                    value: _showPhoneToCandidates,
                    onChanged: (v) {
                       setState(() => _showPhoneToCandidates = v);
                       _updateEmployerPref('show_phone_to_candidates', v);
                    },
                  ),
                ],
              ),
            ] else ...[
              _SectionContainer(
                children: [
                  _ToggleTile(
                    label: l10n.profileVisibility,
                    subtitle: l10n.profileVisibilitySubtitle,
                    value: _profileVisible,
                    onChanged: (v) {
                        setState(() => _profileVisible = v);
                        _updateSeekerPref('company_profile_public', v);
                    },
                    showBorder: true,
                  ),
                  _ToggleTile(
                    label: 'Show Email to Employers',
                    subtitle: 'Display email on your profile',
                    value: _showEmailToCandidates,
                    onChanged: (v) {
                        setState(() => _showEmailToCandidates = v);
                        _updateSeekerPref('show_email_to_candidates', v);
                    },
                    showBorder: true,
                  ),
                  _ToggleTile(
                    label: 'Show Phone to Employers',
                    subtitle: 'Display phone on your profile',
                    value: _showPhoneToCandidates,
                    onChanged: (v) {
                        setState(() => _showPhoneToCandidates = v);
                        _updateSeekerPref('show_phone_to_candidates', v);
                    },
                    showBorder: false,
                  ),
                ],
              ),
            ],

            SizedBox(height: 24.h),
            */

            if (isEmployer) ...[
              /*
              // ================= GENERAL PREFERENCES =================
              _SectionTitle('GENERAL PREFERENCES'),
              _SectionContainer(
                children: [
                  _ValueTile(
                    label: 'Language',
                    value: _language.toUpperCase(),
                    onTap: () {
                      // Show language picker logic
                    },
                  ),
                  _ValueTile(
                    label: 'Timezone',
                    value: _timezone,
                    onTap: () {},
                  ),
                  _ValueTile(
                    label: 'Date Format',
                    value: _dateFormat,
                    onTap: () {},
                    showBorder: false,
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              */

              // ================= DOWNLOAD ACCOUNT DATA =================
              _SectionTitle(l10n.downloadAccountData.toUpperCase()),
              _SectionContainer(
                children: [
                  _NavTile(
                    label: l10n.exportJobsCsv, 
                    showArrow: true,
                    showBorder: true,
                    onTap: () {
                      final url = ref.read(employerSettingsProvider).valueOrNull?.exportUrls['jobs_csv'];
                      if (url != null) {
                        launchUrlString(url, mode: LaunchMode.externalApplication);
                      }
                    }
                  ),
                  _NavTile(
                    label: l10n.exportApplicantsCsv,
                    showArrow: true,
                    showBorder: false,
                    onTap: () {
                      final url = ref.read(employerSettingsProvider).valueOrNull?.exportUrls['applicants_csv'];
                      if (url != null) {
                        launchUrlString(url, mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 24.h),
            ],

            // ================= ABOUT & SUPPORT =================
            _SectionTitle('ABOUT & SUPPORT'),
            _SectionContainer(
              children: [
                ref
                    .watch(cmsPagesListProvider)
                    .when(
                      data: (pages) {
                        return Column(
                          children: pages.asMap().entries.map((entry) {
                            final isLast = entry.key == pages.length - 1;
                            return _NavTile(
                              label: entry.value.title,
                              onTap: () =>
                                  context.push('/pages/${entry.value.slug}'),
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
                if (!isEmployer) ...[
                  _NavTile(
                    label: l10n.signOut,
                    subtitle: 'Sign out of your account on this device',
                    textColor: AppColors.error,
                    showArrow: false,
                    showBorder: false, // Change to true if Sign Out All is uncommented
                    onTap: () => _showSignOutDialog(context),
                  ),
                  /*
                  _NavTile(
                    label: 'Sign Out All Devices',
                    subtitle: 'Revoke access on all logged-in devices',
                    textColor: AppColors.error,
                    showArrow: false,
                    showBorder: false,
                    onTap: () => _showSignOutAllDialog(context),
                  ),
                  */
                ],
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
                    showBorder: false, // Changed from true to false since it is now the only item in the section
                    onTap: () => _showSignOutDialog(context),
                  ),
                  /*
                  _NavTile(
                    label: 'Sign Out All Devices',
                    subtitle: 'Revoke access on all logged-in devices',
                    textColor: AppColors.error,
                    showArrow: false,
                    showBorder: false,
                    onTap: () => _showSignOutAllDialog(context),
                  ),
                  */
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
                if (isEmployer) {
                  await ref.read(dioClientProvider).dio.put(
                    Ep.empPassword,
                    data: {
                      'current_password': current,
                      'new_password': next,
                    },
                  );
                } else {
                  await ref.read(dioClientProvider).dio.put(
                    Ep.seekPassword,
                    data: {
                      'current_password': current,
                      'new_password': next,
                    },
                  );
                }

                if (!sheetContext.mounted) return;
                Navigator.pop(sheetContext);
                if (mounted) {
                  UJobToast.success(
                    context, 
                    l10n.passwordUpdatedSuccess,
                    sub: 'You can now log in with your new password.',
                  );
                }
              } on DioException catch (e) {
                if (!sheetContext.mounted) return;
                setSheetState(() {
                  loading = false;
                  submitError = e.response?.data?['error']?['message'] ?? 
                                e.response?.data?['message'] ?? 
                                l10n.error;
                });
                if (mounted) UJobToast.error(context, l10n.error, sub: submitError!);
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
        (kDebugMode
            ? (isEmployer
                ? 'nexoviasolutions@gmail.com'
                : 'mdazadhossain95@gmail.com')
            : '');
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
              if (loading) return;
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
                if (isEmail) {
                  await ref.read(dioClientProvider).dio.post(
                    isEmployer ? Ep.empEmailRequestOtp : Ep.seekEmailRequestOtp,
                    data: {
                      'new_email': value,
                      'current_password': passwordCtrl.text,
                    },
                  );
                } else {
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
                }

                if (!sheetContext.mounted) return;
                Navigator.pop(sheetContext);
                if (mounted) {
                  if (isEmail) {
                    final success = await context.push<bool>('/change-email-otp', extra: {'email': currentEmail});
                    if (success == true) {
                      // Handled by the OTP screen's countdown dialog
                    }
                  } else {
                    ref.invalidate(authProvider);
                    UJobToast.success(context, successMessage, sub: 'Your contact info has been updated.');
                  }
                }
              } on DioException catch (e) {
                if (!sheetContext.mounted) return;
                setSheetState(() {
                  loading = false;
                  submitError = e.response?.data?['error']?['message'] ?? 
                                e.response?.data?['message'] ?? 
                                l10n.error;
                });
                if (mounted) UJobToast.error(context, l10n.error, sub: submitError!);
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
                    hint: isEmail ? l10n.emailHint : null,
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
                passwordError = password.isEmpty
                    ? l10n.errorRequiredField
                    : null;
                submitError = null;
              });
              if (passwordError != null) return;

              setSheetState(() => loading = true);
              try {
                await ref
                    .read(dioClientProvider)
                    .dio
                    .post(
                      isEmployer ? Ep.emp2FA : Ep.seek2FA,
                      data: {'enable': enable, 'current_password': password},
                    );
                if (!sheetContext.mounted) return;
                Navigator.pop(sheetContext);
                if (mounted) {
                  setState(() => _twoFa = enable);
                  ref.invalidate(authProvider);
                  UJobToast.success(
                    context,
                    enable
                        ? l10n.twoFAEnabledSuccess
                        : l10n.twoFADisabledSuccess,
                    sub: enable ? 'Two-factor authentication is now active on your account.' : 'Two-factor authentication has been turned off.',
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
                  label: enable
                      ? l10n.confirm2FAEnable
                      : l10n.confirm2FADisable,
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
        onConfirm: () {
          Navigator.pop(ctx);
          _deleteAccount(context);
        },
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    // Show a loading overlay so the user can't interact while deleting
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final isEmployer = ref.read(activeRoleProvider) == 'employer';
      
      if (isEmployer) {
        await ref.read(dioClientProvider).dio.delete('/employer/settings/account');
      } else {
        await ref.read(dioClientProvider).dio.delete(Ep.seekAccount);
      }

      if (!context.mounted) return;
      
      // Pop the loading overlay
      Navigator.pop(context);

      // Successfully deleted on backend, now clear local state
      ref.read(authProvider.notifier).logout(localOnly: true);
      
      // Restart the app from the splash screen
      context.go('/');

    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Pop the loading overlay
      UJobToast.error(
        context, 
        'Failed to delete account', 
        sub: 'Please try again or contact support.'
      );
    }
  }

  Future<void> _signOutAllDevices(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final isEmployer = ref.read(activeRoleProvider) == 'employer';
      
      if (isEmployer) {
        // Employer specific logic if any. 
      } else {
        await ref.read(dioClientProvider).dio.post(Ep.seekSignOutAll);
      }

      if (!context.mounted) return;
      
      Navigator.pop(context);
      ref.read(authProvider.notifier).logout(localOnly: true);
      context.go('/');

    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      UJobToast.error(context, 'Error', sub: 'Failed to sign out all devices. Please try again.');
    }
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
    // Standard sign out logic (calls the normal logout endpoint)
    ref.read(authProvider.notifier).logout();
    context.go('/role-picker');
  }

  void _showSignOutAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => UJobAlertDialog(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedLogout01,
          color: AppColors.error,
          size: 32.r,
        ),
        iconBgColor: AppColors.error,
        title: 'Sign Out All Devices',
        description: 'This will revoke all active sessions across all devices. You will be logged out of this device immediately.',
        confirmText: 'Sign Out All',
        confirmColor: AppColors.error,
        cancelText: context.l10n.cancel,
        onConfirm: () {
          Navigator.pop(ctx);
          _signOutAll(context);
        },
      ),
    );
  }

  Future<void> _signOutAll(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final isEmployer = ref.read(activeRoleProvider) == 'employer';
      await ref.read(dioClientProvider).dio.post(isEmployer ? '/employer/settings/sign-out-all' : Ep.seekSignOutAll);

      if (!context.mounted) return;
      
      Navigator.pop(context); // Pop the loading overlay
      
      // Local wipe only, since the remote session is already dead!
      ref.read(authProvider.notifier).logout(localOnly: true);
      context.go('/');

    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Pop the loading overlay
      UJobToast.error(
        context, 
        'Failed to sign out all devices', 
        sub: 'Please check your connection and try again.'
      );
    }
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _ValueTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool showBorder;

  const _ValueTile({
    required this.label,
    required this.value,
    required this.onTap,
    this.showBorder = true,
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
              child: Text(
                label,
                style: AppText.bodyBold.copyWith(color: AppColors.text),
              ),
            ),
            Text(
              value,
              style: AppText.body.copyWith(color: AppColors.muted),
            ),
          ],
        ),
      ),
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
