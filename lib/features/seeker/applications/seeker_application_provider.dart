import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/application.dart';
import '../../../core/models/job.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/providers/auth_provider.dart';

class SeekerApplicationsNotifier
    extends StateNotifier<AsyncValue<List<Application>>> {
  final Ref ref;

  SeekerApplicationsNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final dio = ref.read(dioClientProvider).dio;
      final results = await Future.wait([
        dio.get(Ep.seekerApplications),
        dio.get(Ep.seekerSavedJobs),
      ]);
      
      final appsData = (results[0].data['data'] as List).map((a) => Application.fromJson(a)).toList();
      
      final savedData = (results[1].data['data'] as List).map((a) {
        // saved-jobs might return Jobs directly or a nested structure
        // If it's nested like application, fromJson will handle it.
        // Otherwise, if it returns jobs directly, we wrap them in an Application.
        Job job;
        if (a['jobs'] != null || a['job'] != null) {
          job = Job.fromJson(a['jobs'] ?? a['job']);
        } else {
          job = Job.fromJson(a);
        }
        
        return Application(
          id: int.tryParse(a['id']?.toString() ?? '0') ?? 0,
          job: job,
          status: ApplicationStatus.saved,
          createdAt: DateTime.tryParse(a['saved_at'] ?? a['created_at'] ?? '') ?? DateTime.now(),
        );
      }).toList();
      
      state = AsyncValue.data([...appsData, ...savedData]);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  bool isJobSaved(int jobId) {
    if (state.value == null) return false;
    return state.value!.any(
      (a) => a.job.id == jobId && a.status == ApplicationStatus.saved,
    );
  }

  Future<void> toggleSave(Job job) async {
    if (state.value == null) return;

    final currentList = List<Application>.from(state.value!);
    final existingIndex = currentList.indexWhere(
      (a) => a.job.id == job.id && a.status == ApplicationStatus.saved,
    );

    final isSaved = existingIndex >= 0;

    // Optimistic UI update
    if (isSaved) {
      currentList.removeAt(existingIndex);
    } else {
      currentList.add(
        Application(
          id: DateTime.now().millisecondsSinceEpoch,
          job: job,
          status: ApplicationStatus.saved,
          createdAt: DateTime.now(),
        ),
      );
    }
    state = AsyncValue.data(currentList);

    try {
      final dio = ref.read(dioClientProvider).dio;
      if (isSaved) {
        await dio.delete(Ep.saveJob(job.id.toString()));
      } else {
        await dio.post(Ep.saveJob(job.id.toString()));
      }
    } catch (e) {
      // API call failed, ignore for optimistic UI or add revert logic
    }
  }
}

final seekerApplicationsProvider =
    StateNotifierProvider.family<
      SeekerApplicationsNotifier,
      AsyncValue<List<Application>>,
      String?
    >((ref, _) {
      return SeekerApplicationsNotifier(ref);
    });
