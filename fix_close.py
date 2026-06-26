import re

with open('lib/features/employer/jobs/employer_job_detail_screen.dart', 'r') as f:
    text = f.read()

target = """            // 5. DESTRUCTIVE ACTIONS
            if (job.status == JobStatus.active ||
                job.status == JobStatus.paused ||
                job.status == JobStatus.pending ||
                job.status == JobStatus.draft) ...[
              UJobButton(
                label: context.l10n.closeJob1,
                outlined: true,
                color: AppColors.error,
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedAlert02,
                  color: AppColors.error,
                  size: 20.r,
                ),
                onTap: () {
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
                          await ref.read(employerJobServiceProvider).updateJobStatus(jobId, JobStatus.closed.name);
                          ref.invalidate(employerJobsProvider);
                          ref.invalidate(employerDashboardProvider);
                          if (context.mounted) {
                            Navigator.pop(ctx);
                            Navigator.pop(context);
                            UJobToast.success(context, 'Success', sub: 'Job closed');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            Navigator.pop(ctx);
                            UJobToast.error(context, 'Error', sub: 'Failed to close job');
                          }
                        }
                      },
                    ),
                  );
                },
              ),
            ],"""

replacement = """            // 5. DESTRUCTIVE ACTIONS
            UJobButton(
              label: context.l10n.closeJob1,
              outlined: true,
              color: AppColors.text,
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedAlert02,
                color: AppColors.text,
                size: 20.r,
              ),
              onTap: () {
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
                        await ref.read(employerJobServiceProvider).updateJobStatus(jobId, JobStatus.closed.name);
                        ref.invalidate(employerJobsProvider);
                        ref.invalidate(employerDashboardProvider);
                        if (context.mounted) {
                          Navigator.pop(ctx);
                          Navigator.pop(context);
                          UJobToast.success(context, 'Success', sub: 'Job closed');
                        }
                      } catch (e) {
                        if (context.mounted) {
                          Navigator.pop(ctx);
                          UJobToast.error(context, 'Error', sub: 'Failed to close job');
                        }
                      }
                    },
                  ),
                );
              },
            ),
            SizedBox(height: 12.h),"""

text = text.replace(target, replacement)

with open('lib/features/employer/jobs/employer_job_detail_screen.dart', 'w') as f:
    f.write(text)
