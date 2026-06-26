import re

with open('lib/features/shared/settings/settings_screen.dart', 'r') as f:
    content = f.read()

orig_about = """              _NavTile(
                label: 'About UJobs',
                subtitle: 'Connecting talented professionals with their dream opportunities. Thousands of jobs across all industries.',
                onTap: () {},
              ),"""
new_about = """              _NavTile(
                label: 'About UJobs',
                subtitle: 'Connecting talented professionals with their dream opportunities. Thousands of jobs across all industries.',
                onTap: () => context.push('/about-us'),
              ),"""
content = content.replace(orig_about, new_about)

orig_privacy = """              _NavTile(
                label: 'Privacy Policy',
                subtitle: 'Read how we handle your data',
                onTap: () {},
              ),"""
new_privacy = """              _NavTile(
                label: 'Privacy Policy',
                subtitle: 'Read how we handle your data',
                onTap: () => context.push('/privacy-policy'),
              ),"""
content = content.replace(orig_privacy, new_privacy)

orig_terms = """              _NavTile(
                label: 'Terms of Use',
                subtitle: 'Read our terms and conditions',
                showBorder: false,
                onTap: () {},
              ),"""
new_terms = """              _NavTile(
                label: 'Terms of Use',
                subtitle: 'Read our terms and conditions',
                showBorder: false,
                onTap: () => context.push('/terms-and-conditions'),
              ),"""
content = content.replace(orig_terms, new_terms)

orig_socials = """              _NavTile(
                label: 'Social Media',
                subtitle: 'Follow us on Facebook, X, LinkedIn, and Instagram',
                onTap: () {},
              ),"""
new_socials = """              _NavTile(
                label: 'Social Media',
                subtitle: 'Follow us on Facebook, X, LinkedIn, and Instagram',
                onTap: () => _showSocialsModal(context),
              ),"""
content = content.replace(orig_socials, new_socials)

# Add the _showSocialsModal and _socialRow method to SettingsScreen
orig_helpers = "  // --- Helpers ---"
new_helpers = """  // --- Helpers ---
  void _showSocialsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, MediaQuery.of(context).padding.bottom + 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Follow Us', style: AppText.heading2),
                  IconButton(
                    icon: HugeIcon(icon: HugeIcons.strokeRoundedCancel01, color: AppColors.text, size: 24.r),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              _socialRow(HugeIcons.strokeRoundedLinkedin01, 'LinkedIn', AppColors.primary, 'https://linkedin.com/company/ujobs'),
              SizedBox(height: 16.h),
              _socialRow(HugeIcons.strokeRoundedFacebook01, 'Facebook', const Color(0xFF1877F2), 'https://facebook.com/ujobs'),
              SizedBox(height: 16.h),
              _socialRow(HugeIcons.strokeRoundedInstagram, 'Instagram', const Color(0xFFE1306C), 'https://instagram.com/ujobs'),
              SizedBox(height: 16.h),
              _socialRow(HugeIcons.strokeRoundedNewTwitter, 'X (Twitter)', AppColors.text, 'https://x.com/ujobs'),
            ],
          ),
        );
      },
    );
  }

  Widget _socialRow(List<List<dynamic>> icon, String label, Color brandColor, String url) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderLight),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            HugeIcon(icon: icon, color: brandColor, size: 24.r),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(label, style: AppText.bodyBold),
            ),
            HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, color: AppColors.muted, size: 20.r),
          ],
        ),
      ),
    );
  }
"""
content = content.replace(orig_helpers, new_helpers)

with open('lib/features/shared/settings/settings_screen.dart', 'w') as f:
    f.write(content)
