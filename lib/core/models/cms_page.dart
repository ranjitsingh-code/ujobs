class CmsPage {
  final String id;
  final String slug;
  final String title;
  final String? body;
  final DateTime? updatedAt;

  CmsPage({
    required this.id,
    required this.slug,
    required this.title,
    this.body,
    this.updatedAt,
  });

  factory CmsPage.fromJson(Map<String, dynamic> json) {
    return CmsPage(
      id: json['id']?.toString() ?? '',
      slug: json['slug'] ?? '',
      title: json['title'] ?? '',
      body: json['content'] ?? json['body'],
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }
}
