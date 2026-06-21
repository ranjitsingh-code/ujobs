with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'r') as f:
    text = f.read()

setup_widget = """
class _CompanyProfileSetup extends ConsumerWidget {
  final VoidCallback onSetup;

  const _CompanyProfileSetup({required this.onSetup});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.xl,
        border: Border.all(color: AppColors.warning),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withValues(alpha: 0.1),
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
              color: AppColors.warning.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedBuilding03,
              color: AppColors.warning,
              size: 28.r,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Complete your company profile',
                  style: AppText.titleSm.copyWith(color: AppColors.text),
                ),
                SizedBox(height: 4.h),
                Text(
                  'A complete profile helps attract better candidates and builds trust.',
                  style: AppText.small.copyWith(color: AppColors.muted),
                ),
                SizedBox(height: 16.h),
                FilledButton(
                  onPressed: onSetup,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    foregroundColor: AppColors.surface,
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
                  ),
                  child: Text('Setup Now', style: AppText.button.copyWith(color: Colors.white)),
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

if "_CompanyProfileSetup" not in text:
    text += setup_widget

build_start = text.find('Widget build(BuildContext context, WidgetRef ref) {')
if 'final isProfileComplete' not in text[build_start:build_start+200]:
    text = text[:build_start] + "Widget build(BuildContext context, WidgetRef ref) {\n    final isProfileComplete = ref.watch(isCompanyProfileCompleteProvider);\n" + text[build_start+51:]

quick_actions_usage = """                _QuickActions(
                  onPostJob: () => context.push('/employer/post-job'),
                ),"""
quick_actions_new = """                _QuickActions(
                  isProfileComplete: isProfileComplete,
                  onPostJob: () {
                    if (!isProfileComplete) {
                      showDialog(
                        context: context,
                        builder: (ctx) => UJobAlertDialog(
                          icon: HugeIcon(icon: HugeIcons.strokeRoundedAlert02, color: AppColors.warning, size: 32.r),
                          iconBgColor: AppColors.warning,
                          title: 'Action Required',
                          description: 'You must complete your company profile before you can post a new job.',
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
                ),
                if (!isProfileComplete) ...[
                  SizedBox(height: 24.h),
                  _CompanyProfileSetup(
                    onSetup: () {
                      context.push('/employer/profile');
                    },
                  ),
                ],"""
text = text.replace(quick_actions_usage, quick_actions_new)

text = text.replace('class _QuickActions extends StatelessWidget {\n  final VoidCallback onPostJob;', 'class _QuickActions extends StatelessWidget {\n  final bool isProfileComplete;\n  final VoidCallback onPostJob;')
text = text.replace('const _QuickActions({required this.onPostJob});', 'const _QuickActions({required this.isProfileComplete, required this.onPostJob});')

quick_actions_build = """    return Container(
      height: 58.h,"""
quick_actions_build_new = """    return Opacity(
      opacity: isProfileComplete ? 1.0 : 0.5,
      child: Container(
        height: 58.h,"""
text = text.replace(quick_actions_build, quick_actions_build_new)

quick_actions_end = """      ),
    );
  }
}

class _MessagesToReply"""
quick_actions_end_new = """        ),
      ),
    );
  }
}

class _MessagesToReply"""
text = text.replace(quick_actions_end, quick_actions_end_new)

empty_jobs_usage = """                  _EmptyJobs(
                    onPostJob: () => context.push('/employer/post-job'),
                  )"""
empty_jobs_new = """                  _EmptyJobs(
                    isProfileComplete: isProfileComplete,
                    onPostJob: () {
                      if (!isProfileComplete) {
                        showDialog(
                          context: context,
                          builder: (ctx) => UJobAlertDialog(
                            icon: HugeIcon(icon: HugeIcons.strokeRoundedAlert02, color: AppColors.warning, size: 32.r),
                            iconBgColor: AppColors.warning,
                            title: 'Action Required',
                            description: 'You must complete your company profile before you can post a new job.',
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
text = text.replace(empty_jobs_usage, empty_jobs_new)

text = text.replace('class _EmptyJobs extends StatelessWidget {\n  final VoidCallback onPostJob;', 'class _EmptyJobs extends StatelessWidget {\n  final bool isProfileComplete;\n  final VoidCallback onPostJob;')
text = text.replace('const _EmptyJobs({required this.onPostJob});', 'const _EmptyJobs({super.key, required this.isProfileComplete, required this.onPostJob});')

empty_jobs_btn = """          FilledButton.icon(
            onPressed: onPostJob,"""
empty_jobs_btn_new = """          Opacity(
            opacity: isProfileComplete ? 1.0 : 0.5,
            child: FilledButton.icon(
              onPressed: onPostJob,"""
text = text.replace(empty_jobs_btn, empty_jobs_btn_new)

empty_jobs_btn_end = """            label: Text('Post a Job', style: AppText.button),
          ),
        ],
      ),
    );
  }
}"""
empty_jobs_btn_end_new = """              label: Text('Post a Job', style: AppText.button),
            ),
          ),
        ],
      ),
    );
  }
}"""
text = text.replace(empty_jobs_btn_end, empty_jobs_btn_end_new)

with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'w') as f:
    f.write(text)
