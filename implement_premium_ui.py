import re

with open('lib/features/employer/company/company_profile_screen.dart', 'r') as f:
    text = f.read()

# 1. Remove AppBar and add Stack with Gradient Background and Floating Back Button
old_build_start = """  @override
  Widget build(BuildContext context) {
    final company = ref.watch(companyProfileProvider);
    final completeness = ref.watch(companyProfileCompletenessProvider);
    
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const UJobAppBar(title: 'Company Profile'),
      body: SingleChildScrollView("""

new_build_start = """  @override
  Widget build(BuildContext context) {
    final company = ref.watch(companyProfileProvider);
    final completeness = ref.watch(companyProfileCompletenessProvider);
    
    return Scaffold(
      backgroundColor: AppColors.bg,
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
            SingleChildScrollView("""
text = text.replace(old_build_start, new_build_start)

# Add closing tags for the Stack and Container, and the Floating Back button
old_build_end = """                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }"""

new_build_end = """                  ),
                ],
              ),
            ),
            SizedBox(height: 40.h), // Extra padding at bottom
          ],
        ),
      ),
      Positioned(
        top: MediaQuery.of(context).padding.top + 12.h,
        left: 20.w,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.8),
              borderRadius: AppRadius.pill,
              border: Border.all(color: AppColors.white.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.text1.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: AppColors.text2, size: 20.r),
                SizedBox(width: 6.w),
                Text('Account', style: AppText.bodyMd.copyWith(color: AppColors.text2, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    ],
  ),
),
);
}"""
text = text.replace(old_build_end, new_build_end)

# 2. Add Drop Shadow to _SectionCard
old_section_card_decor = """    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.xl,
        border: Border.all(color: AppColors.border),
      ),"""

new_section_card_decor = """    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.xl,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: _isExpanded ? 0.08 : 0.02),
            blurRadius: _isExpanded ? 24 : 10,
            offset: Offset(0, _isExpanded ? 8 : 4),
          ),
        ],
      ),"""
text = text.replace(old_section_card_decor, new_section_card_decor)

# 3. Update CompanyProfileHeader to have transparent background (to show gradient)
text = text.replace("color: AppColors.surface,\n        border: Border(bottom: BorderSide(color: AppColors.border)),", "color: Colors.transparent,")

# 4. Implement Circular Progress around the Avatar
old_header_stack = """          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 80.r,
                height: 80.r,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppRadius.lg,
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
                bottom: -8.r,
                right: -8.r,
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
            ],
          ),"""

new_header_stack = """          SizedBox(height: MediaQuery.of(context).padding.top + 40.h),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 104.r,
                height: 104.r,
                child: CircularProgressIndicator(
                  value: completeness,
                  strokeWidth: 4.r,
                  backgroundColor: AppColors.primaryLight,
                  color: AppColors.primary,
                  strokeCap: StrokeCap.round,
                ),
              ),
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
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: completeness == 1.0 ? AppColors.success.withValues(alpha: 0.1) : AppColors.primaryLight,
              borderRadius: AppRadius.pill,
            ),
            child: Text(
              completeness == 1.0 ? '100% Complete' : '${(completeness * 100).toInt()}% Profile Complete',
              style: AppText.caption.copyWith(
                color: completeness == 1.0 ? AppColors.success : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),"""
text = text.replace(old_header_stack, new_header_stack)


# 5. Remove the old massive linear progress block at the bottom of the Header
old_linear_progress = """          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: AppRadius.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile Completion',
                      style: AppText.label.copyWith(color: AppColors.white),
                    ),
                    Text(
                      '${(completeness * 100).toInt()}%',
                      style: AppText.label.copyWith(color: AppColors.white),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
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
                  SizedBox(height: 8.h),
                  Text(
                    'Complete your profile to post jobs',
                    style: AppText.caption.copyWith(color: AppColors.white.withValues(alpha: 0.8)),
                  ),
                ],
              ],
            ),
          ),"""

text = text.replace(old_linear_progress, "")

with open('lib/features/employer/company/company_profile_screen.dart', 'w') as f:
    f.write(text)
