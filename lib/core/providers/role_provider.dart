import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage.dart';

final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());

class ActiveRoleNotifier extends Notifier<String> {
  @override
  String build() => 'employer'; // overwritten on login/app start

  void setRole(String role) {
    state = role;
    ref.read(secureStorageProvider).saveRole(role);
  }

  void switchRole() => setRole(state == 'employer' ? 'job_seeker' : 'employer');

  bool get isEmployer => state == 'employer';
  bool get isJobSeeker => state == 'job_seeker';
}

final activeRoleProvider = NotifierProvider<ActiveRoleNotifier, String>(
  ActiveRoleNotifier.new,
);
