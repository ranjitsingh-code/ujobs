import re

with open('lib/features/employer/company/company_profile_screen.dart', 'r') as f:
    text = f.read()

pattern = r"                  SizedBox\(height: 40\.h\),\n                \],\n              \),\n            \),\n          \],\n        \),\n      \),\n    \);\n  \}"

replacement = """                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ],
        ),
      ),
      Positioned(
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
                  color: AppColors.text1.withValues(alpha: 0.05),
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

text = re.sub(pattern, replacement, text)

with open('lib/features/employer/company/company_profile_screen.dart', 'w') as f:
    f.write(text)
