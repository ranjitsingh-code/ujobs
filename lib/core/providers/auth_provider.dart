import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/dio_client.dart';
import '../api/api_endpoints.dart';
import '../models/user.dart';
import 'role_provider.dart';

final dioClientProvider = Provider<DioClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return DioClient(storage);
});

enum LoginResult { success, requiresOtp, invalidCredentials, suspended, error }

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

      // 🔴 If the admin suspended them while they were away, kick them out immediately!
      if (user.status == 'suspended' || user.status == 'banned' || user.status == 'inactive') {
        await storage.clearAll();
        return null;
      }

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


  Future<(LoginResult, String?)> login(String email, String password, String role) async {
    state = const AsyncLoading();
    final storage = ref.read(secureStorageProvider);
    final dio = ref.read(dioClientProvider).dio;

    final apiRole = role == 'seeker' ? 'job_seeker' : role;

    try {
      final res = await dio.post(
        Ep.login,
        data: {'email': email, 'password': password, 'role': apiRole},
      );
      final rawData = res.data as Map<String, dynamic>;

      if (rawData['success'] == false) {
        final code = rawData['error']?['code'];
        if (code == 'INVALID_CREDENTIALS') return (LoginResult.invalidCredentials, null);
        if (code == 'ACCOUNT_SUSPENDED') return (LoginResult.suspended, null);
        return (LoginResult.error, rawData['error']?['message']?.toString());
      }

      final data = (rawData['data'] ?? rawData) as Map<String, dynamic>;

      if (data['requires_otp'] == true) {
        state = const AsyncData(null);
        return (LoginResult.requiresOtp, data['user_id']?.toString());
      }

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
      } else {
        await storage.saveRole(role);
        ref.read(activeRoleProvider.notifier).setRole(role);
      }

      state = AsyncData(user);
      return (LoginResult.success, null);
    } catch (e, st) {
      state = AsyncError(e, st);
      if (e is DioException && e.response?.data is Map<String, dynamic>) {
        final errorData = e.response!.data as Map<String, dynamic>;
        final code = errorData['error']?['code'];
        if (code == 'INVALID_CREDENTIALS') return (LoginResult.invalidCredentials, null);
        if (code == 'ACCOUNT_SUSPENDED') return (LoginResult.suspended, null);
        final message = errorData['error']?['message']?.toString();
        // Extract validation details if available
        final details = errorData['error']?['details'];
        String? detailMsg;
        if (details is Map) {
          detailMsg = details.values.expand((v) => v is List ? v : [v]).join(', ');
        }
        return (LoginResult.error, detailMsg ?? message ?? 'An unexpected error occurred.');
      }
      return (LoginResult.error, 'A network error occurred. Please try again.');
    }
  }

  Future<(LoginResult, String?)> verifyOtp(String userId, String code) async {
    state = const AsyncLoading();
    final storage = ref.read(secureStorageProvider);
    final dio = ref.read(dioClientProvider).dio;

    try {
      final res = await dio.post(
        Ep.verifyOtp,
        data: {'user_id': userId, 'code': code},
      );
      final rawData = res.data as Map<String, dynamic>;

      if (rawData['success'] == false) {
        return (LoginResult.error, rawData['error']?['message']?.toString());
      }

      final data = (rawData['data'] ?? rawData) as Map<String, dynamic>;
      final userData = (data['user'] ?? data) as Map<String, dynamic>;

      final accessToken =
          data['accessToken'] as String? ??
          data['access_token'] as String? ??
          '';
      final refreshToken =
          data['refreshToken'] as String? ??
          data['refresh_token'] as String? ??
          '';

      if (accessToken.isNotEmpty) {
        await storage.saveTokens(accessToken, refreshToken);
      }
      final user = User.fromJson(userData);

      if (user.role != null) {
        await storage.saveRole(user.role!);
        ref.read(activeRoleProvider.notifier).setRole(user.role!);
      }

      state = AsyncData(user);
      return (LoginResult.success, null);
    } catch (e, st) {
      state = AsyncError(e, st);
      if (e is DioException && e.response != null) {
        if (e.response!.statusCode == 423) {
          // Explicitly handle 423 Account Locked
          return (
            LoginResult.error,
            'Account locked due to too many failed OTP attempts — try again later'
          );
        }
        
        if (e.response?.data is Map<String, dynamic>) {
          final errorData = e.response!.data as Map<String, dynamic>;
          final message = errorData['error']?['message']?.toString();
          return (LoginResult.error, message ?? 'An unexpected error occurred.');
        }
      }
      return (LoginResult.error, 'A network error occurred. Please try again.');
    }
  }

  Future<String?> resendOtp(String userId) async {
    try {
      final dio = ref.read(dioClientProvider).dio;
      final res = await dio.post(
        Ep.resendOtp,
        data: {'user_id': userId},
      );
      final rawData = res.data as Map<String, dynamic>;
      
      if (rawData['success'] == false) {
        return rawData['error']?['message']?.toString() ?? 'Failed to resend OTP.';
      }
      return null;
    } catch (e) {
      if (e is DioException && e.response?.data is Map<String, dynamic>) {
        final errorData = e.response!.data as Map<String, dynamic>;
        return errorData['error']?['message']?.toString() ?? 'An unexpected error occurred.';
      }
      return 'A network error occurred. Please try again.';
    }
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    try {
      final dio = ref.read(dioClientProvider).dio;
      await dio.post(Ep.logout);
    } catch (_) {
      // Even if API fails, we still want to clear local session
    }
    await ref.read(secureStorageProvider).clearAll();
    ref.read(activeRoleProvider.notifier).setRole('employer');
    state = const AsyncData(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);
