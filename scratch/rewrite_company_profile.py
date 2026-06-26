import re

with open('lib/features/seeker/company/seeker_company_profile_screen.dart', 'r') as f:
    content = f.read()

# 1. Add "Open Positions" to Header (Under Location)
orig_location = """                                  Text(
                                    widget.company.location ?? 'Worldwide',
                                    style: AppText.small.copyWith(
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),"""
new_location = """                                  Text(
                                    widget.company.location ?? 'Worldwide',
                                    style: AppText.small.copyWith(
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6.h),
                              Row(
                                children: [
                                  HugeIcon(
                                    icon: HugeIcons.strokeRoundedBriefcase02,
                                    color: AppColors.seekPrimary,
                                    size: 12.r,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '${openPositionsCount} Open Positions',
                                    style: AppText.small.copyWith(
                                      color: AppColors.seekPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),"""
content = content.replace(orig_location, new_location)

# 2. Modify Info Modal to include Message Button at bottom
orig_info_modal = """          _infoRow(HugeIcons.strokeRoundedGlobal, 'Website', widget.company.website ?? 'N/A'),
        ],
      ),
    );
  }"""
new_info_modal = """          _infoRow(HugeIcons.strokeRoundedGlobal, 'Website', widget.company.website ?? 'N/A'),
          SizedBox(height: 32.h),
          UJobButton(
            label: 'Message Company',
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedMessage02,
              color: AppColors.seekPrimary,
              size: 20.r,
            ),
            color: AppColors.seekPrimary,
            outlined: true,
            onTap: () {
              Navigator.pop(context);
              UJobToast.info(
                context,
                'Not yet available',
                sub: 'You can only message the company after being shortlisted for an interview.',
              );
            },
          ),
        ],
      ),
    );
  }

  void _showSocialsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, MediaQuery.of(context).padding.bottom + 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Follow Us', style: AppText.heading2),
                  IconButton(
                    icon: HugeIcon(icon: HugeIcons.strokeRoundedCancel01, color: AppColors.text, size: 24.r),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              if (widget.company.linkedinUrl != null) ...[
                _socialRow(HugeIcons.strokeRoundedLinkedin01, 'LinkedIn', AppColors.primary, widget.company.linkedinUrl!),
                SizedBox(height: 16.h),
              ],
              if (widget.company.facebookUrl != null) ...[
                _socialRow(HugeIcons.strokeRoundedFacebook01, 'Facebook', const Color(0xFF1877F2), widget.company.facebookUrl!),
                SizedBox(height: 16.h),
              ],
              if (widget.company.linkedinUrl == null && widget.company.facebookUrl == null)
                Center(
                  child: Text(
                    'No social links provided.',
                    style: AppText.body.copyWith(color: AppColors.muted),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _socialRow(List<List<dynamic>> icon, String label, Color brandColor, String url) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderLight),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            HugeIcon(icon: icon, color: brandColor, size: 24.r),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(label, style: AppText.bodyBold),
            ),
            HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, color: AppColors.muted, size: 20.r),
          ],
        ),
      ),
    );
  }"""
content = content.replace(orig_info_modal, new_info_modal)


# 3. Change the bottom Action Bar to Follow Us (Left) and Website (Right)
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
                            label: context.l10n.website,
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedLink01,
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
                            label: 'Message',
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedMessage02,
                              color: AppColors.text,
                              size: 20.r,
                            ),
                            color: AppColors.text,
                            outlined: true,
                            onTap: () {
                              UJobToast.info(
                                context,
                                'Not yet available',
                                sub: 'You can only message the company after being shortlisted for an interview.',
                              );
                            },
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
                    child: Row(
                      children: [
                        Expanded(
                          child: UJobButton(
                            label: 'Follow Us',
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedUserAdd01,
                              color: AppColors.text,
                              size: 20.r,
                            ),
                            color: AppColors.text,
                            outlined: true,
                            onTap: () => _showSocialsModal(context),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: UJobButton(
                            label: context.l10n.website,
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedLink01,
                              color: AppColors.surface,
                              size: 20.r,
                            ),
                            gradient: AppColors.authGradient,
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                  ),"""
content = content.replace(orig_actions, new_actions)

# 4. Remove Open Positions from Work Culture
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
                    style: AppText.bodyBold.copyWith(color: AppColors.seekPrimary),
                  ),
                ],
              ),"""
content = content.replace(orig_open_positions_culture, "")

# 5. Remove "Follow Us" social buttons from bottom of About Tab
orig_about_socials = """        if (widget.company.linkedinUrl != null || widget.company.facebookUrl != null)
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

