import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/job.dart';
import 'employer_job_service.dart';

final employerJobServiceProvider = Provider<EmployerJobService>((ref) {
  final client = ref.watch(dioClientProvider);
  return EmployerJobService(client);
});

final employerJobsProvider = FutureProvider.family<List<Job>, String?>((ref, status) async {
  final service = ref.watch(employerJobServiceProvider);
  return service.getMyJobs(status: status);
});

// For specific job details
final employerJobDetailProvider = FutureProvider.family<Job, int>((ref, id) async {
  final service = ref.watch(employerJobServiceProvider);
  return service.getJobDetails(id);
});
