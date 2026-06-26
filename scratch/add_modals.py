import re

with open('lib/features/seeker/company/seeker_company_profile_screen.dart', 'r') as f:
    content = f.read()

# 1. Update Info Modal
orig_info = """          _infoRow(
            HugeIcons.strokeRoundedGlobal,
            'Website',
            widget.company.website ?? 'N/A',
          ),
        ],
      ),
    );
  }"""
new_info = """          _infoRow(
            HugeIcons.strokeRoundedGlobal,
            'Website',
            widget.company.website ?? 'N/A',
          ),
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
content = content.replace(orig_info, new_info)

# 2. Update Bottom Action Bar
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

with open('lib/features/seeker/company/seeker_company_profile_screen.dart', 'w') as f:
    f.write(content)

