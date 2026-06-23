import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cms_page.dart';
import '../api/api_endpoints.dart';
import 'auth_provider.dart';

final cmsPagesListProvider = FutureProvider<List<CmsPage>>((ref) async {
  final dio = ref.watch(dioClientProvider).dio;
  final res = await dio.get(Ep.publicPages);
  final data = res.data['data'] as List;
  return data.map((e) => CmsPage.fromJson(e)).toList();
});

final cmsPageDetailProvider = FutureProvider.family<CmsPage, String>((ref, slug) async {
  final dio = ref.watch(dioClientProvider).dio;
  final res = await dio.get(Ep.publicPage(slug));
  final data = res.data['data'] as Map<String, dynamic>;
  return CmsPage.fromJson(data);
});
