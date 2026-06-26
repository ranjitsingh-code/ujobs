import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/models/employer_settings.dart';
import '../../../core/providers/auth_provider.dart';

class EmployerSettingsService {
  final DioClient _client;
  EmployerSettingsService(this._client);

  Future<EmployerSettings> getSettings() async {
    final res = await _client.dio.get(Ep.empSettings);
    return EmployerSettings.fromJson(res.data['data']);
  }

  Future<void> updateSettings(Map<String, dynamic> data) async {
    await _client.dio.patch(Ep.empSettings, data: data);
  }

  Future<EmployerSettings> updatePreferences(Map<String, dynamic> data) async {
    final res = await _client.dio.put(Ep.empPreferences, data: data);
    return EmployerSettings.fromJson(res.data['data']);
  }
}

final employerSettingsServiceProvider = Provider<EmployerSettingsService>((ref) {
  return EmployerSettingsService(ref.watch(dioClientProvider));
});

final employerSettingsProvider = FutureProvider.autoDispose<EmployerSettings>((ref) async {
  final service = ref.watch(employerSettingsServiceProvider);
  return service.getSettings();
});
