import re

with open('lib/features/shared/settings/settings_screen.dart', 'r') as f:
    content = f.read()

# I will find the delete account section, or right before LOG OUT
# `          // ================= ACCOUNT (Seeker only) =================`
orig_account = "          // ================= ACCOUNT (Seeker only) ================="

new_support = """          // ================= ABOUT & SUPPORT =================
          _SectionTitle('ABOUT & SUPPORT'),
          _SectionContainer(
            children: [
              _NavTile(
                label: 'About UJobs',
                subtitle: 'Connecting talented professionals with their dream opportunities. Thousands of jobs across all industries.',
                onTap: () {
                  // Show about page or modal
                },
              ),
              _NavTile(
                label: 'Contact Us',
                subtitle: 'Email: italycode89@gmail.com\\nPhone: 44 12 5689 7456\\n123 Business Street London. EC1A 1IBB United Kingdom',
                onTap: () {
                  // Launch email or phone
                },
              ),
              _NavTile(
                label: 'Social Media',
                subtitle: 'Follow us on Facebook, X, LinkedIn, and Instagram',
                onTap: () {
                  // Launch social links
                },
              ),
              _NavTile(
                label: 'Privacy Policy',
                subtitle: 'Read how we handle your data',
                onTap: () {
                  // Launch URL
                },
              ),
              _NavTile(
                label: 'Terms of Use',
                subtitle: 'Read our terms and conditions',
                showBorder: false,
                onTap: () {
                  // Launch URL
                },
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // ================= ACCOUNT (Seeker only) ================="""

content = content.replace(orig_account, new_support)

with open('lib/features/shared/settings/settings_screen.dart', 'w') as f:
    f.write(content)

