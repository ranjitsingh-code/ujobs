import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_endpoints.dart';
import 'auth_provider.dart';
import '../models/job_form_options.dart';

final jobFormOptionsProvider = FutureProvider<JobFormOptions>((ref) async {
  final dioClient = ref.watch(dioClientProvider);

  try {
    final response = await dioClient.dio.get(Ep.publicJobFormOptions);
    final data = response.data;
    if (data['success'] == true) {
      return JobFormOptions.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to load job form options');
  } catch (e) {
    throw Exception('Failed to load job form options: $e');
  }
});
