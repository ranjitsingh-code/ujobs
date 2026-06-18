class ApiResponse<T> {
  final T? data;
  final String? message;
  final bool success;

  const ApiResponse({this.data, this.message, this.success = true});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJson,
  ) {
    final raw = json['data'] ?? json;
    return ApiResponse<T>(
      data: fromJson(raw),
      message: json['message'] as String?,
      success: (json['success'] as bool?) ?? true,
    );
  }
}

class PaginatedResponse<T> {
  final List<T> items;
  final int total;
  final int page;
  final int pages;

  const PaginatedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pages,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final data       = (json['data'] as Map<String, dynamic>?) ?? json;
    final rawItems   = (data['items'] ?? data['data'] ?? []) as List;
    final pagination = (data['pagination'] ?? data['meta'] ?? {}) as Map;

    return PaginatedResponse<T>(
      items: rawItems.map((e) => fromJson(e as Map<String, dynamic>)).toList(),
      total: (pagination['total'] as int?) ?? rawItems.length,
      page:  (pagination['page']  as int?) ?? 1,
      pages: (pagination['pages'] as int?) ?? 1,
    );
  }
}
