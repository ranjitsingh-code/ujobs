import os

# 1. Update seeker_dashboard_provider.dart
dashboard_provider_path = 'lib/features/seeker/dashboard/seeker_dashboard_provider.dart'
with open(dashboard_provider_path, 'r') as f:
    content = f.read()

content = content.replace(
    "final jobsData = [];",
    "final allJobs = ref.watch(demoEmployerJobsProvider);\n    final jobsData = allJobs.take(3).toList();"
).replace(
    "recommendedJobs: jobsData\n          .map((j) => Job.fromJson(j as Map<String, dynamic>))\n          .toList(),",
    "recommendedJobs: jobsData,"
).replace(
    "import '../../../core/models/job.dart';",
    "import '../../../core/models/job.dart';\nimport '../../employer/jobs/employer_job_provider.dart';"
)

with open(dashboard_provider_path, 'w') as f:
    f.write(content)

# 2. Update seeker_job_provider.dart
seeker_job_provider_path = 'lib/features/seeker/jobs/seeker_job_provider.dart'
with open(seeker_job_provider_path, 'w') as f:
    f.write('''import 'package:flutter_riverpod/flutter_riverpod.dart';
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
          !(job.company?.name.toLowerCase().contains(filter.search!.toLowerCase()) ?? false)) {
        return false;
      }
    }
    
    if (filter.employmentTypes.isNotEmpty) {
      if (!filter.employmentTypes.contains(job.employmentType)) {
        // Handle mapping between display names and internal names if needed
        bool matched = false;
        for (final t in filter.employmentTypes) {
          if (t.toLowerCase().replaceAll('-', '_') == job.employmentType.toLowerCase()) {
            matched = true;
          }
        }
        if (!matched) return false;
      }
    }

    if (filter.workplaces.isNotEmpty) {
      if (!filter.workplaces.map((w) => w.toLowerCase().replaceAll('-', '')).contains(job.workplaceType.toLowerCase())) {
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

    return true;
  }).toList();

  if (filter.sortBy != null) {
    if (filter.sortBy == 'Newest') {
      filtered.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
    } else if (filter.sortBy == 'Salary (High to Low)') {
      filtered.sort((a, b) {
        final valA = int.tryParse(a.salaryMin?.replaceAll(RegExp(r'[^0-9]'), '') ?? '0') ?? 0;
        final valB = int.tryParse(b.salaryMin?.replaceAll(RegExp(r'[^0-9]'), '') ?? '0') ?? 0;
        return valB.compareTo(valA);
      });
    } else if (filter.sortBy == 'Salary (Low to High)') {
      filtered.sort((a, b) {
        final valA = int.tryParse(a.salaryMin?.replaceAll(RegExp(r'[^0-9]'), '') ?? '0') ?? 0;
        final valB = int.tryParse(b.salaryMin?.replaceAll(RegExp(r'[^0-9]'), '') ?? '0') ?? 0;
        return valA.compareTo(valB);
      });
    }
  }

  return filtered;
});

final seekerJobDetailProvider = FutureProvider.family<Job, int>((ref, id) async {
  await Future.delayed(const Duration(milliseconds: 300));
  final allJobs = ref.watch(demoEmployerJobsProvider);
  return allJobs.firstWhere((j) => j.id == id, orElse: () => allJobs.first);
});
''')

# 3. Update find_jobs_screen.dart to use activeJobFilterProvider
find_jobs_path = 'lib/features/seeker/jobs/find_jobs_screen.dart'
with open(find_jobs_path, 'r') as f:
    find_content = f.read()

find_content = find_content.replace(
    "final jobsAsync = ref.watch(seekerJobsProvider(JobFilter()));",
    "final jobsAsync = ref.watch(seekerJobsProvider);"
).replace(
    "onRetry: () => ref.refresh(seekerJobsProvider(JobFilter())),",
    "onRetry: () => ref.refresh(seekerJobsProvider),"
).replace(
    "ref.refresh(seekerJobsProvider(JobFilter()))",
    "ref.refresh(seekerJobsProvider)"
).replace(
    "onChanged: (_) {},",
    "onChanged: (v) => ref.read(activeJobFilterProvider.notifier).state = ref.read(activeJobFilterProvider).copyWith(search: v),"
)

with open(find_jobs_path, 'w') as f:
    f.write(find_content)

print("Updated providers!")
