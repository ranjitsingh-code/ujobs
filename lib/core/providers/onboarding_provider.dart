import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/local_storage.dart';

final localStorageProvider = Provider<LocalStorage>((ref) => LocalStorage());

final onboardingSeenProvider = FutureProvider<bool>(
  (ref) => ref.read(localStorageProvider).getOnboardingSeen(),
);
