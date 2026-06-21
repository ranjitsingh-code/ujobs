import re

with open('lib/features/employer/company/company_profile_screen.dart', 'r') as f:
    text = f.read()

pattern = re.compile(r"class CompanyProfileHeader extends StatelessWidget \{[\s\S]*?\n\}\n\nclass _SectionCard extends StatefulWidget", re.MULTILINE)

new_header = """class CompanyProfileHeader extends StatelessWidget {
  final CompanyProfile company;
  final double completeness;
  final VoidCallback onEditLogo;
  const CompanyProfileHeader({super.key, required this.company, required this.completeness, required this.onEditLogo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side: Avatar
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 80.r,
                    height: 80.r,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: company.logo != null && company.logo!.isNotEmpty
                        ? (company.logo!.startsWith('http') 
                            ? Image.network(company.logo!, fit: BoxFit.cover)
                            : Image.file(File(company.logo!), fit: BoxFit.cover))
                        : Center(
                            child: Text(
                              company.name.isNotEmpty ? company.name[0].toUpperCase() : 'A',
                              style: AppText.heading1.copyWith(color: AppColors.white),
                            ),
                          ),
                  ),
                  Positioned(
                    bottom: -4.r,
                    right: -4.r,
                    child: GestureDetector(
                      onTap: onEditLogo,
                      child: Container(
                        width: 32.r,
                        height: 32.r,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border, width: 2),
                        ),
                        child: Center(
                          child: Icon(Icons.camera_alt_outlined, size: 16.r, color: AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 16.w),
              // Right side: Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            company.name,
                            style: AppText.heading2.copyWith(color: AppColors.text2),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
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
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      company.industry?.isNotEmpty == true ? company.industry! : 'Industry not set',
                      style: AppText.bodyMd.copyWith(
                        color: company.industry?.isNotEmpty == true ? AppColors.text2 : AppColors.muted2,
                        fontStyle: company.industry?.isNotEmpty == true ? FontStyle.normal : FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 12.w,
                      runSpacing: 4.h,
                      children: [
                        if (company.size != null && company.size!.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              HugeIcon(icon: HugeIcons.strokeRoundedUserGroup, color: AppColors.muted, size: 16.r),
                              SizedBox(width: 4.w),
                              Text(company.size!, style: AppText.caption.copyWith(color: AppColors.muted)),
                            ],
                          ),
                        if (company.city != null && company.country != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              HugeIcon(icon: HugeIcons.strokeRoundedLocation01, color: AppColors.muted, size: 16.r),
                              SizedBox(width: 4.w),
                              Text('${company.city}, ${company.country}', style: AppText.caption.copyWith(color: AppColors.muted)),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          // Progress Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                completeness == 1.0 ? '100% Profile Complete' : 'Profile Completeness: ${(completeness * 100).toInt()}%',
                style: AppText.label.copyWith(color: completeness == 1.0 ? AppColors.success : AppColors.text2),
              ),
              if (completeness < 1.0)
                Text(
                  'Needs attention',
                  style: AppText.caption.copyWith(color: AppColors.warning),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: AppRadius.pill,
            child: LinearProgressIndicator(
              value: completeness,
              backgroundColor: AppColors.border,
              color: completeness == 1.0 ? AppColors.success : AppColors.primary,
              minHeight: 6.h,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatefulWidget"""

text = pattern.sub(new_header, text)

with open('lib/features/employer/company/company_profile_screen.dart', 'w') as f:
    f.write(text)
