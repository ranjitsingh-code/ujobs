import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/role_provider.dart';

final onboardingSeenProvider = FutureProvider<bool>(
  (ref) => ref.read(secureStorageProvider).getOnboardingSeen(),
);
