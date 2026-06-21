import re

with open('lib/features/employer/company/company_profile_screen.dart', 'r') as f:
    text = f.read()

# 1. Remove extendBodyBehindAppBar and transparent background
old_scaffold_start = """    return Scaffold(
      backgroundColor: AppColors.bg,
      extendBodyBehindAppBar: true,
      appBar: UJobAppBar(
        title: 'Account',
        showBack: false,
        backgroundColor: Colors.transparent,"""

new_scaffold_start = """    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: UJobAppBar(
        title: 'Account',
        showBack: false,
        backgroundColor: AppColors.bg,"""

text = text.replace(old_scaffold_start, new_scaffold_start)

# 2. Adjust the top padding back to normal since we aren't extending behind the app bar anymore
old_top_padding = "SizedBox(height: MediaQuery.of(context).padding.top + 80.h),"
new_top_padding = "SizedBox(height: 24.h),"

text = text.replace(old_top_padding, new_top_padding)

with open('lib/features/employer/company/company_profile_screen.dart', 'w') as f:
    f.write(text)
