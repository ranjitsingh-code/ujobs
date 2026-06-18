import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/job.dart';
import 'seeker_job_service.dart';

final seekerJobServiceProvider = Provider<SeekerJobService>((ref) {
  final client = ref.watch(dioClientProvider);
  return SeekerJobService(client);
});

// For browsing jobs with filters
class JobFilter {
  final String? search;
  final String? category;
  final String? employmentType;
  final String? workplaceType;

  JobFilter({this.search, this.category, this.employmentType, this.workplaceType});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JobFilter &&
          runtimeType == other.runtimeType &&
          search == other.search &&
          category == other.category &&
          employmentType == other.employmentType &&
          workplaceType == other.workplaceType;

  @override
  int get hashCode => search.hashCode ^ category.hashCode ^ employmentType.hashCode ^ workplaceType.hashCode;
}

final seekerJobsProvider = FutureProvider.family<List<Job>, JobFilter>((ref, filter) async {
  final service = ref.watch(seekerJobServiceProvider);
  return service.getJobs(
    search: filter.search,
    category: filter.category,
    employmentType: filter.employmentType,
    workplaceType: filter.workplaceType,
  );
});

final seekerJobDetailProvider = FutureProvider.family<Job, int>((ref, id) async {
  final service = ref.watch(seekerJobServiceProvider);
  return service.getJobDetails(id);
});
