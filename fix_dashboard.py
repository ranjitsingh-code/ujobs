import re

with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'r') as f:
    code = f.read()

confirm_delete_old = """                          onDelete: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => UJobAlertDialog(
                                icon: HugeIcon(
                                  icon: HugeIcons.strokeRoundedAlert02,
                                  color: AppColors.error,
                                  size: 32.r,
                                ),
                                iconBgColor: AppColors.error,
                                title: 'Close Job',
                                description:
                                    'Are you sure you want to close this job? You will no longer receive new applications.',
                                cancelText: 'Cancel',
                                confirmText: 'Close Job',
                                onConfirm: () async {
                                  try {
                                    await ref.read(employerJobServiceProvider).updateJobStatus(job.id, JobStatus.closed.name);
                                    ref.invalidate(employerDashboardProvider);
                                    ref.invalidate(employerJobsProvider);
                                    if (context.mounted) {
                                      UJobToast.success(context, 'Success', sub: 'Job closed');
                                    }
                                  } catch (e) {
                                    if (context.mounted) UJobToast.error(context, 'Error', sub: 'Failed to close job');
                                  }
                                  if (context.mounted) Navigator.pop(ctx);
                                },
                              ),
                            );
                          },"""

confirm_delete_new = """                          onClose: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => UJobAlertDialog(
                                icon: HugeIcon(
                                  icon: HugeIcons.strokeRoundedAlert02,
                                  color: AppColors.text,
                                  size: 32.r,
                                ),
                                iconBgColor: AppColors.text,
                                title: 'Close Job',
                                description:
                                    'Are you sure you want to close this job? You will no longer receive new applications.',
                                cancelText: 'Cancel',
                                confirmText: 'Close Job',
                                onConfirm: () async {
                                  try {
                                    await ref.read(employerJobServiceProvider).updateJobStatus(job.id, JobStatus.closed.name);
                                    ref.invalidate(employerDashboardProvider);
                                    ref.invalidate(employerJobsProvider);
                                    if (context.mounted) {
                                      UJobToast.success(context, 'Success', sub: 'Job closed');
                                    }
                                  } catch (e) {
                                    if (context.mounted) UJobToast.error(context, 'Error', sub: 'Failed to close job');
                                  }
                                  if (context.mounted) Navigator.pop(ctx);
                                },
                              ),
                            );
                          },
                          onDelete: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => UJobAlertDialog(
                                icon: HugeIcon(
                                  icon: HugeIcons.strokeRoundedDelete01,
                                  color: AppColors.error,
                                  size: 32.r,
                                ),
                                iconBgColor: AppColors.error,
                                title: 'Delete Job',
                                description: 'Are you sure you want to permanently delete this job?',
                                cancelText: 'Cancel',
                                confirmText: 'Delete',
                                onConfirm: () async {
                                  try {
                                    await ref.read(employerJobServiceProvider).deleteJob(int.parse(job.id));
                                    ref.invalidate(employerDashboardProvider);
                                    ref.invalidate(employerJobsProvider);
                                    if (context.mounted) {
                                      UJobToast.success(context, 'Success', sub: 'Job deleted');
                                    }
                                  } catch (e) {
                                    if (context.mounted) UJobToast.error(context, 'Error', sub: 'Failed to delete job');
                                  }
                                  if (context.mounted) Navigator.pop(ctx);
                                },
                              ),
                            );
                          },"""

code = code.replace(confirm_delete_old, confirm_delete_new)
with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'w') as f:
    f.write(code)

