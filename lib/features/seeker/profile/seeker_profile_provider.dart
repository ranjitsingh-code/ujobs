import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/seeker_profile.dart';
import '../../../core/models/user.dart';

class SeekerProfileData {
  final User user;
  final SeekerProfile? profile;
  
  SeekerProfileData({
    required this.user,
    this.profile,
  });
}

final seekerProfileProvider = StateProvider<SeekerProfileData?>((ref) => null);

final fetchSeekerProfileProvider = FutureProvider.autoDispose<void>((ref) async {
  final dio = ref.watch(dioClientProvider).dio;
  
  final res = await dio.get(Ep.seekerMe);
  final data = res.data['data'];
  
  final user = User.fromJson(data);
  SeekerProfile? profile;
  if (data['seeker_profiles'] != null) {
    profile = SeekerProfile.fromJson(data['seeker_profiles']);
  }
  
  ref.read(seekerProfileProvider.notifier).state = SeekerProfileData(
    user: user,
    profile: profile,
  );
});

class SeekerProfileService {
  final DioClient _client;
  SeekerProfileService(this._client);

  Future<void> updateProfile(Map<String, dynamic> data) async {
    await _client.dio.put(Ep.seekerMe, data: data);
  }

  Future<void> uploadResume(String filePath) async {
    final formData = FormData.fromMap({
      'resume': await MultipartFile.fromFile(filePath),
    });
    await _client.dio.post(Ep.seekerResumes, data: formData);
  }

  Future<void> deleteResume(String id) async {
    await _client.dio.delete('${Ep.seekerResumes}/$id');
  }
}

final seekerProfileServiceProvider = Provider<SeekerProfileService>((ref) {
  return SeekerProfileService(ref.watch(dioClientProvider));
});
