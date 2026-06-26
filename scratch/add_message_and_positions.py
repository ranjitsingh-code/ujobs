import re

with open('lib/features/seeker/company/seeker_company_profile_screen.dart', 'r') as f:
    content = f.read()

# 1. Move `final jobsAsync = ref.watch(seekerJobsProvider);` to the top of `build` so we can count jobs.
orig_build_start = """  @override
  Widget build(BuildContext context) {
    return Scaffold("""
new_build_start = """  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(seekerJobsProvider);
    final openPositionsCount = jobsAsync.when(
      data: (jobs) => jobs.where((j) => j.company?.id == widget.company.id).length,
      loading: () => 0,
      error: (_, __) => 0,
    );

    return Scaffold("""
content = content.replace(orig_build_start, new_build_start)

# 2. Add "Open Positions" to Work Culture container.
orig_work_culture = """                  Expanded(
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
          ),"""

new_work_culture = """                  Expanded(
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
              SizedBox(height: 16.h),
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
              ),
            ],
          ),"""
content = content.replace(orig_work_culture, new_work_culture)

# Pass openPositionsCount to _buildAboutTab
orig_about_sig = "  Widget _buildAboutTab() {"
new_about_sig = "  Widget _buildAboutTab(int openPositionsCount) {"
content = content.replace(orig_about_sig, new_about_sig)

orig_body_tabs = "          children: [_buildAboutTab(), _buildJobsTab()],"
new_body_tabs = "          children: [_buildAboutTab(openPositionsCount), _buildJobsTab(jobsAsync)],"
content = content.replace(orig_body_tabs, new_body_tabs)

orig_jobs_sig = """  Widget _buildJobsTab() {
    final jobsAsync = ref.watch(seekerJobsProvider);

    return jobsAsync.when("""
new_jobs_sig = """  Widget _buildJobsTab(AsyncValue jobsAsync) {
    return jobsAsync.when("""
content = content.replace(orig_jobs_sig, new_jobs_sig)


# 3. Add Message button to Actions Section next to Website
orig_actions = """                  // Actions Section
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
                            label: context.l10n.website,
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedLink01,
                              color: AppColors.surface,
                              size: 20.r,
                            ),
                            gradient: AppColors.primaryGradient,
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
content = content.replace(orig_actions, new_actions)


# 4. We need to add the UJobToast import since we use it now
orig_imports = "import 'package:hugeicons/hugeicons.dart';"
new_imports = "import 'package:hugeicons/hugeicons.dart';\\nimport '../../../core/widgets/ujob_toast.dart';"
content = content.replace(orig_imports, new_imports)


with open('lib/features/seeker/company/seeker_company_profile_screen.dart', 'w') as f:
    f.write(content)
