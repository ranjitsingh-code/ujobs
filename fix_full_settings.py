import re

with open('lib/features/employer/settings/employer_settings_screen.dart', 'r') as f:
    text = f.read()

# We completely rewrite the _EmpSettingsState to match the requested layout.
# We'll replace everything from class _EmpSettingsState to the end of the file (before the components if possible, or just rewrite the whole file for safety).
# Since I only want to replace the state class and its methods, I will use regex.

# Let's find the start of _EmpSettingsState
# text = re.sub(r'class _EmpSettingsState extends ConsumerState<EmployerSettingsScreen> \{.*', new_state_code, text, flags=re.DOTALL)
# Actually, let's just rewrite the whole file to make sure it's perfect and has no syntax errors.

full_code = """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ujob_button.dart';
import '../../../core/widgets/ujob_text_field.dart';
import '../../../core/widgets/ujob_app_bar.dart';

import '../../../core/providers/locale_provider.dart';
import '../../../core/utils/l10n_extensions.dart';

class EmployerSettingsScreen extends ConsumerStatefulWidget {
  const EmployerSettingsScreen({super.key});

  @override
  ConsumerState<EmployerSettingsScreen> createState() => _EmpSettingsState();
}

class _EmpSettingsState extends ConsumerState<EmployerSettingsScreen> {
  // Security
  bool _twoFa = false;
  
  // Notifications - Email
  bool _emailNewApplicant = true;
  bool _emailCandidateMessage = true;
  bool _emailInterviewResponse = true;
  bool _emailMarketing = false;
  // Notifications - Browser
  bool _pushNotif = true;
  // Notifications - Chat
  bool _chatSound = true;
  bool _chatPopup = true;

  // Privacy
  bool _privacyShowEmail = true;
  bool _privacyShowPhone = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: UJobAppBar(
        title: l10n.settings,
        showBack: true,
        backgroundColor: AppColors.surface,
      ),
      body: ListView(
        padding: EdgeInsets.only(bottom: 120.h),
        children: [
          // ================= SECURITY =================
          _SectionHeader('SECURITY'),
          _NavTile(
            label: l10n.changePassword,
            onTap: () => _showChangePasswordSheet(context),
          ),
          _NavTile(
            label: l10n.changeEmail,
            onTap: () => _showChangeFieldSheet(context, l10n.email, TextInputType.emailAddress),
          ),
          _NavTile(
            label: l10n.changePhone,
            onTap: () => _showChangeFieldSheet(context, l10n.phone, TextInputType.phone),
          ),
          _ToggleTile(
            label: l10n.twoFactorAuth,
            value: _twoFa,
            onChanged: (v) => setState(() => _twoFa = v),
            hideDivider: true,
          ),
          
          // ================= NOTIFICATIONS =================
          _SectionHeader('NOTIFICATIONS'),
          _SubSectionHeader('Email Notifications'),
          _ToggleTile(
            label: 'New Job Applicant',
            value: _emailNewApplicant,
            onChanged: (v) => setState(() => _emailNewApplicant = v),
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
            label: 'Marketing Emails',
            value: _emailMarketing,
            onChanged: (v) => setState(() => _emailMarketing = v),
          ),
          
          _SubSectionHeader('Browser Notifications'),
          _ToggleTile(
            label: 'Push Notifications',
            value: _pushNotif,
            onChanged: (v) => setState(() => _pushNotif = v),
          ),
          
          _SubSectionHeader('Chat Notifications'),
          _ToggleTile(
            label: 'Message Sound',
            value: _chatSound,
            onChanged: (v) => setState(() => _chatSound = v),
          ),
          _ToggleTile(
            label: 'Pop up Notification',
            value: _chatPopup,
            onChanged: (v) => setState(() => _chatPopup = v),
            hideDivider: true,
          ),
          
          // ================= PRIVACY =================
          _SectionHeader('PRIVACY'),
          _NavTile(label: 'Company Profile Visibility', subtitle: 'Public', onTap: () {}),
          _SubSectionHeader('Contact Visibility'),
          _ToggleTile(
            label: 'Show Email to Candidates',
            value: _privacyShowEmail,
            onChanged: (v) => setState(() => _privacyShowEmail = v),
          ),
          _ToggleTile(
            label: 'Show Phone to Candidates',
            value: _privacyShowPhone,
            onChanged: (v) => setState(() => _privacyShowPhone = v),
            hideDivider: true,
          ),
          
          // ================= PREFERENCES =================
          _SectionHeader('PREFERENCES'),
          _SubSectionHeader('Account Preferences'),
          _NavTile(
            label: l10n.appLanguage,
            subtitle: locale.languageCode == 'en' ? 'English' : 'العربية',
            onTap: () => _showLanguageSheet(context),
          ),
          _NavTile(label: 'Timezone', subtitle: 'Europe / London', onTap: () {}),
          _NavTile(label: 'Date Format', subtitle: 'DD/MM/YYYY', onTap: () {}, hideDivider: true),
          
          // ================= ACCOUNT =================
          _SectionHeader('ACCOUNT'),
          _SubSectionHeader('Current Session'),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            child: Text(
              'This device · Active now',
              style: AppText.caption.copyWith(color: AppColors.muted),
            ),
          ),
          _NavTile(
            label: l10n.signOut,
            onTap: () => _signOut(context),
          ),
          _NavTile(
            label: 'Sign Out from All Devices',
            textColor: AppColors.error,
            onTap: () => _signOut(context),
          ),
          
          _SubSectionHeader('Download Account Data'),
          _NavTile(label: 'Export Jobs (CSV)', onTap: () {}),
          _NavTile(label: 'Export Applicants (CSV)', onTap: () {}),
          
          _SubSectionHeader('Delete Account'),
          _NavTile(
            label: 'Delete My Account',
            textColor: AppColors.error,
            onTap: () => _showDeleteDialog(context),
            hideDivider: true,
          ),
          
          // ================= ACTIVITY LOG =================
          _SectionHeader('ACTIVITY LOG'),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
            child: Text(
              'All actions performed on your account. We store activity records for the last 30 days only. Any records older than 30 days are automatically deleted.',
              style: AppText.caption.copyWith(color: AppColors.muted, height: 1.5),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 32.h),
            child: Center(
              child: Text(
                'No activity recorded yet',
                style: AppText.bodySm.copyWith(color: AppColors.muted2, fontStyle: FontStyle.italic),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: AppRadius.pill,
            ),
          ),
          SizedBox(height: 20.h),
          Text(context.l10n.language, style: AppText.heading3),
          SizedBox(height: 12.h),
          ListTile(
            title: const Text('English'),
            trailing: ref.read(localeProvider).languageCode == 'en'
                ? const HugeIcon(
                    icon: HugeIcons.strokeRoundedTick01,
                    color: AppColors.primary,
                  )
                : null,
            onTap: () {
              ref.read(localeProvider.notifier).setLocale(const Locale('en'));
              Navigator.pop(ctx);
            },
          ),
          ListTile(
            title: const Text('العربية'),
            trailing: ref.read(localeProvider).languageCode == 'ar'
                ? const HugeIcon(
                    icon: HugeIcons.strokeRoundedTick01,
                    color: AppColors.primary,
                  )
                : null,
            onTap: () {
              ref.read(localeProvider.notifier).setLocale(const Locale('ar'));
              Navigator.pop(ctx);
            },
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  void _showChangePasswordSheet(BuildContext context) {
    final l10n = context.l10n;
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.changePassword, style: AppText.heading3),
            const SizedBox(height: 20),
            UJobTextField(
              label: l10n.currentPassword,
              controller: oldCtrl,
              isPassword: true,
            ),
            const SizedBox(height: 16),
            UJobTextField(
              label: l10n.newPassword,
              controller: newCtrl,
              isPassword: true,
            ),
            const SizedBox(height: 16),
            UJobTextField(
              label: 'Confirm New Password',
              controller: confirmCtrl,
              isPassword: true,
            ),
            const SizedBox(height: 24),
            UJobButton(
              text: 'Update Password',
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeFieldSheet(
    BuildContext context,
    String fieldName,
    TextInputType type,
  ) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Change $fieldName', style: AppText.heading3),
            const SizedBox(height: 20),
            UJobTextField(label: 'New $fieldName', controller: ctrl, keyboardType: type),
            const SizedBox(height: 16),
            UJobTextField(label: 'Current Password (for verification)', controller: TextEditingController(), isPassword: true),
            const SizedBox(height: 24),
            UJobButton(
              text: 'Update $fieldName',
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Account'),
        content: const Text(
          'Once you delete your account, all of your data including jobs, applications, and settings will be permanently removed. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppText.bodySm.copyWith(color: AppColors.text)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _signOut(context);
            },
            child: Text('Delete My Account', style: AppText.bodySm.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _signOut(BuildContext context) {
    ref.read(authProvider.notifier).logout();
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.bg,
      padding: EdgeInsets.fromLTRB(20.w, 32.h, 20.w, 12.h),
      child: Text(
        title.toUpperCase(),
        style: AppText.caption.copyWith(
          color: AppColors.muted2,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _SubSectionHeader extends StatelessWidget {
  final String title;
  const _SubSectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 4.h),
      child: Text(
        title,
        style: AppText.bodySm.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
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
  final bool hideDivider;

  const _NavTile({
    required this.label,
    this.subtitle,
    this.textColor,
    required this.onTap,
    this.hideDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: hideDivider ? null : Border(
            bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5), width: 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppText.body.copyWith(
                      color: textColor ?? AppColors.text,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 4.h),
                    Text(subtitle!, style: AppText.caption.copyWith(color: AppColors.muted)),
                  ],
                ],
              ),
            ),
            HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight01,
              color: AppColors.muted2,
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
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool hideDivider;

  const _ToggleTile({
    required this.label,
    required this.value,
    required this.onChanged,
    this.hideDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: hideDivider ? null : Border(
          bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppText.body.copyWith(
                color: AppColors.text,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.white,
            activeTrackColor: AppColors.primary,
            inactiveThumbColor: AppColors.white,
            inactiveTrackColor: AppColors.border,
          ),
        ],
      ),
    );
  }
}
"""

with open('lib/features/employer/settings/employer_settings_screen.dart', 'w') as f:
    f.write(full_code)
