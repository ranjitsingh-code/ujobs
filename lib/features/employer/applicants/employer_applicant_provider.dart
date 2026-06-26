import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/applicant.dart';
import 'employer_applicant_service.dart';

final jobApplicantsProvider = FutureProvider.family<List<Applicant>, int>((ref, jobId) async {
  final service = ref.watch(employerApplicantServiceProvider);
  return await service.getJobApplicants(jobId);
});

final employerApplicantsProvider =
    AsyncNotifierProvider<EmployerApplicantsNotifier, List<Applicant>>(() {
      return EmployerApplicantsNotifier();
    });

class EmployerApplicantsNotifier extends AsyncNotifier<List<Applicant>> {
  @override
  Future<List<Applicant>> build() async {
    final service = ref.watch(employerApplicantServiceProvider);
    return await service.getAllApplicants();
  }

  Future<void> updateStatus(String applicantId, String newStatus) async {
    try {
      final service = ref.read(employerApplicantServiceProvider);
      await service.updateApplicantStage(applicantId, newStatus);
      
      // Update local state for immediate feedback
      if (state.value != null) {
        state = AsyncValue.data(
          state.value!.map((applicant) {
            if (applicant.id == applicantId) {
              return applicant.copyWith(status: newStatus);
            }
            return applicant;
          }).toList(),
        );
      }
      
      // Force a refresh of the single applicant detail provider to pull any new data
      ref.invalidate(singleApplicantProvider);
    } catch (e) {
      rethrow;
    }
  }

  void markAsMessaged(String applicantId) {
    if (state.value == null) return;
    state = AsyncValue.data(
      state.value!.map((applicant) {
        if (applicant.id == applicantId) {
          return applicant.copyWith(hasMessaged: true);
        }
        return applicant;
      }).toList(),
    );
  }
}

final singleApplicantProvider = FutureProvider.family<Applicant, Applicant>((ref, applicant) async {
  final service = ref.watch(employerApplicantServiceProvider);
  try {
    // applicant.jobId must be an integer, but it's a string, so parse it
    final jobId = int.tryParse(applicant.jobId) ?? 0;
    if (jobId == 0) return applicant; // Fallback if no valid job ID
    return await service.getApplicantDetails(applicant.id);
  } catch (e) {
    // If the API call fails, just return the applicant data we already have
    return applicant;
  }
});
