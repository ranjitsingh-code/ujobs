import re

with open('lib/features/employer/jobs/employer_job_detail_screen.dart', 'r') as f:
    text = f.read()

target = """                onTap: () {
                  JobActionHelpers.confirmPublish(
                    context,
                    () => ref
                        .read(demoEmployerJobsProvider.notifier)
                        .updateStatus(job.id, JobStatus.active),
                  );
                },"""

replacement = """                onTap: () {
                  JobActionHelpers.confirmPublish(
                    context,
                    () async {
                      try {
                        await ref.read(employerJobServiceProvider).updateJobStatus(job.id, JobStatus.active.name);
                        ref.invalidate(employerJobsProvider);
                        ref.invalidate(employerDashboardProvider);
                        ref.invalidate(employerJobDetailProvider(jobId));
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        if (context.mounted) UJobToast.error(context, 'Error', sub: 'Failed to publish job');
                      }
                    },
                  );
                },"""

if target in text:
    text = text.replace(target, replacement)
    with open('lib/features/employer/jobs/employer_job_detail_screen.dart', 'w') as f:
        f.write(text)
    print("Success")
else:
    print("Target not found")
