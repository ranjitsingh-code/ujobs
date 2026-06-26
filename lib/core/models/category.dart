class JobCategory {
  final String id;
  final String name;
  final String slug;
  final String? icon;
  final int jobCount;

  const JobCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
    this.jobCount = 0,
  });

  factory JobCategory.fromJson(Map<String, dynamic> json) {
    return JobCategory(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      icon: json['icon'] as String?,
      jobCount: json['job_count'] as int? ?? 0,
    );
  }
}
