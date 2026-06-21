import re

with open('lib/features/employer/company/company_profile_screen.dart', 'r') as f:
    text = f.read()

# 1. Completely rewrite the CompanyProfileHeader class
old_header_pattern = re.compile(r"class CompanyProfileHeader extends StatelessWidget \{[\s\S]*?\n\}\n\nclass _SectionCard extends StatefulWidget", re.MULTILINE)

new_header = """class CompanyProfileHeader extends StatelessWidget {
  final CompanyProfile company;
  final double completeness;
  final VoidCallback onEditLogo;
  const CompanyProfileHeader({super.key, required this.company, required this.completeness, required this.onEditLogo});

  @override
  Widget build(BuildContext context) {
    final percentCompleted = (completeness * 100).toInt();

    // Construct the subtitle (Industry · Size)
    List<String> subtitleParts = [];
    if (company.industry != null && company.industry!.isNotEmpty) subtitleParts.add(company.industry!);
    if (company.size != null && company.size!.isNotEmpty) subtitleParts.add(company.size!);
    final subtitle = subtitleParts.join(' · ');

    // Construct location
    String location = '';
    if (company.city != null && company.city!.isNotEmpty && company.country != null && company.country!.isNotEmpty) {
      location = '${company.city}, ${company.country}';
    } else if (company.city != null && company.city!.isNotEmpty) {
      location = company.city!;
    } else if (company.country != null && company.country!.isNotEmpty) {
      location = company.country!;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0.8, -0.5),
          radius: 1.5,
          colors: [
            AppColors.primaryLight,
            AppColors.primary,
          ],
        ),
      ),
      padding: EdgeInsets.fromLTRB(20.w, MediaQuery.of(context).padding.top + 24.h, 20.w, 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 72.r,
                    height: 72.r,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.xl,
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: company.logo != null && company.logo!.isNotEmpty
                        ? (company.logo!.startsWith('http') 
                            ? Image.network(company.logo!, fit: BoxFit.cover)
                            : Image.file(File(company.logo!), fit: BoxFit.cover))
                        : Center(
                            child: Text(
                              company.name.isNotEmpty ? company.name[0].toUpperCase() : 'A',
                              style: AppText.heading1.copyWith(color: AppColors.primary),
                            ),
                          ),
                  ),
                  Positioned(
                    bottom: -6.r,
                    right: -6.r,
                    child: GestureDetector(
                      onTap: onEditLogo,
                      child: Container(
                        width: 24.r,
                        height: 24.r,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: HugeIcon(icon: HugeIcons.strokeRoundedCamera01, size: 14.r, color: AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 16.w),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            company.name,
                            style: AppText.heading2.copyWith(color: AppColors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (completeness == 1.0) ...[
                          SizedBox(width: 6.w),
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedTick02,
                            color: AppColors.white,
                            size: 20.r,
                          ),
                        ],
                      ],
                    ),
                    if (subtitle.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        style: AppText.bodySm.copyWith(color: AppColors.white.withValues(alpha: 0.8)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (location.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        location,
                        style: AppText.bodySm.copyWith(color: AppColors.white.withValues(alpha: 0.8)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Settings Button
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.pill,
                    border: Border.all(color: AppColors.white.withValues(alpha: 0.3)),
                    color: AppColors.white.withValues(alpha: 0.1),
                  ),
                  child: Text(
                    'Settings',
                    style: AppText.bodySm.copyWith(color: AppColors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          // Progress Section
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.15),
              borderRadius: AppRadius.lg,
              border: Border.all(color: AppColors.white.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile Completeness',
                      style: AppText.bodyMd.copyWith(color: AppColors.white),
                    ),
                    Text(
                      '${percentCompleted}%',
                      style: AppText.bodyBold.copyWith(color: AppColors.white),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                ClipRRect(
                  borderRadius: AppRadius.pill,
                  child: LinearProgressIndicator(
                    value: completeness,
                    backgroundColor: AppColors.white.withValues(alpha: 0.2),
                    color: AppColors.white,
                    minHeight: 6.h,
                  ),
                ),
                if (completeness < 1.0) ...[
                  SizedBox(height: 12.h),
                  Text(
                    'Complete your profile to unlock all features',
                    style: AppText.caption.copyWith(color: AppColors.white.withValues(alpha: 0.8)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatefulWidget"""

text = old_header_pattern.sub(new_header, text)

# 2. Remove the Scaffold AppBar and change body to just SingleChildScrollView
old_scaffold = """    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: UJobAppBar(
        title: 'Account',
        showBack: false,
        backgroundColor: AppColors.bg,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -1.0),
            radius: 1.2,
            colors: [
              AppColors.primaryLight.withValues(alpha: 0.4),
              AppColors.bg,
            ],
            stops: const [0.0, 0.5],
          ),
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CompanyProfileHeader(
              company: company, 
              completeness: completeness,
              onEditLogo: () => _showEditCompanyInfo(context, ref, company),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),"""

new_scaffold = """    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CompanyProfileHeader(
              company: company, 
              completeness: completeness,
              onEditLogo: () => _showEditCompanyInfo(context, ref, company),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),"""

text = text.replace(old_scaffold, new_scaffold)

# 3. Remove the extra closing tags we added before
old_end = """                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),
);
}"""

new_end = """                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }"""

text = text.replace(old_end, new_end)

with open('lib/features/employer/company/company_profile_screen.dart', 'w') as f:
    f.write(text)
