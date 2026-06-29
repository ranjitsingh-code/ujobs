import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/models/seeker_settings.dart';
import '../../../core/providers/auth_provider.dart';

class SeekerSettingsService {
  final DioClient _client;
  SeekerSettingsService(this._client);

  Future<SeekerSettings> getSettings() async {
    final res = await _client.dio.get(Ep.seekSettings);
    return SeekerSettings.fromJson(res.data['data']);
  }

  Future<SeekerSettings> updatePreferences(Map<String, dynamic> data) async {
    final res = await _client.dio.put(Ep.seekPreferences, data: data);
    return SeekerSettings.fromJson(res.data['data']);
  }

  Future<void> signOutAllDevices() async {
    await _client.dio.post(Ep.seekSignOutAll);
  }
}

final seekerSettingsServiceProvider = Provider<SeekerSettingsService>((ref) {
  return SeekerSettingsService(ref.watch(dioClientProvider));
});

final seekerSettingsProvider = FutureProvider.autoDispose<SeekerSettings>((ref) async {
  final service = ref.watch(seekerSettingsServiceProvider);
  return service.getSettings();
});
