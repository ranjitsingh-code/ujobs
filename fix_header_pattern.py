import re

with open('lib/features/employer/company/company_profile_screen.dart', 'r') as f:
    text = f.read()

# 1. Replace RadialGradient with AppColors.authGradient
old_gradient = """      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0.8, -0.5),
          radius: 1.5,
          colors: [
            AppColors.primaryLight,
            AppColors.primary,
          ],
        ),
      ),"""

new_gradient = """      decoration: const BoxDecoration(
        gradient: AppColors.authGradient,
      ),"""

text = text.replace(old_gradient, new_gradient)

# 2. Replace the Settings button pill with the Dashboard pattern IconButton
old_settings_button = """              // Settings Button
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.pill,
                    border: Border.all(color: AppColors.white.withValues(alpha: 0.3)),
                    color: AppColors.white.withValues(alpha: 0.1),
                  ),
                  child: Text(
                    'Settings',
                    style: AppText.caption.copyWith(color: AppColors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),"""

new_settings_button = """              // Settings Button
              IconButton(
                onPressed: () {},
                tooltip: 'Settings',
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surface.withValues(alpha: 0.12),
                  fixedSize: Size(44.r, 44.r),
                ),
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedSettings01,
                  color: AppColors.surface,
                  size: 23.r,
                ),
              ),"""

text = text.replace(old_settings_button, new_settings_button)

with open('lib/features/employer/company/company_profile_screen.dart', 'w') as f:
    f.write(text)
