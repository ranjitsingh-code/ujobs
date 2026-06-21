import re

with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'r') as f:
    text = f.read()

# 1. Spacing for _CompanyProfileSetup
text = text.replace(
    """                if (!isProfileComplete)
                  _CompanyProfileSetup(
                    onSetup: () {
                      ref.read(isCompanyProfileCompleteProvider.notifier).state = true;
                    },
                  ),""",
    """                if (!isProfileComplete) ...[
                  SizedBox(height: 24.h),
                  _CompanyProfileSetup(
                    onSetup: () {
                      context.push('/employer/profile');
                    },
                  ),
                ],"""
)

# 2. Update existing refs to context.push
text = text.replace(
    "ref.read(isCompanyProfileCompleteProvider.notifier).state = true;",
    "context.push('/employer/profile');"
)

# 3. Update the _StatTiles
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

# 4. Use UJobEmployerJobCard
imports = """import '../../../core/widgets/ujob_employer_job_card.dart';
import '../../../core/widgets/ujob_employer_job_actions_sheet.dart';
import '../../../core/utils/job_action_helpers.dart';
import '../jobs/employer_job_provider.dart';"""
text = text.replace("import 'employer_dashboard_provider.dart';", "import 'employer_dashboard_provider.dart';\n" + imports)

old_usage = """                  ...dashboard.recentJobs.indexed.map((entry) {
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

new_usage = """                  ...dashboard.recentJobs.map((job) {
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
text = text.replace(old_usage, new_usage)

# Safely remove _JobCard
import re
text = re.sub(r'class _JobCard extends StatelessWidget \{.*?(?=class _CompanyProfileSetup)', '', text, flags=re.DOTALL)
text = text.replace("static const _applicantCounts = [12, 5, 0, 8, 3];", "")

# Remove _statusLabel and _statusColor which were only used by _JobCard
text = re.sub(r'String _workplaceLabel.*?\}', '', text, flags=re.DOTALL)
text = re.sub(r'String _statusLabel.*?\}', '', text, flags=re.DOTALL)
text = re.sub(r'Color _statusColor.*?\}', '', text, flags=re.DOTALL)


with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'w') as f:
    f.write(text)
