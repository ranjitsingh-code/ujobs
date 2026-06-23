import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/country.dart';
import '../api/api_endpoints.dart';
import 'auth_provider.dart';

final countriesProvider = FutureProvider<List<Country>>((ref) async {
  final dio = ref.watch(dioClientProvider).dio;
  final res = await dio.get(Ep.publicCountries);
  final data = res.data['data'] as List;
  return data.map((e) => Country.fromJson(e)).toList();
});
