class FilterOption {
  final String label;
  final String value;
  const FilterOption(this.label, this.value);

  factory FilterOption.fromJson(Map<String, dynamic> json) {
    return FilterOption(
      json['label']?.toString() ?? '',
      json['value']?.toString() ?? '',
    );
  }
}

class JobFilterOptions {
  final List<FilterOption> employmentTypes;
  final List<FilterOption> workplaceTypes;
  final List<FilterOption> experienceLevels;
  final List<FilterOption> salaryRanges;
  final List<FilterOption> datePosted;
  final List<FilterOption> sortOptions;
  final List<FilterOption> categories;

  const JobFilterOptions({
    this.employmentTypes = const [],
    this.workplaceTypes = const [],
    this.experienceLevels = const [],
    this.salaryRanges = const [],
    this.datePosted = const [],
    this.sortOptions = const [],
    this.categories = const [],
  });

  static List<FilterOption> _parseList(dynamic jsonList) {
    if (jsonList is! List) return [];
    return jsonList.map((e) {
      if (e is Map<String, dynamic>) {
        return FilterOption.fromJson(e);
      }
      return FilterOption(e.toString(), e.toString());
    }).toList();
  }

  factory JobFilterOptions.fromJson(Map<String, dynamic> json) {
    return JobFilterOptions(
      employmentTypes: _parseList(json['employment_types']),
      workplaceTypes: _parseList(json['workplace_types']),
      experienceLevels: _parseList(json['experience_levels']),
      salaryRanges: _parseList(json['salary_ranges']),
      datePosted: _parseList(json['date_posted']),
      sortOptions: _parseList(json['sort_options']),
      categories: _parseList(json['categories']),
    );
  }
}
