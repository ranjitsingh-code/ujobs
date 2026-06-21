import re

with open('lib/features/employer/company/company_profile_screen.dart', 'r') as f:
    text = f.read()

# Restore UJobAppBar import
if "import '../../../core/widgets/ujob_app_bar.dart';" not in text:
    text = text.replace("import '../../../core/widgets/ujob_button.dart';", "import '../../../core/widgets/ujob_app_bar.dart';\nimport '../../../core/widgets/ujob_button.dart';")

# Re-add AppBar to Scaffold and extendBodyBehindAppBar
old_scaffold_start = """    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Container("""

new_scaffold_start = """    return Scaffold(
      backgroundColor: AppColors.bg,
      extendBodyBehindAppBar: true,
      appBar: UJobAppBar(
        title: 'Account',
        showBack: false,
        backgroundColor: Colors.transparent,
        rightWidget: GestureDetector(
          onTap: () {
            // TODO: Navigate to settings
          },
          child: Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: HugeIcon(icon: HugeIcons.strokeRoundedSettings01, color: AppColors.text2, size: 20.r),
          ),
        ),
      ),
      body: Container("""
text = text.replace(old_scaffold_start, new_scaffold_start)

# Remove the Positioned floating headers
old_positioned = r"""      Positioned\(\n        top: MediaQuery\.of\(context\)\.padding\.top \+ 16\.h,\n        left: 20\.w,\n        child: Text\('Account', style: AppText\.heading2\.copyWith\(color: AppColors\.text2\)\),\n      \),\n      Positioned\(\n        top: MediaQuery\.of\(context\)\.padding\.top \+ 12\.h,\n        right: 20\.w,\n        child: GestureDetector\([\s\S]*?child: HugeIcon\(icon: HugeIcons\.strokeRoundedSettings01, color: AppColors\.text2, size: 20\.r\),\n          \),\n        \),\n      \),\n    \],\n  \),\n\),\n\);\n\}"""

new_positioned = """    ],
  ),
),
);
}"""

text = re.sub(old_positioned, new_positioned, text)

# Adjust top padding for the content since we use extendBodyBehindAppBar
old_top_padding = "SizedBox(height: MediaQuery.of(context).padding.top + 40.h),"
new_top_padding = "SizedBox(height: MediaQuery.of(context).padding.top + 80.h),"
text = text.replace(old_top_padding, new_top_padding)

with open('lib/features/employer/company/company_profile_screen.dart', 'w') as f:
    f.write(text)
