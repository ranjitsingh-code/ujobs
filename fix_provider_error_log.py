import re

with open("lib/features/employer/jobs/employer_job_provider.dart", "r") as f:
    content = f.read()

old_provider = """final employerJobsProvider = FutureProvider.family<List<Job>, String?>((
  ref,
  status,
) async {
  return ref.read(employerJobServiceProvider).getMyJobs(status: status);
});"""

new_provider = """final employerJobsProvider = FutureProvider.family<List<Job>, String?>((
  ref,
  status,
) async {
  try {
    return await ref.read(employerJobServiceProvider).getMyJobs(status: status);
  } catch (e, stackTrace) {
    print('Error loading jobs: $e');
    print(stackTrace);
    rethrow;
  }
});"""

content = content.replace(old_provider, new_provider)

with open("lib/features/employer/jobs/employer_job_provider.dart", "w") as f:
    f.write(content)

