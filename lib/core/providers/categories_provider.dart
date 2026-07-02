import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_endpoints.dart';
import '../models/category.dart';
import 'auth_provider.dart';

final categoriesProvider = FutureProvider<List<JobCategory>>((ref) async {
  final dioClient = ref.watch(dioClientProvider);
  try {
    final response = await dioClient.dio.get(Ep.publicCategories);
    final data = response.data['data'] as List;
    return data.map((json) => JobCategory.fromJson(json)).toList();
  } catch (e) {
    // In a real app, you might want to retry or log
    return [];
  }
});
