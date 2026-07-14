import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/dio_client.dart';
import '../api/api_endpoints.dart';
import '../models/user.dart';
import '../models/company_profile.dart';
import 'role_provider.dart';
import '../utils/api_error_parser.dart';
import '../../features/employer/dashboard/employer_dashboard_provider.dart';
import '../services/notification_service.dart';

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(ref);
});

enum LoginResult { success, requiresOtp, invalidCredentials, suspended, locked, error }

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
      final apiEndpoint = savedRole == 'employer' ? Ep.employerMe : Ep.me;
      final res = await dio.get(apiEndpoint);
      final data = (res.data['data'] ?? res.data) as Map<String, dynamic>;
      final user = User.fromJson(data);

      if (savedRole == 'employer' && data['companies'] != null && (data['companies'] as List).isNotEmpty) {
        final companyData = data['companies'][0] as Map<String, dynamic>;
        Future.microtask(() {
          ref.read(companyProfileProvider.notifier).state = CompanyProfile.fromJson(companyData);
        });
      }

      if (user.role != null) {
        ref.read(activeRoleProvider.notifier).setRole(user.role!);
      } else if (savedRole != null) {
        return user.copyWith(role: savedRole);
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
        data: {
          'email': email,
          'password': password,
          'role': apiRole,
          ...await NotificationService.deviceRegistrationFields(),
        },
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
      if (e is DioException) {
        final err = parseApiErrorDetail(e);
        if (err.code == 'INVALID_CREDENTIALS') return (LoginResult.invalidCredentials, null);
        if (err.code == 'ACCOUNT_SUSPENDED') return (LoginResult.suspended, null);
        if (err.code == 'ACCOUNT_LOCKED') return (LoginResult.locked, err.message);
        return (LoginResult.error, err.message);
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
      if (e is DioException) {
        final err = parseApiErrorDetail(e);
        if (err.code == 'ACCOUNT_SUSPENDED') return (LoginResult.suspended, err.message);
        if (err.code == 'ACCOUNT_LOCKED') return (LoginResult.locked, err.message);
        return (LoginResult.error, err.message);
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
      if (e is DioException) {
        return parseApiError(e);
      }
      return 'A network error occurred. Please try again.';
    }
  }

  Future<void> logout({bool localOnly = false}) async {
    state = const AsyncLoading();
    if (!localOnly) {
      try {
        final dio = ref.read(dioClientProvider).dio;
        await dio.post(Ep.logout);
      } catch (_) {
        // Even if API fails, we still want to clear local session
      }
    }
    await ref.read(secureStorageProvider).clearAll();
    ref.read(activeRoleProvider.notifier).setRole('employer');
    state = const AsyncData(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);
