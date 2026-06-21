import re

with open('lib/features/employer/company/company_profile_screen.dart', 'r') as f:
    text = f.read()

old_subtitle_block = """                    if (subtitle.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        style: AppText.caption.copyWith(color: AppColors.white.withValues(alpha: 0.8)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (location.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        location,
                        style: AppText.caption.copyWith(color: AppColors.white.withValues(alpha: 0.8)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],"""

new_subtitle_block = """                    SizedBox(height: 4.h),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: AppText.caption.copyWith(color: AppColors.white.withValues(alpha: 0.8)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      Text(
                        'Industry & size not set',
                        style: AppText.caption.copyWith(color: AppColors.white.withValues(alpha: 0.5), fontStyle: FontStyle.italic),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    
                    SizedBox(height: 2.h),
                    if (location.isNotEmpty)
                      Text(
                        location,
                        style: AppText.caption.copyWith(color: AppColors.white.withValues(alpha: 0.8)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      Text(
                        'Location not set',
                        style: AppText.caption.copyWith(color: AppColors.white.withValues(alpha: 0.5), fontStyle: FontStyle.italic),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),"""

text = text.replace(old_subtitle_block, new_subtitle_block)

with open('lib/features/employer/company/company_profile_screen.dart', 'w') as f:
    f.write(text)
