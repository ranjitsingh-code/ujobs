import '../../core/api/dio_client.dart';
import '../../core/api/api_endpoints.dart';

class AuthService {
  final DioClient _client;
  AuthService(this._client);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _client.dio.post(
      Ep.login,
      data: {'email': email, 'password': password},
    );
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> registerEmployer({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String companyName,
  }) async {
    final res = await _client.dio.post(
      Ep.registerEmployer,
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'company_name': companyName,
      },
    );
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> registerSeeker({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final res = await _client.dio.post(
      Ep.registerSeeker,
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
      },
    );
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMe() async {
    final res = await _client.dio.get(Ep.me);
    return res.data as Map<String, dynamic>;
  }

  Future<void> verifyOtp(String email, String otp) async {
    // ⚠️ server returns 500 — this will throw. Caller handles gracefully.
    await _client.dio.post(Ep.verifyOtp, data: {'email': email, 'otp': otp});
  }

  Future<void> forgotPassword(String email) async {
    await _client.dio.post(Ep.forgotPasswordRequest, data: {'email': email});
  }
}
