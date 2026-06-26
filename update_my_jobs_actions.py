import re

with open("lib/features/employer/jobs/my_jobs_screen.dart", "r") as f:
    content = f.read()

# Replace demoEmployerJobsProvider with employerJobServiceProvider
old_pause_card = """                  () => ref
                      .read(demoEmployerJobsProvider.notifier)
                      .updateStatus(job.id, JobStatus.paused),"""
new_pause_card = """                  () async {
                    await ref.read(employerJobServiceProvider).updateJobStatus(job.id, JobStatus.paused.name);
                    ref.refresh(employerJobsProvider(status));
                  },"""
content = content.replace(old_pause_card, new_pause_card)

old_resume_card = """                  () => ref
                      .read(demoEmployerJobsProvider.notifier)
                      .updateStatus(job.id, JobStatus.active),"""
new_resume_card = """                  () async {
                    await ref.read(employerJobServiceProvider).updateJobStatus(job.id, JobStatus.active.name);
                    ref.refresh(employerJobsProvider(status));
                  },"""
content = content.replace(old_resume_card, new_resume_card)

old_publish_card = """                  () => ref
                      .read(demoEmployerJobsProvider.notifier)
                      .updateStatus(job.id, JobStatus.active),"""
new_publish_card = """                  () async {
                    await ref.read(employerJobServiceProvider).updateJobStatus(job.id, JobStatus.active.name);
                    ref.refresh(employerJobsProvider(status));
                  },"""
content = content.replace(old_publish_card, new_publish_card)

old_reopen_card = """                  () => ref
                      .read(demoEmployerJobsProvider.notifier)
                      .updateStatus(job.id, JobStatus.active),"""
new_reopen_card = """                  () async {
                    await ref.read(employerJobServiceProvider).updateJobStatus(job.id, JobStatus.active.name);
                    ref.refresh(employerJobsProvider(status));
                  },"""
content = content.replace(old_reopen_card, new_reopen_card)


old_notifier_actions = """    final notifier = ref.read(demoEmployerJobsProvider.notifier);

    showUJobEmployerJobActionsSheet(
      context: context,
      job: job,
      onEdit: () => JobActionHelpers.confirmEdit(
        context,
        () => context.push('/employer/jobs/${job.id}/edit', extra: job),
      ),
      onViewApplicants: () =>
          context.push('/employer/jobs/${job.id}/applicants', extra: job),
      onPause: () => JobActionHelpers.confirmPause(
        context,
        () => notifier.updateStatus(job.id, JobStatus.paused),
      ),
      onResume: () => JobActionHelpers.confirmResume(
        context,
        () => notifier.updateStatus(job.id, JobStatus.active),
      ),
      onPublish: () => JobActionHelpers.confirmPublish(
        context,
        () => notifier.updateStatus(job.id, JobStatus.active),
      ),
      onReopen: () => JobActionHelpers.confirmReopen(
        context,
        () => notifier.updateStatus(job.id, JobStatus.active),
      ),
      onDelete: () => _confirmDelete(context, ref, job),
    );"""

new_notifier_actions = """    showUJobEmployerJobActionsSheet(
      context: context,
      job: job,
      onEdit: () => JobActionHelpers.confirmEdit(
        context,
        () => context.push('/employer/jobs/${job.id}/edit', extra: job),
      ),
      onViewApplicants: () =>
          context.push('/employer/jobs/${job.id}/applicants', extra: job),
      onPause: () => JobActionHelpers.confirmPause(
        context,
        () async {
          await ref.read(employerJobServiceProvider).updateJobStatus(job.id, JobStatus.paused.name);
          ref.refresh(employerJobsProvider(null));
        },
      ),
      onResume: () => JobActionHelpers.confirmResume(
        context,
        () async {
          await ref.read(employerJobServiceProvider).updateJobStatus(job.id, JobStatus.active.name);
          ref.refresh(employerJobsProvider(null));
        },
      ),
      onPublish: () => JobActionHelpers.confirmPublish(
        context,
        () async {
          await ref.read(employerJobServiceProvider).updateJobStatus(job.id, JobStatus.active.name);
          ref.refresh(employerJobsProvider(null));
        },
      ),
      onReopen: () => JobActionHelpers.confirmReopen(
        context,
        () async {
          await ref.read(employerJobServiceProvider).updateJobStatus(job.id, JobStatus.active.name);
          ref.refresh(employerJobsProvider(null));
        },
      ),
      onDelete: () => _confirmDelete(context, ref, job),
    );"""
content = content.replace(old_notifier_actions, new_notifier_actions)

old_delete = """              () {
                ref
                    .read(demoEmployerJobsProvider.notifier)
                    .deleteJob(job.id);
                context.pop();
              },"""
new_delete = """              () async {
                await ref.read(employerJobServiceProvider).deleteJob(job.id);
                ref.refresh(employerJobsProvider(null));
                if (context.mounted) context.pop();
              },"""
content = content.replace(old_delete, new_delete)

with open("lib/features/employer/jobs/my_jobs_screen.dart", "w") as f:
    f.write(content)

