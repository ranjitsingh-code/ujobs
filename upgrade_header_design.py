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
    final percentCompleted = (completeness * 100).toInt();
    final percentLeft = 100 - percentCompleted;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.xl,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left side: Avatar
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 72.r,
                    height: 72.r,
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
                              style: AppText.heading2.copyWith(color: AppColors.white),
                            ),
                          ),
                  ),
                  Positioned(
                    bottom: -4.r,
                    right: -4.r,
                    child: GestureDetector(
                      onTap: onEditLogo,
                      child: Container(
                        width: 28.r,
                        height: 28.r,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border, width: 2),
                        ),
                        child: Center(
                          child: Icon(Icons.camera_alt_outlined, size: 14.r, color: AppColors.primary),
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
                            style: AppText.heading3.copyWith(color: AppColors.text2),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (completeness == 1.0) ...[
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.all(2.r),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedTick02,
                              color: AppColors.white,
                              size: 14.r,
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
                              HugeIcon(icon: HugeIcons.strokeRoundedUserGroup, color: AppColors.muted, size: 14.r),
                              SizedBox(width: 4.w),
                              Text(company.size!, style: AppText.caption.copyWith(color: AppColors.muted)),
                            ],
                          ),
                        if (company.city != null && company.country != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              HugeIcon(icon: HugeIcons.strokeRoundedLocation01, color: AppColors.muted, size: 14.r),
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
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: completeness == 1.0 ? AppColors.success.withValues(alpha: 0.05) : AppColors.bg,
              borderRadius: AppRadius.lg,
              border: Border.all(color: completeness == 1.0 ? AppColors.success.withValues(alpha: 0.2) : AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      completeness == 1.0 ? 'Profile Verified' : 'Profile Completeness',
                      style: AppText.bodyBold.copyWith(color: completeness == 1.0 ? AppColors.success : AppColors.text2),
                    ),
                    Text(
                      completeness == 1.0 ? '100%' : '${percentLeft}% left',
                      style: AppText.caption.copyWith(
                        color: completeness == 1.0 ? AppColors.success : AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                ClipRRect(
                  borderRadius: AppRadius.pill,
                  child: LinearProgressIndicator(
                    value: completeness,
                    backgroundColor: completeness == 1.0 ? AppColors.success.withValues(alpha: 0.2) : AppColors.border,
                    color: completeness == 1.0 ? AppColors.success : AppColors.primary,
                    minHeight: 6.h,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatefulWidget"""

text = pattern.sub(new_header, text)

# Remove the padding from CompanyProfileScreenState.build that wraps the accordion since we put margin on the header now.
# We actually just want to keep the padding for the accordion but we already have `Padding(padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h), child: Column(...)` around the accordions. That is fine, we just want to change `vertical: 24.h` to `0` or `bottom: 24.h` so we don't have double padding.
old_accordion_padding = """            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),"""
new_accordion_padding = """            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),"""
text = text.replace(old_accordion_padding, new_accordion_padding)

with open('lib/features/employer/company/company_profile_screen.dart', 'w') as f:
    f.write(text)
