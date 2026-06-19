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
import '../../../core/widgets/ujob_app_bar.dart';

import '../../../core/providers/locale_provider.dart';
import '../../../core/utils/l10n_extensions.dart';

class EmployerSettingsScreen extends ConsumerStatefulWidget {
  const EmployerSettingsScreen({super.key});

  @override
  ConsumerState<EmployerSettingsScreen> createState() => _EmpSettingsState();
}

class _EmpSettingsState extends ConsumerState<EmployerSettingsScreen> {
  bool _contactVisibility = true;
  bool _newApplicants = true;
  bool _applicationUpdates = true;
  bool _pushNotifs = true;
  bool _twoFa = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: UJobAppBar(title: l10n.settings),
      body: ListView(
        children: [
          _SectionHeader(l10n.accountSection),
          _NavTile(label: l10n.editPersonalInfo, onTap: () {}),
          _NavTile(
            label: l10n.changePassword,
            onTap: () => _showChangePasswordSheet(context),
          ),
          _NavTile(
            label: l10n.changeEmail,
            onTap: () => _showChangeFieldSheet(
              context,
              l10n.email,
              TextInputType.emailAddress,
            ),
          ),
          _NavTile(
            label: l10n.changePhone,
            onTap: () =>
                _showChangeFieldSheet(context, l10n.phone, TextInputType.phone),
          ),
          _ToggleTile(
            label: l10n.twoFactorAuth,
            value: _twoFa,
            onChanged: (v) => setState(() => _twoFa = v),
          ),
          _SectionHeader(l10n.companySection),
          _NavTile(
            label: l10n.editCompanyProfile,
            onTap: () => context.push('/employer/profile'),
          ),
          _NavTile(label: l10n.privacySettings, onTap: () {}),
          _ToggleTile(
            label: l10n.contactVisibility,
            value: _contactVisibility,
            onChanged: (v) => setState(() => _contactVisibility = v),
          ),
          _SectionHeader(l10n.notificationsSection),
          _ToggleTile(
            label: l10n.newApplicantsNotif,
            value: _newApplicants,
            onChanged: (v) => setState(() => _newApplicants = v),
          ),
          _ToggleTile(
            label: l10n.applicationUpdatesNotif,
            value: _applicationUpdates,
            onChanged: (v) => setState(() => _applicationUpdates = v),
          ),
          _ToggleTile(
            label: l10n.pushNotifications,
            value: _pushNotifs,
            onChanged: (v) => setState(() => _pushNotifs = v),
          ),
          _SectionHeader(l10n.languageSection),
          _NavTile(
            label: l10n.appLanguage,
            subtitle: locale.languageCode == 'en' ? 'English' : 'العربية',
            onTap: () => _showLanguageSheet(context),
          ),
          _SectionHeader(l10n.accountSection),
          _NavTile(
            label: l10n.deleteAccount,
            textColor: AppColors.error,
            onTap: () => _showDeleteDialog(context),
          ),
          _NavTile(
            label: l10n.signOut,
            textColor: AppColors.error,
            onTap: () => _signOut(context),
          ),
          const SizedBox(height: 32),
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
            UJobTextField(
              label: l10n.newPassword,
              controller: newCtrl,
              isPassword: true,
            ),
            UJobTextField(
              label: l10n.confirmNewPassword,
              controller: confirmCtrl,
              isPassword: true,
            ),
            UJobButton(
              label: l10n.updatePassword,
              onTap: () => Navigator.pop(ctx),
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
            Text('Change $fieldName', style: AppText.heading3),
            const SizedBox(height: 20),
            UJobTextField(
              label: 'New $fieldName',
              controller: ctrl,
              keyboardType: type,
            ),
            UJobButton(label: l10n.confirm, onTap: () => Navigator.pop(ctx)),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.deleteAccount),
        content: Text(l10n.deleteAccountMsgEmployer),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _signOut(BuildContext context) {
    ref.read(authProvider.notifier).logout();
    context.go('/role-picker');
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
    color: AppColors.bg,
    child: Text(
      title,
      style: AppText.overline.copyWith(
        color: AppColors.muted2,
        letterSpacing: 1.2,
      ),
    ),
  );
}

class _NavTile extends StatelessWidget {
  final String label;
  final String? subtitle;
  final Color? textColor;
  final VoidCallback onTap;

  const _NavTile({
    required this.label,
    this.subtitle,
    this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppText.bodyMd.copyWith(
                    color: textColor ?? AppColors.text,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppText.small.copyWith(color: AppColors.muted),
                  ),
                ],
              ],
            ),
          ),
          if (textColor == null)
            const HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight01,
              color: AppColors.muted2,
              size: 20,
            ),
        ],
      ),
    ),
  );
}

class _ToggleTile extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    decoration: const BoxDecoration(
      color: AppColors.surface,
      border: Border(bottom: BorderSide(color: AppColors.borderLight)),
    ),
    child: Row(
      children: [
        Expanded(child: Text(label, style: AppText.bodyMd)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.empPrimary,
          activeTrackColor: AppColors.empPrimary.withValues(alpha: 0.5),
        ),
      ],
    ),
  );
}
