import re

with open('lib/features/employer/jobs/employer_job_detail_screen.dart', 'r') as f:
    code = f.read()

close_block_old = """            if (job.status != JobStatus.draft &&
                job.status != JobStatus.closed) ...[
              UJobButton(
                label: context.l10n.closeJob1,
                variant: UJobButtonVariant.danger,
                isFullWidth: true,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dialogCtx) => UJobAlertDialog(
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedAlert02,
                        color: AppColors.error,
                        size: 32.r,
                      ),
                      iconBgColor: AppColors.error,
                      title: 'Close Job',
                      description:
                          'Are you sure you want to close this job? You will no longer receive new applications.',
                      confirmText: 'Close Job',
                      confirmColor: AppColors.error,
                      onConfirm: () async {
                        try {
                          await ref.read(employerJobServiceProvider).updateJobStatus(jobId, JobStatus.closed.name);
                          ref.invalidate(employerJobsProvider);
                          ref.invalidate(employerDashboardProvider);
                          if (context.mounted) {
                            Navigator.pop(dialogCtx);
                            Navigator.pop(context);
                            UJobToast.success(context, 'Success', sub: 'Job closed');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            Navigator.pop(dialogCtx);
                            UJobToast.error(context, 'Error', sub: 'Failed to close job');
                          }
                        }
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 12.h),
            ],"""

close_block_new = """            if (job.status != JobStatus.draft &&
                job.status != JobStatus.closed) ...[
              UJobButton(
                label: 'Close Job',
                variant: UJobButtonVariant.secondary,
                isFullWidth: true,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dialogCtx) => UJobAlertDialog(
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedAlert02,
                        color: AppColors.text,
                        size: 32.r,
                      ),
                      iconBgColor: AppColors.text,
                      title: 'Close Job',
                      description:
                          'Are you sure you want to close this job? You will no longer receive new applications.',
                      confirmText: 'Close Job',
                      confirmColor: AppColors.text,
                      onConfirm: () async {
                        try {
                          await ref.read(employerJobServiceProvider).updateJobStatus(jobId, JobStatus.closed.name);
                          ref.invalidate(employerJobsProvider);
                          ref.invalidate(employerDashboardProvider);
                          if (context.mounted) {
                            Navigator.pop(dialogCtx);
                            Navigator.pop(context);
                            UJobToast.success(context, 'Success', sub: 'Job closed');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            Navigator.pop(dialogCtx);
                            UJobToast.error(context, 'Error', sub: 'Failed to close job');
                          }
                        }
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 12.h),
            ],
            UJobButton(
              label: 'Delete Job',
              variant: UJobButtonVariant.danger,
              isFullWidth: true,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (dialogCtx) => UJobAlertDialog(
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedDelete01,
                      color: AppColors.error,
                      size: 32.r,
                    ),
                    iconBgColor: AppColors.error,
                    title: 'Delete Job',
                    description: 'Are you sure you want to permanently delete this job?',
                    confirmText: 'Delete Job',
                    confirmColor: AppColors.error,
                    onConfirm: () async {
                      try {
                        await ref.read(employerJobServiceProvider).deleteJob(int.parse(job.id));
                        ref.invalidate(employerJobsProvider);
                        ref.invalidate(employerDashboardProvider);
                        if (context.mounted) {
                          Navigator.pop(dialogCtx);
                          Navigator.pop(context);
                          UJobToast.success(context, 'Success', sub: 'Job deleted');
                        }
                      } catch (e) {
                        if (context.mounted) {
                          Navigator.pop(dialogCtx);
                          UJobToast.error(context, 'Error', sub: 'Failed to delete job');
                        }
                      }
                    },
                  ),
                );
              },
            ),
            SizedBox(height: 12.h),"""

code = code.replace(close_block_old, close_block_new)

with open('lib/features/employer/jobs/employer_job_detail_screen.dart', 'w') as f:
    f.write(code)

