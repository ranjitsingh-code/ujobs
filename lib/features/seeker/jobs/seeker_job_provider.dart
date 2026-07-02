import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/job.dart';
import 'seeker_job_service.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/providers/categories_provider.dart';

import '../../../core/models/job_filter_options.dart';

final seekerJobServiceProvider = Provider((ref) {
  return SeekerJobService(ref.watch(dioClientProvider));
});

final jobFilterOptionsProvider = FutureProvider<JobFilterOptions>((ref) async {
  final dio = ref.watch(dioClientProvider);
  final response = await dio.dio.get('/public/job-filter-options');
  if (response.data['success'] == true) {
    return JobFilterOptions.fromJson(response.data['data']);
  }
  return const JobFilterOptions();
});

class JobFilter {
  final String? search;
  final String? location;
  final String? company;
  final String? category;
  final List<String> employmentTypes;
  final List<String> workplaces;
  final String? datePosted;
  final String? experienceLevel;
  final String? minSalary;
  final String? sortBy;

  JobFilter({
    this.search,
    this.location,
    this.company,
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
    String? location,
    String? company,
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
      location: location ?? this.location,
      company: company ?? this.company,
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
          location == other.location &&
          company == other.company &&
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
      location.hashCode ^
      company.hashCode ^
      category.hashCode ^
      employmentTypes.join(',').hashCode ^
      workplaces.join(',').hashCode ^
      datePosted.hashCode ^
      experienceLevel.hashCode ^
      minSalary.hashCode ^
      sortBy.hashCode;
}

final activeJobFilterProvider = StateProvider<JobFilter>((ref) => JobFilter());

final seekerMatchingJobsProvider = FutureProvider.autoDispose<List<Job>>((ref) async {
  final dio = ref.watch(dioClientProvider).dio;
  final res = await dio.get(Ep.seekerMatching);
  return (res.data['data'] as List).map((j) => Job.fromJson(j)).toList();
});

final seekerJobsProvider = FutureProvider<List<Job>>((ref) async {
  final filter = ref.watch(activeJobFilterProvider);
  final service = ref.watch(seekerJobServiceProvider);


  // Determine employment type, workplace type.
  String? employmentType;
  if (filter.employmentTypes.isNotEmpty) {
    employmentType = filter.employmentTypes.first.toLowerCase().replaceAll('-', '_');
  }

  String? workplaceType;
  if (filter.workplaces.isNotEmpty) {
    workplaceType = filter.workplaces.first.toLowerCase().replaceAll('-', '_');
  }

  // Combine search and company name since the API search param supports company name,
  // and we don't have a company_id from a text input.
  String? search = filter.search;
  if (filter.company != null && filter.company!.isNotEmpty) {
    search = search == null || search.isEmpty 
      ? filter.company 
      : '$search ${filter.company}';
  }

  // Look up category_id
  int? categoryId;
  if (filter.category != null && filter.category != 'all_categories' && filter.category != 'All Categories') {
    final categories = ref.read(categoriesProvider).valueOrNull ?? [];
    try {
      final match = categories.firstWhere((c) => c.name == filter.category || c.id.toString() == filter.category);
      categoryId = int.tryParse(match.id.toString());
    } catch (_) {}
  }

  final experienceLevel = filter.experienceLevel == 'any_level' ? null : filter.experienceLevel;
  final salaryRange = filter.minSalary == 'any_salary' ? null : filter.minSalary;
  final datePosted = filter.datePosted == 'any_time' ? null : filter.datePosted;

  // Map Sort By
  String? sort;
  if (filter.sortBy == 'Most relevant') {
    sort = 'most_relevant';
  } else if (filter.sortBy == 'Newest/latest') {
    sort = 'latest';
  } else if (filter.sortBy == 'Salary: High to low') {
    sort = 'salary_high_to_low';
  } else if (filter.sortBy == 'Salary: Low to high') {
    sort = 'salary_low_to_high';
  }

  return service.getJobs(
    search: search,
    categoryId: categoryId,
    employmentType: employmentType,
    workplaceType: workplaceType,
    experienceLevel: experienceLevel,
    salaryRange: salaryRange,
    datePosted: datePosted,
    sort: sort,
    location: filter.location,
  );
});

final seekerJobDetailProvider = FutureProvider.autoDispose.family<Job, int>((
  ref,
  id,
) async {
  return ref.read(seekerJobServiceProvider).getJobDetails(id);
});
