import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/job.dart';
import '../../employer/jobs/employer_job_provider.dart';

class JobFilter {
  final String? search;
  final String? category;
  final List<String> employmentTypes;
  final List<String> workplaces;
  final String? datePosted;
  final String? experienceLevel;
  final String? minSalary;
  final String? sortBy;

  JobFilter({
    this.search,
    this.category,
    this.employmentTypes = const [],
    this.workplaces = const [],
    this.datePosted,
    this.experienceLevel,
    this.minSalary,
    this.sortBy,
  });

  JobFilter copyWith({
    String? search,
    String? category,
    List<String>? employmentTypes,
    List<String>? workplaces,
    String? datePosted,
    String? experienceLevel,
    String? minSalary,
    String? sortBy,
  }) {
    return JobFilter(
      search: search ?? this.search,
      category: category ?? this.category,
      employmentTypes: employmentTypes ?? this.employmentTypes,
      workplaces: workplaces ?? this.workplaces,
      datePosted: datePosted ?? this.datePosted,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      minSalary: minSalary ?? this.minSalary,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JobFilter &&
          runtimeType == other.runtimeType &&
          search == other.search &&
          category == other.category &&
          datePosted == other.datePosted &&
          experienceLevel == other.experienceLevel &&
          minSalary == other.minSalary &&
          sortBy == other.sortBy &&
          employmentTypes.join(',') == other.employmentTypes.join(',') &&
          workplaces.join(',') == other.workplaces.join(',');

  @override
  int get hashCode =>
      search.hashCode ^
      category.hashCode ^
      employmentTypes.join(',').hashCode ^
      workplaces.join(',').hashCode ^
      datePosted.hashCode ^
      experienceLevel.hashCode ^
      minSalary.hashCode ^
      sortBy.hashCode;
}

final activeJobFilterProvider = StateProvider<JobFilter>((ref) => JobFilter());

final seekerJobsProvider = FutureProvider<List<Job>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 300));

  final allJobs = ref.watch(demoEmployerJobsProvider);
  final filter = ref.watch(activeJobFilterProvider);

  var filtered = allJobs.where((job) {
    if (filter.search != null && filter.search!.isNotEmpty) {
      if (!job.title.toLowerCase().contains(filter.search!.toLowerCase()) &&
          !(job.company?.name.toLowerCase().contains(
                filter.search!.toLowerCase(),
              ) ??
              false)) {
        return false;
      }
    }

    if (filter.employmentTypes.isNotEmpty) {
      if (!filter.employmentTypes.contains(job.employmentType)) {
        // Handle mapping between display names and internal names if needed
        bool matched = false;
        for (final t in filter.employmentTypes) {
          if (t.toLowerCase().replaceAll('-', '_') ==
              job.employmentType.toLowerCase()) {
            matched = true;
          }
        }
        if (!matched) return false;
      }
    }

    if (filter.workplaces.isNotEmpty) {
      if (!filter.workplaces
          .map((w) => w.toLowerCase().replaceAll('-', ''))
          .contains(job.workplaceType.toLowerCase())) {
        return false;
      }
    }

    if (filter.datePosted != null && filter.datePosted != 'Any time') {
      final now = DateTime.now();
      final diff = now.difference(job.createdAt ?? now).inHours;
      if (filter.datePosted == 'Last 24 hours' && diff > 24) return false;
      if (filter.datePosted == 'Last 3 days' && diff > 72) return false;
      if (filter.datePosted == 'Last 7 days' && diff > 168) return false;
      if (filter.datePosted == 'Last 14 days' && diff > 336) return false;
      if (filter.datePosted == 'Last 30 days' && diff > 720) return false;
    }

    if (filter.category != null && filter.category != 'All Categories') {
      if (job.category != filter.category) return false;
    }

    if (filter.experienceLevel != null &&
        filter.experienceLevel != 'Any level') {
      if (job.experienceLevel != filter.experienceLevel) return false;
    }

    if (filter.minSalary != null && filter.minSalary != 'Any salary') {
      final jobSalaryVal =
          int.tryParse(
            job.salaryMin?.replaceAll(RegExp(r'[^0-9]'), '') ?? '0',
          ) ??
          0;
      final filterSalaryVal =
          int.tryParse(filter.minSalary!.replaceAll(RegExp(r'[^0-9]'), '')) ??
          0;
      if (jobSalaryVal < filterSalaryVal) return false;
    }

    return true;
  }).toList();

  if (filter.sortBy != null) {
    if (filter.sortBy == 'Newest/latest') {
      filtered.sort(
        (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
          a.createdAt ?? DateTime.now(),
        ),
      );
    } else if (filter.sortBy == 'Salary: High to low') {
      filtered.sort((a, b) {
        final valA =
            int.tryParse(
              a.salaryMin?.replaceAll(RegExp(r'[^0-9]'), '') ?? '0',
            ) ??
            0;
        final valB =
            int.tryParse(
              b.salaryMin?.replaceAll(RegExp(r'[^0-9]'), '') ?? '0',
            ) ??
            0;
        return valB.compareTo(valA);
      });
    } else if (filter.sortBy == 'Salary: Low to high') {
      filtered.sort((a, b) {
        final valA =
            int.tryParse(
              a.salaryMin?.replaceAll(RegExp(r'[^0-9]'), '') ?? '0',
            ) ??
            0;
        final valB =
            int.tryParse(
              b.salaryMin?.replaceAll(RegExp(r'[^0-9]'), '') ?? '0',
            ) ??
            0;
        return valA.compareTo(valB);
      });
    }
  }

  return filtered;
});

final seekerJobDetailProvider = FutureProvider.family<Job, int>((
  ref,
  id,
) async {
  await Future.delayed(const Duration(milliseconds: 300));
  final allJobs = ref.watch(demoEmployerJobsProvider);
  return allJobs.firstWhere((j) => j.id == id, orElse: () => allJobs.first);
});
