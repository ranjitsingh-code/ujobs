import re

with open('lib/features/seeker/company/seeker_company_profile_screen.dart', 'r') as f:
    content = f.read()

# 1. Update the Info icon onPressed
orig_info_icon = """                              onPressed: () {
                                // Show company info sheet or tooltip
                              },"""

new_info_icon = """                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: AppColors.surface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                                  ),
                                  builder: (context) => _buildCompanyInfoModal(context),
                                );
                              },"""

content = content.replace(orig_info_icon, new_info_icon)

# 2. Add the modal builder method inside the class before _buildAboutTab
modal_method = """
  Widget _buildCompanyInfoModal(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, MediaQuery.of(context).padding.bottom + 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Company Details', style: AppText.heading2),
              IconButton(
                icon: HugeIcon(icon: HugeIcons.strokeRoundedCancel01, color: AppColors.text, size: 24.r),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          _infoRow(HugeIcons.strokeRoundedBuilding03, 'Industry', widget.company.industry ?? 'N/A'),
          SizedBox(height: 16.h),
          _infoRow(HugeIcons.strokeRoundedLocation01, 'Location', widget.company.location ?? 'Worldwide'),
          SizedBox(height: 16.h),
          _infoRow(HugeIcons.strokeRoundedUserMultiple, 'Team Size', widget.company.size ?? 'N/A'),
          SizedBox(height: 16.h),
          _infoRow(HugeIcons.strokeRoundedCalendar01, 'Founded', widget.company.founded ?? 'N/A'),
          SizedBox(height: 16.h),
          _infoRow(HugeIcons.strokeRoundedGlobal, 'Website', widget.company.website ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _infoRow(List<List<dynamic>> icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: HugeIcon(icon: icon, color: AppColors.muted, size: 20.r),
        ),
        SizedBox(width: 16.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppText.small.copyWith(color: AppColors.muted)),
            SizedBox(height: 2.h),
            Text(value, style: AppText.bodyBold),
          ],
        ),
      ],
    );
  }

"""
orig_about = "  Widget _buildAboutTab() {"
content = content.replace(orig_about, modal_method + orig_about)

# 3. Update the actions section (Remove follow button)
orig_actions = """                  // Actions Section
                  Container(
                    color: AppColors.surface,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 16.h,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: UJobButton(
                            label: context.l10n.follow,
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedUserAdd01,
                              color: AppColors.surface,
                              size: 20.r,
                            ),
                            gradient: AppColors.authGradient,
                            onTap: () {},
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: UJobButton(
                            label: context.l10n.website,
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedLink01,
                              color: AppColors.text,
                              size: 20.r,
                            ),
                            color: AppColors.text,
                            outlined: true,
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                  ),"""
new_actions = """                  // Actions Section
                  Container(
                    color: AppColors.surface,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 16.h,
                    ),
                    child: UJobButton(
                      label: context.l10n.website,
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedLink01,
                        color: AppColors.surface,
                        size: 20.r,
                      ),
                      gradient: AppColors.primaryGradient,
                      onTap: () {},
                    ),
                  ),"""
content = content.replace(orig_actions, new_actions)

# 4. Add "Follow us" to the _buildAboutTab
orig_culture = """                ],
              ),
            ],
          ),
        ),
      ],
    );
  }"""
new_culture = """                ],
              ),
            ],
          ),
        ),
        if (widget.company.linkedinUrl != null || widget.company.facebookUrl != null)
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
                      _socialBtn(HugeIcons.strokeRoundedLinkedin01, 'LinkedIn', AppColors.primary),
                    if (widget.company.linkedinUrl != null && widget.company.facebookUrl != null)
                      SizedBox(width: 12.w),
                    if (widget.company.facebookUrl != null)
                      _socialBtn(HugeIcons.strokeRoundedFacebook01, 'Facebook', const Color(0xFF1877F2)),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _socialBtn(List<List<dynamic>> icon, String platform, Color brandColor) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
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
  }
"""
content = content.replace(orig_culture, new_culture)

with open('lib/features/seeker/company/seeker_company_profile_screen.dart', 'w') as f:
    f.write(content)

