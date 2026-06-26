import re

with open("lib/features/seeker/jobs/seeker_job_provider.dart", "r") as f:
    content = f.read()

# Add imports
if "import '../../../core/api/dio_client.dart';" not in content:
    content = content.replace(
        "import '../../../core/models/job.dart';",
        "import '../../../core/models/job.dart';\nimport '../../../core/api/dio_client.dart';\nimport 'seeker_job_service.dart';"
    )

# Add provider
if "final seekerJobServiceProvider =" not in content:
    content = content.replace(
        "class JobFilter {",
        "final seekerJobServiceProvider = Provider((ref) {\n  return SeekerJobService(ref.watch(dioClientProvider));\n});\n\nclass JobFilter {"
    )

# Replace seekerJobDetailProvider
old_detail = """final seekerJobDetailProvider = FutureProvider.family<Job, int>((
  ref,
  id,
) async {
  await Future.delayed(const Duration(milliseconds: 300));
  final allJobs = ref.watch(demoEmployerJobsProvider);
  return allJobs.firstWhere((j) => j.id == id, orElse: () => allJobs.first);
});"""

new_detail = """final seekerJobDetailProvider = FutureProvider.family<Job, int>((
  ref,
  id,
) async {
  return ref.read(seekerJobServiceProvider).getJobDetails(id);
});"""

content = content.replace(old_detail, new_detail)

with open("lib/features/seeker/jobs/seeker_job_provider.dart", "w") as f:
    f.write(content)

