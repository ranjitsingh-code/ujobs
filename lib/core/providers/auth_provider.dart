import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/dio_client.dart';
import '../api/api_endpoints.dart';
import '../models/user.dart';
import 'role_provider.dart';

final dioClientProvider = Provider<DioClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return DioClient(storage);
});

class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    final storage = ref.read(secureStorageProvider);
    final token = await storage.getAccessToken();
    if (token == null) return null;

    // Restore saved role immediately so router doesn't flash wrong theme
    final savedRole = await storage.getRole();
    if (savedRole != null) {
      ref.read(activeRoleProvider.notifier).setRole(savedRole);
    }

    try {
      final dio = ref.read(dioClientProvider).dio;
      final res = await dio.get(Ep.me);
      final data = (res.data['data'] ?? res.data) as Map<String, dynamic>;
      final user = User.fromJson(data);
      if (user.role != null) {
        ref.read(activeRoleProvider.notifier).setRole(user.role!);
      }
      return user;
    } catch (_) {
      await storage.clearAll();
      return null;
    }
  }

  Future<void> mockLogin() async {
    state = const AsyncLoading();
    final user = User(
      id: '1',
      email: 'test@example.com',
      firstName: 'Test',
      lastName: 'User',
      role: 'seeker',
    );
    state = AsyncData(user);
  }

  Future<bool> login(String email, String password) async {
    state = const AsyncLoading();
    final storage = ref.read(secureStorageProvider);
    final dio = ref.read(dioClientProvider).dio;

    try {
      final res = await dio.post(
        Ep.login,
        data: {'email': email, 'password': password},
      );
      final data = (res.data['data'] ?? res.data) as Map<String, dynamic>;
      final userData = (data['user'] ?? data) as Map<String, dynamic>;

      final accessToken =
          data['accessToken'] as String? ??
          data['access_token'] as String? ??
          '';
      final refreshToken =
          data['refreshToken'] as String? ??
          data['refresh_token'] as String? ??
          '';

      await storage.saveTokens(accessToken, refreshToken);
      final user = User.fromJson(userData);

      if (user.role != null) {
        await storage.saveRole(user.role!);
        ref.read(activeRoleProvider.notifier).setRole(user.role!);
      }

      state = AsyncData(user);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<void> logout() async {
    await ref.read(secureStorageProvider).clearAll();
    ref.read(activeRoleProvider.notifier).setRole('employer');
    state = const AsyncData(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);
