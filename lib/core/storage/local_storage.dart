import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const _keyOnboarding = 'onboarding_seen';

  Future<void> saveOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboarding, true);
  }

  Future<bool> getOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboarding) ?? false;
  }
}
