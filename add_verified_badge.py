import re

with open('lib/features/employer/company/company_profile_screen.dart', 'r') as f:
    text = f.read()

old_name_text = """          SizedBox(height: 16.h),
          Text(
            company.name,
            style: AppText.heading2.copyWith(color: AppColors.text2),
          ),"""

new_name_text = """          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                company.name,
                style: AppText.heading2.copyWith(color: AppColors.text2),
              ),
              if (completeness == 1.0) ...[
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.all(2.r),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedTick02,
                    color: AppColors.white,
                    size: 16.r,
                  ),
                ),
              ],
            ],
          ),"""

text = text.replace(old_name_text, new_name_text)

with open('lib/features/employer/company/company_profile_screen.dart', 'w') as f:
    f.write(text)
