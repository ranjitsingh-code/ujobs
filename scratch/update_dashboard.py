import re

with open('lib/features/seeker/dashboard/seeker_dashboard_screen.dart', 'r') as f:
    content = f.read()

if "import '../applications/seeker_application_provider.dart';" not in content:
    content = content.replace("import 'seeker_dashboard_provider.dart';", "import 'seeker_dashboard_provider.dart';\nimport '../applications/seeker_application_provider.dart';\nimport '../../../core/models/application.dart';\nimport '../../../core/widgets/ujob_toast.dart';")

orig = """                          return UJobJobCard(
                            job: job,
                            onTap: () => context.push('/seeker/jobs/${job.id}'),
                          );"""

new = """                          final apps = ref.watch(seekerApplicationsProvider(null)).value ?? [];
                          final isSaved = apps.any((a) => a.job.id == job.id && a.status == ApplicationStatus.saved);
                          return UJobJobCard(
                            job: job.copyWith(isSaved: isSaved),
                            onTap: () => context.push('/seeker/jobs/${job.id}'),
                            onSaveTap: () {
                              ref.read(seekerApplicationsProvider(null).notifier).toggleSave(job);
                              UJobToast.success(context, isSaved ? 'Job removed from saved' : 'Job saved successfully!');
                            },
                          );"""

content = content.replace(orig, new)

with open('lib/features/seeker/dashboard/seeker_dashboard_screen.dart', 'w') as f:
    f.write(content)
