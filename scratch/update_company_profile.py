import re

with open('lib/features/seeker/company/seeker_company_profile_screen.dart', 'r') as f:
    content = f.read()

# 1. Add "Verified" badge next to company name
orig_title = """                              Text(widget.company.name, style: AppText.titleMd),"""
new_title = """                              Row(
                                children: [
                                  Text(widget.company.name, style: AppText.titleMd),
                                  if (widget.company.isVerified == true) ...[
                                    SizedBox(width: 8.w),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                      decoration: BoxDecoration(
                                        color: AppColors.successBg,
                                        borderRadius: BorderRadius.circular(4.r),
                                      ),
                                      child: Row(
                                        children: [
                                          HugeIcon(
                                            icon: HugeIcons.strokeRoundedCheckmarkBadge01,
                                            color: AppColors.success,
                                            size: 12.r,
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            'Verified',
                                            style: AppText.small.copyWith(
                                              color: AppColors.success,
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),"""
content = content.replace(orig_title, new_title)

# 2. Update _buildAboutTab to show the "Work Culture" block and containers
orig_about = """  Widget _buildAboutTab() {
    return ListView(
      padding: EdgeInsets.all(20.r),
      children: [
        Text(context.l10n.aboutCompany, style: AppText.heading3),
        SizedBox(height: 12.h),
        Text(
          widget.company.description ?? context.l10n.noDescriptionAvailable,
          style: AppText.body.copyWith(color: AppColors.text2, height: 1.5),
        ),
        SizedBox(height: 24.h),
        if (widget.company.industry != null) ...[
          Text(context.l10n.industryLabel, style: AppText.heading3),
          SizedBox(height: 8.h),
          Text(
            widget.company.industry!,
            style: AppText.body.copyWith(color: AppColors.text2),
          ),
          SizedBox(height: 24.h),
        ],
        if (widget.company.size != null) ...[
          Text(context.l10n.companySize, style: AppText.heading3),
          SizedBox(height: 8.h),
          Text(
            widget.company.size!,
            style: AppText.body.copyWith(color: AppColors.text2),
          ),
        ],
      ],
    );
  }"""
new_about = """  Widget _buildAboutTab() {
    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 120.h),
      children: [
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
              Text(context.l10n.aboutCompany, style: AppText.heading3),
              SizedBox(height: 12.h),
              Text(
                widget.company.description ?? context.l10n.noDescriptionAvailable,
                style: AppText.body.copyWith(color: AppColors.text2, height: 1.5),
              ),
            ],
          ),
        ),
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
              Text('Work Culture', style: AppText.heading3),
              SizedBox(height: 16.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Team Size',
                          style: AppText.small.copyWith(color: AppColors.muted),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          widget.company.size ?? 'N/A',
                          style: AppText.bodyBold,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Founded',
                          style: AppText.small.copyWith(color: AppColors.muted),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          widget.company.founded ?? 'N/A',
                          style: AppText.bodyBold,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }"""
content = content.replace(orig_about, new_about)

with open('lib/features/seeker/company/seeker_company_profile_screen.dart', 'w') as f:
    f.write(content)
