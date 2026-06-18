import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/application.dart';
import 'seeker_application_service.dart';

final seekerApplicationServiceProvider = Provider<SeekerApplicationService>((ref) {
  final client = ref.watch(dioClientProvider);
  return SeekerApplicationService(client);
});

final seekerApplicationsProvider = FutureProvider.family<List<Application>, String?>((ref, status) async {
  final service = ref.watch(seekerApplicationServiceProvider);
  return service.getMyApplications(status: status);
});
