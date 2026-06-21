with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'r') as f:
    text = f.read()

# 1. Update EmployerDashboardScreen to watch isCompanyProfileCompleteProvider
build_start = text.find('Widget build(BuildContext context, WidgetRef ref) {')
text = text[:build_start] + "Widget build(BuildContext context, WidgetRef ref) {\n    final isProfileComplete = ref.watch(isCompanyProfileCompleteProvider);\n" + text[build_start+51:]

# Update QuickActions to pass isProfileComplete
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
                            ref.read(isCompanyProfileCompleteProvider.notifier).state = true;
                          },
                        ),
                      );
                      return;
                    }
                    context.push('/employer/post-job');
                  },
                ),"""
text = text.replace(quick_actions_usage, quick_actions_new)

# Update EmptyJobs
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
                              ref.read(isCompanyProfileCompleteProvider.notifier).state = true;
                            },
                          ),
                        );
                        return;
                      }
                      context.push('/employer/post-job');
                    },
                  )"""
text = text.replace(empty_jobs_usage, empty_jobs_new)

# Show banner only if NOT complete
banner_usage = """                _CompanyProfileSetup(
                  onSetup: () {
                    // Navigate to company profile setup screen
                    // context.push('/employer/company-profile-setup');
                  },
                ),"""
banner_new = """                if (!isProfileComplete)
                  _CompanyProfileSetup(
                    onSetup: () {
                      ref.read(isCompanyProfileCompleteProvider.notifier).state = true;
                    },
                  ),"""
if banner_usage in text:
    text = text.replace(banner_usage, banner_new)
else:
    # insert before messagesToReply
    idx = text.find('if (messagesToReply.isNotEmpty) ...[')
    if idx != -1:
        text = text[:idx] + banner_new + "\n                " + text[idx:]

# Update QuickActions class
text = text.replace('class _QuickActions extends StatelessWidget {\n  final VoidCallback onPostJob;', 'class _QuickActions extends StatelessWidget {\n  final bool isProfileComplete;\n  final VoidCallback onPostJob;')
text = text.replace('const _QuickActions({required this.onPostJob});', 'const _QuickActions({required this.isProfileComplete, required this.onPostJob});')

# Inside QuickActions build: Opacity wrap
quick_actions_build = """    return Container(
      height: 58.h,"""
quick_actions_build_new = """    return Opacity(
      opacity: isProfileComplete ? 1.0 : 0.5,
      child: Container(
        height: 58.h,"""
text = text.replace(quick_actions_build, quick_actions_build_new)

# Adjust closing tags for QuickActions
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


# Update EmptyJobs class
text = text.replace('class _EmptyJobs extends StatelessWidget {\n  final VoidCallback onPostJob;', 'class _EmptyJobs extends StatelessWidget {\n  final bool isProfileComplete;\n  final VoidCallback onPostJob;')
text = text.replace('const _EmptyJobs({required this.onPostJob});', 'const _EmptyJobs({required this.isProfileComplete, required this.onPostJob});')

# EmptyJobs opacity on the button
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

