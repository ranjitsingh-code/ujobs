import re

with open('lib/features/seeker/company/seeker_company_profile_screen.dart', 'r') as f:
    content = f.read()

# 1. Remove Open Positions from Work Culture
orig_open_positions_culture = """              SizedBox(height: 16.h),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Open Positions',
                    style: AppText.small.copyWith(color: AppColors.muted),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${openPositionsCount} Positions available',
                    style: AppText.bodyBold.copyWith(
                      color: AppColors.seekPrimary,
                    ),
                  ),
                ],
              ),"""
content = content.replace(orig_open_positions_culture, "")

# 2. Remove "Follow Us" social buttons from bottom of About Tab
orig_about_socials = """        if (widget.company.linkedinUrl != null ||
            widget.company.facebookUrl != null)
          Container(
            padding: EdgeInsets.all(16.r),
            margin: EdgeInsets.only(bottom: 24.h),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Follow us', style: AppText.heading3),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    if (widget.company.linkedinUrl != null)
                      _socialBtn(
                        HugeIcons.strokeRoundedLinkedin01,
                        'LinkedIn',
                        AppColors.primary,
                      ),
                    if (widget.company.linkedinUrl != null &&
                        widget.company.facebookUrl != null)
                      SizedBox(width: 12.w),
                    if (widget.company.facebookUrl != null)
                      _socialBtn(
                        HugeIcons.strokeRoundedFacebook01,
                        'Facebook',
                        const Color(0xFF1877F2),
                      ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _socialBtn(
    List<List<dynamic>> icon,
    String platform,
    Color brandColor,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(icon: icon, color: brandColor, size: 20.r),
            SizedBox(width: 8.w),
            Text(
              platform,
              style: AppText.bodyBold.copyWith(color: AppColors.text),
            ),
          ],
        ),
      ),
    );
  }"""
new_about_socials = """      ],
    );
  }"""
content = content.replace(orig_about_socials, new_about_socials)

with open('lib/features/seeker/company/seeker_company_profile_screen.dart', 'w') as f:
    f.write(content)
