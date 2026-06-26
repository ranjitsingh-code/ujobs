import re

with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'r') as f:
    text = f.read()

# Replace `_QuickActions` invocation
quick_actions_target = """                _QuickActions(
                  isProfileComplete: isProfileComplete,
                  onPostJob: () {
                    if (!isProfileComplete) {
                      showDialog(
                        context: context,
                        builder: (ctx) => UJobAlertDialog(
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedAlert02,
                            color: AppColors.warning,
                            size: 32.r,
                          ),
                          iconBgColor: AppColors.warning,
                          title: 'Action Required',
                          description:
                              'You must complete your company profile before you can post a new job.',
                          confirmText: 'Setup Profile',
                          confirmColor: AppColors.primary,
                          cancelText: 'Cancel',
                          onConfirm: () {
                            Navigator.pop(ctx);
                            context.push('/employer/profile');
                          },
                        ),
                      );
                      return;
                    }
                    context.push('/employer/post-job');
                  },
                ),"""

quick_actions_replacement = """                _QuickActions(
                  isVerified: dashboard.isVerified,
                  onPostJob: () {
                    if (!dashboard.isVerified) {
                      showDialog(
                        context: context,
                        builder: (ctx) => UJobAlertDialog(
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedAlert02,
                            color: AppColors.error,
                            size: 32.r,
                          ),
                          iconBgColor: AppColors.error,
                          title: 'Verification Required',
                          description: 'You are not allowed to post a job until you verify your profile. Please wait for the admin to verify your account.',
                          confirmText: 'Okay',
                          confirmColor: AppColors.primary,
                          onConfirm: () {
                            Navigator.pop(ctx);
                          },
                        ),
                      );
                      return;
                    }
                    context.push('/employer/post-job');
                  },
                ),"""

text = text.replace(quick_actions_target, quick_actions_replacement)

# Replace `_CompanyProfileSetup` invocation logic
setup_target = """                if (!isProfileComplete) ...[
                  SizedBox(height: 24.h),
                  _CompanyProfileSetup(
                    onSetup: () {
                      context.push('/employer/profile');
                    },
                  ),
                ],"""

setup_replacement = """                if (!dashboard.isVerified) ...[
                  SizedBox(height: 24.h),
                  _VerificationPendingBanner(),
                ],
                if (dashboard.profileCompleted < 100) ...[
                  SizedBox(height: 24.h),
                  _CompanyProfileSetup(
                    onSetup: () {
                      context.push('/employer/profile');
                    },
                  ),
                ],"""

text = text.replace(setup_target, setup_replacement)

# Replace `_EmptyJobs` invocation logic
empty_jobs_target = """                if (dashboard.recentJobs.isEmpty)
                  _EmptyJobs(
                    isProfileComplete: isProfileComplete,
                    onPostJob: () {
                      if (!isProfileComplete) {
                        showDialog(
                          context: context,
                          builder: (ctx) => UJobAlertDialog(
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedAlert02,
                              color: AppColors.warning,
                              size: 32.r,
                            ),
                            iconBgColor: AppColors.warning,
                            title: 'Action Required',
                            description:
                                'You must complete your company profile before you can post a new job.',
                            confirmText: 'Setup Profile',
                            confirmColor: AppColors.primary,
                            cancelText: 'Cancel',
                            onConfirm: () {
                              Navigator.pop(ctx);
                              context.push('/employer/profile');
                            },
                          ),
                        );
                        return;
                      }
                      context.push('/employer/post-job');
                    },
                  )"""

empty_jobs_replacement = """                if (dashboard.recentJobs.isEmpty)
                  _EmptyJobs(
                    isVerified: dashboard.isVerified,
                    onPostJob: () {
                      if (!dashboard.isVerified) {
                        showDialog(
                          context: context,
                          builder: (ctx) => UJobAlertDialog(
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedAlert02,
                              color: AppColors.error,
                              size: 32.r,
                            ),
                            iconBgColor: AppColors.error,
                            title: 'Verification Required',
                            description: 'You are not allowed to post a job until you verify your profile. Please wait for the admin to verify your account.',
                            confirmText: 'Okay',
                            confirmColor: AppColors.primary,
                            onConfirm: () {
                              Navigator.pop(ctx);
                            },
                          ),
                        );
                        return;
                      }
                      context.push('/employer/post-job');
                    },
                  )"""

text = text.replace(empty_jobs_target, empty_jobs_replacement)

# Update `_QuickActions` and `_EmptyJobs` class definitions
text = text.replace("class _QuickActions extends StatelessWidget {\n  final bool isProfileComplete;", "class _QuickActions extends StatelessWidget {\n  final bool isVerified;")
text = text.replace("const _QuickActions({required this.isProfileComplete,", "const _QuickActions({required this.isVerified,")
text = text.replace("opacity: isProfileComplete ? 1.0 : 0.5,", "opacity: isVerified ? 1.0 : 0.5,")

text = text.replace("class _EmptyJobs extends StatelessWidget {\n  final bool isProfileComplete;", "class _EmptyJobs extends StatelessWidget {\n  final bool isVerified;")
text = text.replace("const _EmptyJobs({required this.isProfileComplete,", "const _EmptyJobs({required this.isVerified,")

# Add _VerificationPendingBanner
banner_code = """
class _VerificationPendingBanner extends StatelessWidget {
  const _VerificationPendingBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.xl,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedAlert02,
              color: AppColors.error,
              size: 28.r,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile verification pending',
                  style: AppText.titleSm.copyWith(color: AppColors.text),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Your profile is not verified yet. You have to wait for the verification from the admin.',
                  style: AppText.small.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
"""

text = text + banner_code

with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'w') as f:
    f.write(text)

