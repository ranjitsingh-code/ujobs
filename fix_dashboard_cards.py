with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'r') as f:
    text = f.read()

# Add imports
imports = """import '../../../core/widgets/ujob_employer_job_card.dart';
import '../../../core/widgets/ujob_employer_job_actions_sheet.dart';
import '../../../core/utils/job_action_helpers.dart';
import '../jobs/employer_job_provider.dart';"""
text = text.replace("import 'employer_dashboard_provider.dart';", "import 'employer_dashboard_provider.dart';\n" + imports)

# Update the rendering logic
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

# Remove _applicantCounts since it's not used anymore
text = text.replace("static const _applicantCounts = [12, 5, 0, 8, 3];", "")

# Delete the _JobCard class and _workplaceLabel, _statusLabel, _statusColor completely.
class_start = text.find("class _JobCard extends StatelessWidget {")
if class_start != -1:
    text = text[:class_start]

with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'w') as f:
    f.write(text)
