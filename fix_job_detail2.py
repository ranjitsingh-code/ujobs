import re

with open('lib/features/employer/jobs/employer_job_detail_screen.dart', 'r') as f:
    code = f.read()

delete_block_old = """                      cancelText: 'Cancel',
                      confirmText: 'Delete',
                      onConfirm: () {
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },"""

delete_block_new = """                      cancelText: 'Cancel',
                      confirmText: 'Delete Job',
                      confirmColor: AppColors.error,
                      onConfirm: () async {
                        try {
                          await ref.read(employerJobServiceProvider).deleteJob(job.id);
                          ref.invalidate(employerJobsProvider);
                          ref.invalidate(employerDashboardProvider);
                          if (context.mounted) {
                            Navigator.pop(ctx);
                            Navigator.pop(context);
                            UJobToast.success(context, 'Success', sub: 'Job deleted');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            Navigator.pop(ctx);
                            UJobToast.error(context, 'Error', sub: 'Failed to delete job');
                          }
                        }
                      },"""

code = code.replace(delete_block_old, delete_block_new)

with open('lib/features/employer/jobs/employer_job_detail_screen.dart', 'w') as f:
    f.write(code)

