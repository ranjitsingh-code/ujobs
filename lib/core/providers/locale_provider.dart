import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'role_provider.dart'; // secureStorageProvider lives here

const supportedLocales = [Locale('en'), Locale('ar')];

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    _loadFromStorage();
    return const Locale('en');
  }

  Future<void> _loadFromStorage() async {
    final saved = await ref.read(secureStorageProvider).getLocale();
    if (saved.isNotEmpty) state = Locale(saved);
  }

  void setLocale(Locale locale) {
    state = locale;
    ref.read(secureStorageProvider).saveLocale(locale.languageCode);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);
