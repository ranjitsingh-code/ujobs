import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ujob_button.dart';
import '../../../core/widgets/ujob_text_field.dart';
import '../../../core/widgets/ujob_alert_dialog.dart';
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
  bool _publicProfile = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: UJobAppBar(
        title: l10n.settings,
        showBack: true,
        backgroundColor: AppColors.bg,
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
                onTap: () => _showChangeFieldSheet(context: context, title: l10n.changeEmail, fieldLabel: l10n.email, buttonLabel: l10n.save, type: TextInputType.emailAddress),
              ),
              _NavTile(
                label: l10n.changePhone,
                subtitle: 'Update your contact phone number',
                onTap: () => _showChangeFieldSheet(context: context, title: l10n.changePhone, fieldLabel: l10n.phone, buttonLabel: l10n.save, type: TextInputType.phone),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Two-Factor Authentication', style: AppText.body.copyWith(color: AppColors.text)),
                    SizedBox(height: 4.h),
                    Text('Add an extra layer of security to your account', style: AppText.caption.copyWith(color: AppColors.muted)),
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: AppColors.bg,
                        borderRadius: AppRadius.sm,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _twoFa ? '2FA is enabled' : '2FA is disabled',
                                  style: AppText.body.copyWith(
                                    color: _twoFa ? AppColors.primary : AppColors.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Enable to require a code from your email each time you log in',
                                  style: AppText.caption.copyWith(color: AppColors.muted, height: 1.3),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Switch(
                            value: _twoFa,
                            onChanged: (v) => setState(() => _twoFa = v),
                            activeColor: AppColors.white,
                            activeTrackColor: AppColors.primary,
                            inactiveThumbColor: AppColors.white,
                            inactiveTrackColor: AppColors.border,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // ================= NOTIFICATIONS =================
          _SectionTitle('NOTIFICATIONS'),
          _SectionContainer(
            children: [
              _SubSectionHeader('Email Notifications', subtitle: 'Choose which emails you receive'),
              _ToggleTile(
                label: context.l10n.newJobApplication,
                subtitle: 'Get notified when a candidate applies to one of your jobs',
                value: _emailNewApplicant,
                onChanged: (v) => setState(() => _emailNewApplicant = v),
              ),
              _ToggleTile(
                label: context.l10n.candidateMessages,
                subtitle: 'Receive emails when candidates send you messages',
                value: _emailCandidateMessage,
                onChanged: (v) => setState(() => _emailCandidateMessage = v),
              ),
              _ToggleTile(
                label: context.l10n.interviewResponses,
                subtitle: 'Get notified about interview confirmations and cancellations',
                value: _emailInterviewResponse,
                onChanged: (v) => setState(() => _emailInterviewResponse = v),
              ),
              _ToggleTile(
                label: context.l10n.marketingEmails,
                subtitle: 'Product updates, tips, and promotional offers',
                value: _emailMarketing,
                onChanged: (v) => setState(() => _emailMarketing = v),
              ),
              
              _SubSectionHeader('Browser Notifications', subtitle: 'Push notifications in your browser'),
              _ToggleTile(
                label: context.l10n.pushNotifications,
                subtitle: 'Receive real-time push notifications in your browser',
                value: _pushNotif,
                onChanged: (v) => setState(() => _pushNotif = v),
              ),
              
              _SubSectionHeader('Chat Notifications', subtitle: 'Sound and alerts when you receive a new message'),
              _ToggleTile(
                label: context.l10n.messageSound,
                subtitle: 'Play a soft chime when a new message arrives',
                value: _chatSound,
                onChanged: (v) => setState(() => _chatSound = v),
              ),
              _ToggleTile(
                label: context.l10n.popupNotification,
                subtitle: 'Show a slide-in alert when a new message arrives',
                value: _chatPopup,
                onChanged: (v) => setState(() => _chatPopup = v),
                hideDivider: true,
              ),
            ],
          ),
          
          // ================= PRIVACY =================
          _SectionTitle('PRIVACY'),
          _SectionContainer(
            children: [
              _SubSectionHeader('Company Profile Visibility', subtitle: 'Control who can see your company profile'),
              _RadioTile(
                label: context.l10n.publicProfile,
                subtitle: 'Your company profile is visible to all job seekers, including those not logged in',
                value: true,
                groupValue: _publicProfile,
                onChanged: (v) => setState(() => _publicProfile = v!),
              ),
              _RadioTile(
                label: context.l10n.privateProfile,
                subtitle: 'Only logged-in job seekers can view your company profile',
                value: false,
                groupValue: _publicProfile,
                onChanged: (v) => setState(() => _publicProfile = v!),
              ),
              
              _SubSectionHeader('Contact Visibility', subtitle: 'Control what contact details candidates can see'),
              _ToggleTile(
                label: context.l10n.showEmailToCandidates,
                subtitle: 'Allow candidates to see your contact email on your profile',
                value: _privacyShowEmail,
                onChanged: (v) => setState(() => _privacyShowEmail = v),
              ),
              _ToggleTile(
                label: context.l10n.showPhoneToCandidates,
                subtitle: 'Allow candidates to see your contact phone on your profile',
                value: _privacyShowPhone,
                onChanged: (v) => setState(() => _privacyShowPhone = v),
                hideDivider: true,
              ),
            ],
          ),
          
          // ================= PREFERENCES =================
          _SectionTitle('PREFERENCES'),
          _SectionContainer(
            children: [
              _SubSectionHeader('Account Preferences', subtitle: 'Default regional settings'),
              _NavTile(
                label: l10n.appLanguage,
                subtitle: locale.languageCode == 'en' ? 'English' : 'العربية',
                onTap: () => _showLanguageSheet(context),
              ),
              _NavTile(label: context.l10n.timezone, subtitle: 'Europe / London', onTap: () {}),
              _NavTile(label: context.l10n.dateFormat, subtitle: 'DD/MM/YYYY', onTap: () {}, hideDivider: true),
            ],
          ),
          
          // ================= ACCOUNT =================
          _SectionTitle('ACCOUNT'),
          _SectionContainer(
            children: [
              _SubSectionHeader('Active Sessions', subtitle: 'Devices currently logged in'),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Current Session', style: AppText.body.copyWith(color: AppColors.text, fontWeight: FontWeight.w600)),
                          SizedBox(height: 4.h),
                          Text('This device · Active now', style: AppText.caption.copyWith(color: AppColors.muted)),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: AppRadius.sm,
                      ),
                      child: Text('Active', style: AppText.caption.copyWith(color: AppColors.success, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
                child: Text(
                  'Session management with detailed device info is coming soon.',
                  style: AppText.caption.copyWith(color: AppColors.muted, fontStyle: FontStyle.italic),
                ),
              ),
              _NavTile(
                label: l10n.signOut,
                onTap: () => _showSignOutDialog(context),
              ),
              _NavTile(
                label: l10n.signOutAllDevices,
                textColor: AppColors.error,
                onTap: () => _showSignOutAllDevicesDialog(context),
                hideDivider: true,
              ),
            ],
          ),
          
          // ================= ACCOUNT DATA =================
          _SectionTitle('ACCOUNT DATA'),
          _SectionContainer(
            children: [
              _SubSectionHeader('Download Account Data', subtitle: 'Export a copy of your data'),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
                child: Text(
                  'Download your jobs and applicant data as CSV files.',
                  style: AppText.caption.copyWith(color: AppColors.muted, height: 1.4),
                ),
              ),
              _NavTile(label: context.l10n.exportJobsCsv, onTap: () {}),
              _NavTile(label: context.l10n.exportApplicantsCsv, onTap: () {}, hideDivider: true),
            ],
          ),
          
          // ================= DELETE ACCOUNT =================
          _SectionTitle('DELETE ACCOUNT'),
          _SectionContainer(
            children: [
              _SubSectionHeader('Delete Account', subtitle: 'Permanently remove your account and all data'),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
                child: Text(
                  'Once you delete your account, all of your data including jobs, applications, and settings will be permanently removed. This action cannot be undone.',
                  style: AppText.caption.copyWith(color: AppColors.muted, height: 1.4),
                ),
              ),
              _NavTile(
                label: context.l10n.deleteMyAccount,
                textColor: AppColors.error,
                onTap: () => _showDeleteDialog(context),
                hideDivider: true,
              ),
            ],
          ),
          
          // ================= ACTIVITY LOG =================
          _SectionTitle('ACTIVITY LOG'),
          _SectionContainer(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 32.h),
                child: Column(
                  children: [
                    Text(
                      'All actions performed on your account. We store activity records for the last 30 days only. Any records older than 30 days are automatically deleted.',
                      style: AppText.caption.copyWith(color: AppColors.muted, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32.h),
                    HugeIcon(icon: HugeIcons.strokeRoundedClock01, color: AppColors.muted2, size: 48.r),
                    SizedBox(height: 16.h),
                    Text(
                      'No activity recorded yet',
                      style: AppText.body.copyWith(color: AppColors.muted2, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ],
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20.w),
                child: Text(context.l10n.language, style: AppText.heading3),
              ),
              Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: IconButton(
                  icon: const HugeIcon(icon: HugeIcons.strokeRoundedCancel01, color: AppColors.muted),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ListTile(
            title: Text(context.l10n.english),
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
            title: Text(context.l10n.dynamicKey),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.changePassword, style: AppText.heading3),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const HugeIcon(icon: HugeIcons.strokeRoundedCancel01, color: AppColors.muted),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
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
              label: l10n.confirmNewPassword,
              controller: confirmCtrl,
              isPassword: true,
            ),
            const SizedBox(height: 24),
            UJobButton(
              label: l10n.updatePassword,
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeFieldSheet({
    required BuildContext context,
    required String title,
    required String fieldLabel,
    required String buttonLabel,
    required TextInputType type,
  }) {
    final l10n = context.l10n;
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: AppText.heading3),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const HugeIcon(icon: HugeIcons.strokeRoundedCancel01, color: AppColors.muted),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 20),
            UJobTextField(label: fieldLabel, controller: ctrl, keyboardType: type),
            const SizedBox(height: 16),
            UJobTextField(label: l10n.currentPasswordVerification, controller: TextEditingController(), isPassword: true),
            const SizedBox(height: 24),
            UJobButton(
              label: buttonLabel,
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  void _signOut(BuildContext context) {
    ref.read(authProvider.notifier).logout();
  }

  void _showSignOutDialog(BuildContext context) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (ctx) => UJobAlertDialog(
        icon: HugeIcon(icon: HugeIcons.strokeRoundedLogout02, color: AppColors.error, size: 32.r),
        iconBgColor: AppColors.error,
        title: l10n.signOut,
        description: l10n.signOutConfirmation,
        cancelText: l10n.cancel,
        confirmText: l10n.signOut,
        confirmColor: AppColors.error,
        onConfirm: () {
          Navigator.pop(ctx);
          _signOut(context);
        },
      ),
    );
  }

  void _showSignOutAllDevicesDialog(BuildContext context) {
    final l10n = context.l10n;
    final pwdCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => UJobAlertDialog(
        icon: HugeIcon(icon: HugeIcons.strokeRoundedShield02, color: AppColors.error, size: 32.r),
        iconBgColor: AppColors.error,
        title: l10n.signOutAllDevices,
        description: l10n.signOutAllDevicesMsg,
        cancelText: l10n.cancel,
        confirmText: l10n.confirm,
        confirmColor: AppColors.error,
        onConfirm: () {
          Navigator.pop(ctx);
          _signOut(context);
        },
        child: UJobTextField(
          label: l10n.currentPassword,
          controller: pwdCtrl,
          isPassword: true,
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (ctx) => UJobAlertDialog(
        icon: HugeIcon(icon: HugeIcons.strokeRoundedDelete01, color: AppColors.error, size: 32.r),
        iconBgColor: AppColors.error,
        title: l10n.deleteAccountTitle,
        description: l10n.deleteAccountMsgEmployer,
        cancelText: l10n.cancel,
        confirmText: l10n.delete,
        confirmColor: AppColors.error,
        onConfirm: () {
          Navigator.pop(ctx);
          _signOut(context);
        },
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
      padding: EdgeInsets.fromLTRB(16.w, 32.h, 16.w, 8.h),
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
  final String? subtitle;
  const _SubSectionHeader(this.title, {this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppText.body.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 4.h),
            Text(
              subtitle!,
              style: AppText.caption.copyWith(color: AppColors.muted),
            ),
          ],
        ],
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
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool hideDivider;

  const _ToggleTile({
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.hideDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: AppText.body.copyWith(
                    color: AppColors.text,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    subtitle!,
                    style: AppText.caption.copyWith(color: AppColors.muted),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 16.w),
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
class _RadioTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final bool groupValue;
  final ValueChanged<bool?> onChanged;

  const _RadioTile({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5), width: 1)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Radio<bool>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: AppColors.primary,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppText.body.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: AppText.caption.copyWith(color: AppColors.muted, height: 1.4),
                    ),
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
class _SectionContainer extends StatelessWidget {
  final List<Widget> children;
  const _SectionContainer({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lg,
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
