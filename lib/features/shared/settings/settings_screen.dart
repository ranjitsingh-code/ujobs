import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/role_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ujob_app_bar.dart';
import '../../../core/widgets/ujob_alert_dialog.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/utils/l10n_extensions.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Shared States
  bool _twoFa = false;

  // Notifications - Shared
  bool _pushNotif = true;

  // Notifications - Employer
  bool _emailCandidateMessage = true;
  bool _emailInterviewResponse = true;
  bool _emailMarketing = false;
  bool _chatSound = true;
  bool _chatPopup = true;

  // Notifications - Seeker
  bool _pushNewJobs = true;
  bool _pushApplicationUpdates = true;
  bool _pushMessages = true;

  // Privacy & Preferences
  bool _profileVisible = true;
  bool _showSalaryExpectations = false;
  bool _privacyShowEmail = true;
  bool _privacyShowPhone = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final role = ref.watch(activeRoleProvider);
    final isEmployer = role == 'employer';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: UJobAppBar(
        title: l10n.settings,
        showBack: true,
        backgroundColor: AppColors.background,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 120.h),
        children: [
          // ================= SECURITY =================
          _SectionTitle('SECURITY'),
          _SectionContainer(
            children: [
              _NavTile(
                label: l10n.changePassword,
                subtitle: 'Use a strong password to protect your account',
                onTap: () => _showChangePasswordSheet(context),
              ),
              _NavTile(
                label: l10n.changeEmail,
                subtitle: 'Update your login email address',
                onTap: () => _showChangeFieldSheet(
                  context: context,
                  title: l10n.changeEmail,
                  fieldLabel: l10n.email,
                  buttonLabel: l10n.save,
                  type: TextInputType.emailAddress,
                ),
              ),
              _NavTile(
                label: l10n.changePhone,
                subtitle: 'Update your contact phone number',
                onTap: () => _showChangeFieldSheet(
                  context: context,
                  title: l10n.changePhone,
                  fieldLabel: l10n.phone,
                  buttonLabel: l10n.save,
                  type: TextInputType.phone,
                ),
              ),
              if (isEmployer) ...[
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Two-Factor Authentication',
                        style: AppText.bodyBold.copyWith(color: AppColors.text),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Add an extra layer of security to your account',
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
                                        ? 'Status: Enabled'
                                        : 'Status: Disabled',
                                    style: AppText.bodyBold.copyWith(
                                      color: _twoFa
                                          ? AppColors.success
                                          : AppColors.muted,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'Authenticator App (Google, Authy)',
                                    style: AppText.small.copyWith(
                                      color: AppColors.text,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _twoFa,
                              onChanged: (v) => setState(() => _twoFa = v),
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
            ],
          ),

          SizedBox(height: 24.h),

          // ================= NOTIFICATIONS =================
          _SectionTitle('NOTIFICATIONS'),
          _SectionContainer(
            children: [
              if (isEmployer) ...[
                _NavTile(
                  label: 'Email Notifications',
                  subtitle: 'Manage what emails you receive from us',
                  showArrow: false,
                  showBorder: false,
                  onTap: () {},
                ),
                _ToggleTile(
                  label: 'Candidate Messages',
                  value: _emailCandidateMessage,
                  onChanged: (v) => setState(() => _emailCandidateMessage = v),
                ),
                _ToggleTile(
                  label: 'Interview Responses',
                  value: _emailInterviewResponse,
                  onChanged: (v) => setState(() => _emailInterviewResponse = v),
                ),
                _ToggleTile(
                  label: 'Marketing & Tips',
                  value: _emailMarketing,
                  onChanged: (v) => setState(() => _emailMarketing = v),
                ),
                _NavTile(
                  label: 'Browser Notifications',
                  subtitle:
                      'Get alerts when the app is running in the background',
                  showArrow: false,
                  showBorder: false,
                  onTap: () {},
                ),
                _ToggleTile(
                  label: 'Allow Push Notifications',
                  value: _pushNotif,
                  onChanged: (v) => setState(() => _pushNotif = v),
                ),
                _NavTile(
                  label: 'Chat Notifications',
                  subtitle: 'Settings for real-time messaging',
                  showArrow: false,
                  showBorder: false,
                  onTap: () {},
                ),
                _ToggleTile(
                  label: 'Sound Alerts',
                  value: _chatSound,
                  onChanged: (v) => setState(() => _chatSound = v),
                ),
                _ToggleTile(
                  label: 'Popup Preview',
                  value: _chatPopup,
                  onChanged: (v) => setState(() => _chatPopup = v),
                  showBorder: false,
                ),
              ] else ...[
                _ToggleTile(
                  label: 'New Job Recommendations',
                  subtitle:
                      'Get notified when jobs matching your profile are posted',
                  value: _pushNewJobs,
                  onChanged: (v) => setState(() => _pushNewJobs = v),
                ),
                _ToggleTile(
                  label: 'Application Updates',
                  subtitle: 'Get notified when your application status changes',
                  value: _pushApplicationUpdates,
                  onChanged: (v) => setState(() => _pushApplicationUpdates = v),
                ),
                _ToggleTile(
                  label: 'Messages',
                  subtitle: 'Get notified when an employer sends you a message',
                  value: _pushMessages,
                  onChanged: (v) => setState(() => _pushMessages = v),
                  showBorder: false,
                ),
              ],
            ],
          ),

          SizedBox(height: 24.h),

          // ================= PRIVACY & PREFERENCES =================
          _SectionTitle(isEmployer ? 'PRIVACY' : 'PRIVACY & PREFERENCES'),
          _SectionContainer(
            children: [
              if (isEmployer) ...[
                _ToggleTile(
                  label: 'Show Email on Profile',
                  subtitle: 'Candidates can see your contact email',
                  value: _privacyShowEmail,
                  onChanged: (v) => setState(() => _privacyShowEmail = v),
                ),
                _ToggleTile(
                  label: 'Show Phone on Profile',
                  subtitle: 'Candidates can see your contact phone',
                  value: _privacyShowPhone,
                  onChanged: (v) => setState(() => _privacyShowPhone = v),
                ),
                _ToggleTile(
                  label: 'Public Company Profile',
                  subtitle: 'Allow search engines to index your company page',
                  value: _profileVisible,
                  onChanged: (v) => setState(() => _profileVisible = v),
                  showBorder: false,
                ),
              ] else ...[
                _ToggleTile(
                  label: 'Public Profile',
                  subtitle: 'Allow employers to find your profile',
                  value: _profileVisible,
                  onChanged: (v) => setState(() => _profileVisible = v),
                ),
                _ToggleTile(
                  label: 'Show Salary Expectations',
                  subtitle: 'Allow employers to see your expected salary range',
                  value: _showSalaryExpectations,
                  onChanged: (v) => setState(() => _showSalaryExpectations = v),
                  showBorder: false,
                ),
              ],
            ],
          ),

          SizedBox(height: 24.h),

          // ================= PREFERENCES / LANGUAGE =================
          _SectionTitle(isEmployer ? 'PREFERENCES' : 'LANGUAGE'),
          _SectionContainer(
            children: [
              _NavTile(
                label: l10n.appLanguage,
                subtitle: locale.languageCode == 'en' ? 'English' : 'العربية',
                onTap: () => _showLanguageSheet(context),
                showBorder: isEmployer,
              ),
              if (isEmployer)
                _NavTile(
                  label: 'Timezone',
                  subtitle: 'UTC-5 (Eastern Time)',
                  onTap: () {},
                  showBorder: false,
                ),
            ],
          ),

          SizedBox(height: 24.h),

          if (isEmployer) ...[
            // ================= ACCOUNT DATA =================
            _SectionTitle('ACCOUNT DATA'),
            _SectionContainer(
              children: [
                _NavTile(
                  label: 'Download Data Archive',
                  subtitle: 'Request a copy of your personal data',
                  onTap: () {},
                ),
                _NavTile(
                  label: 'Data Portability',
                  subtitle: 'Export your job postings to CSV/JSON',
                  onTap: () {},
                  showBorder: false,
                ),
              ],
            ),
            SizedBox(height: 24.h),
          ],

          // ================= ACCOUNT =================
          _SectionTitle(isEmployer ? 'DELETE ACCOUNT' : 'ACCOUNT'),
          _SectionContainer(
            children: [
              _NavTile(
                label: l10n.deleteAccount,
                subtitle: 'Permanently delete your account and all data',
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
                  onTap: () => _signOut(context),
                ),
            ],
          ),

          if (isEmployer) ...[
            SizedBox(height: 24.h),
            // ================= LOG OUT (Employer puts it here or in account) =================
            _SectionContainer(
              children: [
                _NavTile(
                  label: l10n.signOut,
                  subtitle: 'Log out of this session',
                  textColor: AppColors.error,
                  showArrow: false,
                  showBorder: false,
                  onTap: () => _signOut(context),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // --- Helpers ---
  void _showChangePasswordSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(height: 300),
    );
  }

  void _showChangeFieldSheet({
    required BuildContext context,
    required String title,
    required String fieldLabel,
    required String buttonLabel,
    required TextInputType type,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(height: 300),
    );
  }

  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Language', style: AppText.heading2),
              SizedBox(height: 16.h),
              ListTile(
                title: const Text('English'),
                trailing: ref.read(localeProvider).languageCode == 'en'
                    ? const HugeIcon(
                        icon: HugeIcons.strokeRoundedCheckmarkBadge01,
                        color: AppColors.primary,
                      )
                    : null,
                onTap: () {
                  ref
                      .read(localeProvider.notifier)
                      .setLocale(const Locale('en'));
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: const Text('العربية'),
                trailing: ref.read(localeProvider).languageCode == 'ar'
                    ? const HugeIcon(
                        icon: HugeIcons.strokeRoundedCheckmarkBadge01,
                        color: AppColors.primary,
                      )
                    : null,
                onTap: () {
                  ref
                      .read(localeProvider.notifier)
                      .setLocale(const Locale('ar'));
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
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
        title: 'Delete Account',
        description:
            'Are you sure you want to delete your account? This action cannot be undone.',
        confirmText: 'Delete',
        confirmColor: AppColors.error,
        cancelText: 'Cancel',
        onConfirm: () => Navigator.pop(ctx),
      ),
    );
  }

  void _signOut(BuildContext context) {
    ref.read(authProvider.notifier).logout();
    context.go('/role-picker');
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
