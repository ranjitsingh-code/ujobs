import re

with open("lib/features/employer/jobs/employer_job_provider.dart", "r") as f:
    content = f.read()

old_detail = """final employerJobDetailProvider = FutureProvider.family<Job, int>((
  ref,
  id,
) async {
  return ref.read(employerJobServiceProvider).getJobDetails(id);
});"""

new_detail = """final employerJobDetailProvider = FutureProvider.family<Job, int>((
  ref,
  id,
) async {
  // Since the list API already returns all details, we don't need a separate detail API call.
  // We can just fetch it from the API if we don't have it, but for now we'll assume the 
  // EmployerJobService is updated, or we just pass the full Job object to the screen instead.
  
  // Wait, if the user says "you can use id to check if api is working fine", maybe they DO want me 
  // to just use the list endpoint. 
  
  // Actually, I'll just change getJobDetails in employer_job_service to not be used if we don't need it.
  return ref.read(employerJobServiceProvider).getJobDetails(id);
});"""
# Wait, I won't run this script yet, I need to think.

