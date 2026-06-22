import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _s = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _keyAccess = 'access_token';
  static const _keyRefresh = 'refresh_token';
  static const _keyRole = 'active_role'; // 'employer' | 'job_seeker'
  static const _keyTheme = 'theme_mode'; // 'light' | 'dark' | 'system'
  static const _keyLocale = 'locale'; // 'en' | 'ar'
  static const _keyOnboarding = 'onboarding_seen';
  static const _keyEmail = 'remember_email';
  static const _keyPassword = 'remember_password';

  Future<void> saveTokens(String access, String refresh) async {
    await _s.write(key: _keyAccess, value: access);
    await _s.write(key: _keyRefresh, value: refresh);
  }

  Future<String?> getAccessToken() => _s.read(key: _keyAccess);
  Future<String?> getRefreshToken() => _s.read(key: _keyRefresh);

  Future<void> saveRememberMe(String email, String password) async {
    await _s.write(key: _keyEmail, value: email);
    await _s.write(key: _keyPassword, value: password);
  }

  Future<String?> getRememberedEmail() => _s.read(key: _keyEmail);
  Future<String?> getRememberedPassword() => _s.read(key: _keyPassword);

  Future<void> clearRememberMe() async {
    await _s.delete(key: _keyEmail);
    await _s.delete(key: _keyPassword);
  }

  Future<void> saveRole(String role) => _s.write(key: _keyRole, value: role);
  Future<String?> getRole() => _s.read(key: _keyRole);

  Future<void> saveTheme(String mode) => _s.write(key: _keyTheme, value: mode);
  Future<String> getTheme() async => await _s.read(key: _keyTheme) ?? 'system';

  Future<void> saveLocale(String code) =>
      _s.write(key: _keyLocale, value: code);
  Future<String> getLocale() async => await _s.read(key: _keyLocale) ?? 'en';

  Future<void> saveOnboardingSeen() =>
      _s.write(key: _keyOnboarding, value: '1');
  Future<bool> getOnboardingSeen() async =>
      await _s.read(key: _keyOnboarding) == '1';

  Future<void> clearAll() => _s.deleteAll();
}
