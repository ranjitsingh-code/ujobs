import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/job.dart';
import '../../employer/jobs/employer_job_provider.dart';

// For browsing jobs with filters
class JobFilter {
  final String? search;
  final String? category;
  final String? employmentType;
  final String? workplaceType;

  JobFilter({
    this.search,
    this.category,
    this.employmentType,
    this.workplaceType,
  });

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
  int get hashCode =>
      search.hashCode ^
      category.hashCode ^
      employmentType.hashCode ^
      workplaceType.hashCode;
}

final seekerJobsProvider = FutureProvider.family<List<Job>, JobFilter>((
  ref,
  filter,
) async {
  // Wait a bit to simulate network
  await Future.delayed(const Duration(milliseconds: 500));

  final allJobs = ref.watch(demoEmployerJobsProvider);

  // Simple mock filtering
  return allJobs.where((job) {
    if (filter.search != null && filter.search!.isNotEmpty) {
      if (!job.title.toLowerCase().contains(filter.search!.toLowerCase()))
        return false;
    }
    return true;
  }).toList();
});

final seekerJobDetailProvider = FutureProvider.family<Job, int>((
  ref,
  id,
) async {
  // Wait a bit to simulate network
  await Future.delayed(const Duration(milliseconds: 500));

  final allJobs = ref.watch(demoEmployerJobsProvider);
  return allJobs.firstWhere((j) => j.id == id, orElse: () => allJobs.first);
});
