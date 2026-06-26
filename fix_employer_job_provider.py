import re

with open("lib/features/employer/jobs/employer_job_provider.dart", "r") as f:
    content = f.read()

# Add imports
old_imports = """import '../../../core/models/company.dart';"""
new_imports = """import '../../../core/models/company.dart';
import '../../../core/api/dio_client.dart';
import 'employer_job_service.dart';

final employerJobServiceProvider = Provider((ref) {
  return EmployerJobService(ref.watch(dioClientProvider));
});"""
content = content.replace(old_imports, new_imports)

# Replace provider
old_provider = """final employerJobsProvider = FutureProvider.family<List<Job>, String?>((
  ref,
  status,
) async {
  final jobs = ref.watch(demoEmployerJobsProvider);
  if (status == null) return jobs;
  return jobs.where((job) => job.status.name == status).toList();
});"""

new_provider = """final employerJobsProvider = FutureProvider.family<List<Job>, String?>((
  ref,
  status,
) async {
  return ref.read(employerJobServiceProvider).getMyJobs(status: status);
});"""
content = content.replace(old_provider, new_provider)

with open("lib/features/employer/jobs/employer_job_provider.dart", "w") as f:
    f.write(content)

