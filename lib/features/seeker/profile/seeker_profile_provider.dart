import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/models/skill.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/seeker_profile.dart';
import '../../../core/models/user.dart';

class SeekerProfileData {
  final User user;
  final SeekerProfile? profile;

  SeekerProfileData({required this.user, this.profile});

  String get status => user.status ?? 'pending';

  bool get isFresher => profile?.isFresher ?? false;

  // Server's profile_completed (13 checkpoints incl. avatar_url, skills,
  // experience, education) can't reach 100 while those sections stay hidden
  // in this UI (client request) — kept for display only, NOT used for gating.
  int get profileCompletionPercent => user.profileCompleted ?? 0;

  // Gates on only the fields actually shown+required in the current UI.
  bool get isProfileComplete {
    final profile = this.profile;

    if (user.firstName.isEmpty) return false;
    if (user.lastName.isEmpty) return false;
    if (user.phone == null || user.phone!.isEmpty) return false;

    if (profile == null) return false;

    // Location
    if (profile.country == null || profile.country!.isEmpty) return false;
    if (profile.city == null || profile.city!.isEmpty) return false;
    if (profile.address == null || profile.address!.isEmpty) return false;
    if (profile.zipCode == null || profile.zipCode!.isEmpty) return false;

    // Professional
    if (profile.headline == null || profile.headline!.isEmpty) return false;
    if ((profile.about == null || profile.about!.isEmpty) &&
        (profile.summary == null || profile.summary!.isEmpty)) {
      return false;
    }
    if (profile.availability == null || profile.availability!.isEmpty) return false;

    // Skills, Experience, Education, Avatar are excluded — those sections are
    // hidden in the UI (client request, will re-add later).

    return true;
  }

  bool get canApply => status == 'active' && isProfileComplete;
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

  Future<List<SeekerResume>> listResumes() async {
    final response = await _client.dio.get(Ep.seekerResumes);
    final data = response.data['data'] as List;
    return data
        .map((item) => SeekerResume.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<SeekerResume> uploadResume(String filePath) async {
    final formData = FormData.fromMap({
      'resume': await MultipartFile.fromFile(filePath),
    });
    final response = await _client.dio.post(Ep.seekerResumes, data: formData);
    return SeekerResume.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteResume(String id) async {
    await _client.dio.delete('${Ep.seekerResumes}/$id');
  }

  Future<List<CoverLetter>> listCoverLetters() async {
    final response = await _client.dio.get(Ep.seekerCoverLetters);
    final data = response.data['data'] as List;
    return data
        .map((item) => CoverLetter.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<CoverLetter> uploadCoverLetter(String filePath) async {
    final formData = FormData.fromMap({
      'cover_letter': await MultipartFile.fromFile(filePath),
    });
    final response = await _client.dio.post(Ep.seekerCoverLetters, data: formData);
    return CoverLetter.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteCoverLetter(String id) async {
    await _client.dio.delete('${Ep.seekerCoverLetters}/$id');
  }

  Future<Skill> createSkill(String name) async {
    final response = await _client.dio.post(
      Ep.seekerSkills,
      data: {'name': name},
    );
    return Skill.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}

final seekerProfileServiceProvider = Provider<SeekerProfileService>((ref) {
  return SeekerProfileService(ref.watch(dioClientProvider));
});
