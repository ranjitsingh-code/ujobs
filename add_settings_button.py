import re

with open('lib/features/employer/company/company_profile_screen.dart', 'r') as f:
    text = f.read()

old_positioned_back = """      Positioned(
        top: MediaQuery.of(context).padding.top + 12.h,
        left: 20.w,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.8),
              borderRadius: AppRadius.pill,
              border: Border.all(color: AppColors.white.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.text2.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: AppColors.text2, size: 20.r),
                SizedBox(width: 6.w),
                Text('Account', style: AppText.bodyMd.copyWith(color: AppColors.text2, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    ],
  ),
),
);
}"""

new_positioned_back_and_settings = """      Positioned(
        top: MediaQuery.of(context).padding.top + 12.h,
        left: 20.w,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.8),
              borderRadius: AppRadius.pill,
              border: Border.all(color: AppColors.white.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.text2.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: AppColors.text2, size: 20.r),
                SizedBox(width: 6.w),
                Text('Account', style: AppText.bodyMd.copyWith(color: AppColors.text2, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
      Positioned(
        top: MediaQuery.of(context).padding.top + 12.h,
        right: 20.w,
        child: GestureDetector(
          onTap: () {
            // TODO: Navigate to settings or show settings options
          },
          child: Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.8),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.text2.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: HugeIcon(icon: HugeIcons.strokeRoundedSettings01, color: AppColors.text2, size: 20.r),
          ),
        ),
      ),
    ],
  ),
),
);
}"""

text = text.replace(old_positioned_back, new_positioned_back_and_settings)

with open('lib/features/employer/company/company_profile_screen.dart', 'w') as f:
    f.write(text)
