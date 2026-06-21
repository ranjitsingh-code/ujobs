import re

with open('lib/features/employer/settings/employer_settings_screen.dart', 'r') as f:
    text = f.read()

# Replace SECURITY section
old_security = """          // ================= SECURITY =================
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
          ),"""

new_security = """          // ================= SECURITY =================
          _SectionHeader('SECURITY'),
          _NavTile(
            label: l10n.changePassword,
            subtitle: 'Use a strong password to protect your account',
            onTap: () => _showChangePasswordSheet(context),
          ),
          _NavTile(
            label: l10n.changeEmail,
            subtitle: 'Update your login email address',
            onTap: () => _showChangeFieldSheet(context, l10n.email, TextInputType.emailAddress),
          ),
          _NavTile(
            label: l10n.changePhone,
            subtitle: 'Update your contact phone number',
            onTap: () => _showChangeFieldSheet(context, l10n.phone, TextInputType.phone),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
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
                              style: AppText.bodySm.copyWith(
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
          ),"""

text = text.replace(old_security, new_security)

with open('lib/features/employer/settings/employer_settings_screen.dart', 'w') as f:
    f.write(text)
