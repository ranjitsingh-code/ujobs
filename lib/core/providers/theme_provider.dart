import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'role_provider.dart'; // secureStorageProvider lives here

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _loadFromStorage();
    return ThemeMode.system;
  }

  Future<void> _loadFromStorage() async {
    final saved = await ref.read(secureStorageProvider).getTheme();
    state = _fromString(saved);
  }

  void setMode(ThemeMode mode) {
    state = mode;
    ref.read(secureStorageProvider).saveTheme(_toString(mode));
  }

  void toggle() =>
      setMode(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);

  bool get isDark => state == ThemeMode.dark;

  static ThemeMode _fromString(String s) => switch (s) {
    'dark' => ThemeMode.dark,
    'light' => ThemeMode.light,
    _ => ThemeMode.system,
  };

  static String _toString(ThemeMode m) => switch (m) {
    ThemeMode.dark => 'dark',
    ThemeMode.light => 'light',
    _ => 'system',
  };
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
