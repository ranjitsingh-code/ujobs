import re

with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'r') as f:
    text = f.read()

# 1. Add _CompanyProfileSetup widget to the end of the file
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
text += setup_widget

# 2. Add necessary imports
imports = """import '../../../core/widgets/ujob_alert_dialog.dart';
import '../../../core/widgets/ujob_employer_job_card.dart';
import '../../../core/widgets/ujob_employer_job_actions_sheet.dart';
import '../../../core/utils/job_action_helpers.dart';
import '../jobs/employer_job_provider.dart';"""
text = text.replace("import 'employer_dashboard_provider.dart';", "import 'employer_dashboard_provider.dart';\n" + imports)

# 3. Update build method to watch isCompanyProfileCompleteProvider
build_start = text.find('Widget build(BuildContext context, WidgetRef ref) {')
text = text[:build_start] + "Widget build(BuildContext context, WidgetRef ref) {\n    final isProfileComplete = ref.watch(isCompanyProfileCompleteProvider);\n" + text[build_start+51:]

# 4. Insert _CompanyProfileSetup inside SliverList
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

# 5. Update _QuickActions definition
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

# 6. Update _StatTiles onTap
text = text.replace(
    """                      label: 'Total Jobs',
                      icon: Icons.work_outline_rounded,
                      onTap: onJobsTap,""",
    """                      label: 'Total Jobs',
                      icon: Icons.work_outline_rounded,
                      onTap: () => context.go('/employer/jobs', extra: 0),"""
)

text = text.replace(
    """                      label: 'Active Jobs',
                      icon: Icons.work_history_outlined,
                      onTap: onJobsTap,""",
    """                      label: 'Active Jobs',
                      icon: Icons.work_history_outlined,
                      onTap: () => context.go('/employer/jobs', extra: 1),"""
)

text = text.replace(
    """                      label: 'Total Applicants',
                      icon: Icons.groups_outlined,
                      onTap: onApplicantsTap,""",
    """                      label: 'Total Applicants',
                      icon: Icons.groups_outlined,
                      onTap: () => context.push('/employer/applicants', extra: 0),"""
)

text = text.replace(
    """                      label: 'Shortlisted',
                      icon: Icons.bookmark_added_outlined,
                      onTap: onApplicantsTap,""",
    """                      label: 'Shortlisted',
                      icon: Icons.bookmark_added_outlined,
                      onTap: () => context.push('/employer/applicants', extra: 2),"""
)

# 7. Update Job List to use UJobEmployerJobCard
old_job_list = """                  ...dashboard.recentJobs.indexed.map((entry) {
                    final index = entry.$1;
                    final job = entry.$2;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _JobCard(
                        job: job,
                        applicantCount:
                            _applicantCounts[index % _applicantCounts.length],
                        onTap: () => context.push('/employer/jobs/${job.id}'),
                        onApplicantsTap: () =>
                            context.push('/employer/jobs/${job.id}/applicants', extra: job),
                      ),
                    );
                  }),"""

new_job_list = """                  ...dashboard.recentJobs.map((job) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: UJobEmployerJobCard(
                        job: job,
                        isManaging: false,
                        onTap: () => context.push('/employer/jobs/${job.id}'),
                        onApplicantsTap: () => context.push('/employer/jobs/${job.id}/applicants', extra: job),
                        onMoreTap: () => showUJobEmployerJobActionsSheet(
                          context: context,
                          job: job,
                          onEdit: () => JobActionHelpers.confirmEdit(context, () => context.push('/employer/jobs/${job.id}/edit', extra: job)),
                          onViewApplicants: () => context.push('/employer/jobs/${job.id}/applicants', extra: job),
                          onPause: () => JobActionHelpers.confirmPause(context, () => ref.read(demoEmployerJobsProvider.notifier).updateStatus(job.id, JobStatus.paused)),
                          onResume: () => JobActionHelpers.confirmResume(context, () => ref.read(demoEmployerJobsProvider.notifier).updateStatus(job.id, JobStatus.active)),
                          onPublish: () => JobActionHelpers.confirmPublish(context, () => ref.read(demoEmployerJobsProvider.notifier).updateStatus(job.id, JobStatus.active)),
                          onReopen: () => JobActionHelpers.confirmReopen(context, () => ref.read(demoEmployerJobsProvider.notifier).updateStatus(job.id, JobStatus.active)),
                          onDelete: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => UJobAlertDialog(
                                icon: HugeIcon(
                                  icon: job.status == JobStatus.closed || job.status == JobStatus.rejected ? HugeIcons.strokeRoundedDelete01 : HugeIcons.strokeRoundedAlert02,
                                  color: AppColors.error,
                                  size: 32.r,
                                ),
                                iconBgColor: AppColors.error,
                                title: job.status == JobStatus.closed || job.status == JobStatus.rejected ? 'Delete Job' : 'Close Job',
                                description: job.status == JobStatus.closed || job.status == JobStatus.rejected 
                                    ? 'Are you sure you want to permanently delete this job?' 
                                    : 'Are you sure you want to close this job? You will no longer receive new applications.',
                                cancelText: 'Cancel',
                                confirmText: job.status == JobStatus.closed || job.status == JobStatus.rejected ? 'Delete' : 'Close Job',
                                onConfirm: () {
                                  if (!(job.status == JobStatus.closed || job.status == JobStatus.rejected)) {
                                    ref.read(demoEmployerJobsProvider.notifier).updateStatus(job.id, JobStatus.closed);
                                  }
                                  Navigator.pop(ctx);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }),"""
text = text.replace(old_job_list, new_job_list)

# 8. Update _EmptyJobs
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
text = text.replace('const _EmptyJobs({required this.onPostJob});', 'const _EmptyJobs({required this.isProfileComplete, required this.onPostJob});')

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

# 9. REMOVE _JobCard, _workplaceLabel, _statusLabel, _statusColor, _JobMenuAction, _postedLabel
text = re.sub(r'class _JobCard extends StatelessWidget \{.*?\}\n\}', '', text, flags=re.DOTALL)
text = re.sub(r'enum _JobMenuAction \{ details, applicants \}', '', text, flags=re.DOTALL)
text = re.sub(r'String _postedLabel.*?\}', '', text, flags=re.DOTALL)
text = re.sub(r'String _workplaceLabel.*?\}', '', text, flags=re.DOTALL)
text = re.sub(r'String _statusLabel.*?\}', '', text, flags=re.DOTALL)
text = re.sub(r'Color _statusColor.*?\}', '', text, flags=re.DOTALL)
text = text.replace("static const _applicantCounts = [12, 5, 0, 8, 3];\n", "")

with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'w') as f:
    f.write(text)
