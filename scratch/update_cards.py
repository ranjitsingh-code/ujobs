import re
import os

def update_file(path, replacements):
    with open(path, 'r') as f:
        content = f.read()
    
    for orig, new in replacements:
        content = content.replace(orig, new)
        
    with open(path, 'w') as f:
        f.write(content)

# 1. MyApplicationsScreen
update_file('lib/features/seeker/applications/my_applications_screen.dart', [
    (
        "class _ApplicationList extends StatelessWidget {",
        "class _ApplicationList extends ConsumerWidget {"
    ),
    (
        "  Widget build(BuildContext context) {",
        "  Widget build(BuildContext context, WidgetRef ref) {"
    ),
    (
        "        return UJobJobCard(\n          job: app.job,\n          onTap: () => context.push('/seeker/jobs/${app.job.id}'),\n          // add application status here ideally, or a custom wrapper\n        );",
        """        final apps = ref.watch(seekerApplicationsProvider(null)).value ?? [];
        final isSaved = apps.any((a) => a.job.id == app.job.id && a.status == ApplicationStatus.saved);
        return UJobJobCard(
          job: app.job.copyWith(isSaved: isSaved),
          onTap: () => context.push('/seeker/jobs/${app.job.id}'),
          onSaveTap: () {
            ref.read(seekerApplicationsProvider(null).notifier).toggleSave(app.job);
            UJobToast.success(context, isSaved ? 'Job removed from saved' : 'Job saved successfully!');
          },
        );"""
    )
])

