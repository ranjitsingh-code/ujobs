import re

with open('lib/features/employer/employer_shell.dart', 'r') as f:
    text = f.read()

# Revert _indexFromPath
old_index = """    if (path.startsWith('/employer/profile')) return 4;
    if (path.startsWith('/employer/settings')) return 4;
    return 0;"""

new_index = """    if (path.startsWith('/employer/profile')) return 4;
    if (path.startsWith('/employer/settings')) return 4;
    return 0;"""

# Wait, keeping settings as return 4 is actually good so the bottom bar highlights it if they are pushed. But wait, if they are PUSHED on top of profile, the ShellRoute automatically highlights 4. I'll leave _indexFromPath as is.

# Revert onTap
old_tap = """            case 4:
              context.go('/employer/settings');
              break;"""

new_tap = """            case 4:
              context.go('/employer/profile');
              break;"""

text = text.replace(old_tap, new_tap)

with open('lib/features/employer/employer_shell.dart', 'w') as f:
    f.write(text)

# Now fix the Settings screen AppBar
with open('lib/features/employer/settings/employer_settings_screen.dart', 'r') as f:
    text = f.read()

old_appbar = """      appBar: UJobAppBar(
        title: l10n.settings,
        showBack: false,
        backgroundColor: AppColors.surface,
      ),"""

new_appbar = """      appBar: UJobAppBar(
        title: l10n.settings,
        showBack: true,
        backgroundColor: AppColors.surface,
      ),"""

text = text.replace(old_appbar, new_appbar)

with open('lib/features/employer/settings/employer_settings_screen.dart', 'w') as f:
    f.write(text)

# Now wire the Settings button in the Company Profile Screen
with open('lib/features/employer/company/company_profile_screen.dart', 'r') as f:
    text = f.read()

old_settings_btn = """              // Settings Button
              IconButton(
                onPressed: () {},
                tooltip: 'Settings',"""

new_settings_btn = """              // Settings Button
              IconButton(
                onPressed: () => context.push('/employer/settings'),
                tooltip: 'Settings',"""

text = text.replace(old_settings_btn, new_settings_btn)

with open('lib/features/employer/company/company_profile_screen.dart', 'w') as f:
    f.write(text)

