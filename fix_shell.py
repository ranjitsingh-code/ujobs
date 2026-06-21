import re

with open('lib/features/employer/employer_shell.dart', 'r') as f:
    text = f.read()

# Update _indexFromPath
old_index = """    if (path.startsWith('/employer/messages')) return 3;
    if (path.startsWith('/employer/profile')) return 4;
    return 0;"""

new_index = """    if (path.startsWith('/employer/messages')) return 3;
    if (path.startsWith('/employer/profile')) return 4;
    if (path.startsWith('/employer/settings')) return 4;
    return 0;"""

text = text.replace(old_index, new_index)

# Update onTap
old_tap = """            case 4:
              context.go('/employer/profile');
              break;"""

new_tap = """            case 4:
              context.go('/employer/settings');
              break;"""

text = text.replace(old_tap, new_tap)

# Update Account icon to be a user
old_icon = """          BottomNavigationBarItem(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedBuilding04,
              color: AppColors.muted2,
              size: 24,
            ),
            activeIcon: HugeIcon(
              icon: HugeIcons.strokeRoundedBuilding04,
              color: AppColors.primary,
              size: 24,
            ),
            label: 'Account',
          ),"""

new_icon = """          BottomNavigationBarItem(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedUser,
              color: AppColors.muted2,
              size: 24,
            ),
            activeIcon: HugeIcon(
              icon: HugeIcons.strokeRoundedUser,
              color: AppColors.primary,
              size: 24,
            ),
            label: 'Account',
          ),"""

text = text.replace(old_icon, new_icon)

with open('lib/features/employer/employer_shell.dart', 'w') as f:
    f.write(text)
