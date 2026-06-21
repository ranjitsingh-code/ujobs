import re

with open('lib/features/employer/settings/employer_settings_screen.dart', 'r') as f:
    text = f.read()

# Let's replace the build method of _EmpSettingsState
old_build = """  @override
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
  }"""

new_build = """  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: AppColors.surface, // Clean white background for settings
      appBar: UJobAppBar(
        title: l10n.settings,
        showBack: false,
        backgroundColor: AppColors.surface,
      ),
      body: ListView(
        padding: EdgeInsets.only(bottom: 120.h),
        children: [
          _SectionHeader('ACCOUNT'),
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
            hideDivider: true,
          ),
          
          _SectionHeader('COMPANY'),
          _NavTile(
            label: l10n.editCompanyProfile,
            onTap: () => context.push('/employer/profile'),
          ),
          _NavTile(label: l10n.privacySettings, onTap: () {}),
          _ToggleTile(
            label: l10n.contactVisibility,
            value: _contactVisibility,
            onChanged: (v) => setState(() => _contactVisibility = v),
            hideDivider: true,
          ),
          
          _SectionHeader('NOTIFICATIONS'),
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
            hideDivider: true,
          ),
          
          _SectionHeader('PREFERENCES'),
          _NavTile(
            label: l10n.appLanguage,
            subtitle: locale.languageCode == 'en' ? 'English' : 'العربية',
            onTap: () => _showLanguageSheet(context),
          ),
          _NavTile(label: 'Timezone', subtitle: 'Europe / London', onTap: () {}),
          _NavTile(label: 'Date Format', subtitle: 'DD/MM/YYYY', onTap: () {}, hideDivider: true),
          
          _SectionHeader('ACCOUNT DATA'),
          _NavTile(label: 'Active Sessions', onTap: () {}),
          _NavTile(label: 'Download Account Data', onTap: () {}),
          _NavTile(label: 'Activity Log', onTap: () {}),
          _NavTile(
            label: l10n.deleteAccount,
            textColor: AppColors.error,
            onTap: () => _showDeleteDialog(context),
          ),
          _NavTile(
            label: l10n.signOut,
            textColor: AppColors.error,
            onTap: () => _signOut(context),
            hideDivider: true,
          ),
        ],
      ),
    );
  }"""

text = text.replace(old_build, new_build)

# We need to update _SectionHeader, _NavTile, _ToggleTile to match the sleek design in screenshot
old_components = """class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 8.h),
      child: Text(
        title.toUpperCase(),
        style: AppText.caption.copyWith(
          color: AppColors.muted,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
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

  const _NavTile({
    required this.label,
    this.subtitle,
    this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: AppText.body.copyWith(
          color: textColor ?? AppColors.text,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!, style: AppText.caption.copyWith(color: AppColors.muted))
          : null,
      trailing: const HugeIcon(
        icon: HugeIcons.strokeRoundedArrowRight01,
        color: AppColors.muted,
      ),
      onTap: onTap,
    );
  }
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
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(
        label,
        style: AppText.body.copyWith(
          color: AppColors.text,
          fontWeight: FontWeight.w500,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }
}"""

new_components = """class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.bg, // Light gray background for section headers
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
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
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
}"""

text = text.replace(old_components, new_components)

with open('lib/features/employer/settings/employer_settings_screen.dart', 'w') as f:
    f.write(text)
