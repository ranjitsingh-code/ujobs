import re

with open('lib/features/seeker/applications/seeker_application_provider.dart', 'r') as f:
    content = f.read()

new_content = """import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/application.dart';
import '../../../core/models/job.dart';
import '../../employer/jobs/employer_job_provider.dart';

class SeekerApplicationsNotifier extends StateNotifier<AsyncValue<List<Application>>> {
  final Ref ref;
  
  SeekerApplicationsNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final jobs = ref.read(demoEmployerJobsProvider);

    final mockApps = [
      Application(
        id: 1,
        job: jobs.first,
        status: ApplicationStatus.applied,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      if (jobs.length > 1)
        Application(
          id: 2,
          job: jobs[1],
          status: ApplicationStatus.applied,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      if (jobs.length > 2)
        Application(
          id: 3,
          job: jobs[2],
          status: ApplicationStatus.rejected,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
    ];

    state = AsyncValue.data(mockApps);
  }

  bool isJobSaved(int jobId) {
    if (state.value == null) return false;
    return state.value!.any((a) => a.job.id == jobId && a.status == ApplicationStatus.saved);
  }

  void toggleSave(Job job) {
    if (state.value == null) return;
    
    final currentList = List<Application>.from(state.value!);
    final existingIndex = currentList.indexWhere((a) => a.job.id == job.id && a.status == ApplicationStatus.saved);
    
    if (existingIndex >= 0) {
      currentList.removeAt(existingIndex);
    } else {
      currentList.add(Application(
        id: DateTime.now().millisecondsSinceEpoch,
        job: job,
        status: ApplicationStatus.saved,
        createdAt: DateTime.now(),
      ));
    }
    
    state = AsyncValue.data(currentList);
  }
}

final seekerApplicationsProvider = StateNotifierProvider.family<SeekerApplicationsNotifier, AsyncValue<List<Application>>, String?>((ref, _) {
  return SeekerApplicationsNotifier(ref);
});
"""

with open('lib/features/seeker/applications/seeker_application_provider.dart', 'w') as f:
    f.write(new_content)
