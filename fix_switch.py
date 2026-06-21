with open('lib/features/employer/company/company_profile_screen.dart', 'r') as f:
    text = f.read()

text = text.replace("activeColor: AppColors.primary, activeThumbColor: AppColors.primary,", "activeColor: AppColors.primary, activeTrackColor: AppColors.primaryLight,")
# The previous replace added activeThumbColor, but Switch actually deprecated activeColor.
# Wait, Switch has `activeColor` which is deprecated in newer Flutter versions in favor of `activeThumbColor`.
# Let's just remove the deprecated flag completely to avoid warnings.
text = text.replace("activeColor: AppColors.primary, activeTrackColor: AppColors.primaryLight,", "activeTrackColor: AppColors.primaryLight,")

with open('lib/features/employer/company/company_profile_screen.dart', 'w') as f:
    f.write(text)
