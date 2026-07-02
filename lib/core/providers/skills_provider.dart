import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_endpoints.dart';
import '../models/skill.dart';
import 'auth_provider.dart';

final publicSkillsProvider = FutureProvider<List<Skill>>((ref) async {
  final dio = ref.watch(dioClientProvider).dio;
  final res = await dio.get(Ep.publicSkills);
  final data = res.data['data'] as List;
  return data.map((e) => Skill.fromJson(e as Map<String, dynamic>)).toList();
});
