import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/applicant.dart';
import 'employer_applicant_service.dart';

final jobApplicantsProvider = AsyncNotifierProvider.family<JobApplicantsNotifier, List<Applicant>, int>(JobApplicantsNotifier.new);

class JobApplicantsNotifier extends FamilyAsyncNotifier<List<Applicant>, int> {
  @override
  Future<List<Applicant>> build(int arg) async {
    final service = ref.watch(employerApplicantServiceProvider);
    return await service.getJobApplicants(arg);
  }

  void updateStatusLocally(String applicantId, String newStatus) {
    if (state.value == null) return;
    state = AsyncValue.data(
      state.value!.map((applicant) {
        if (applicant.id == applicantId) {
          return applicant.copyWith(status: newStatus);
        }
        return applicant;
      }).toList(),
    );
  }
}

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

  Future<void> updateStatus(String applicantId, String newStatus, {String? jobId}) async {
    try {
      final service = ref.read(employerApplicantServiceProvider);
      await service.updateApplicantStage(applicantId, newStatus);
      
      // Update local state for immediate feedback on "All Applicants"
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

      // Attempt to find jobId from local state if not provided
      if (jobId == null) {
        final applicant = state.value?.cast<Applicant?>().firstWhere((a) => a?.id == applicantId, orElse: () => null);
        jobId = applicant?.jobId;
      }
      
      if (jobId != null) {
        final parsedJobId = int.tryParse(jobId) ?? 0;
        if (parsedJobId != 0) {
          ref.read(jobApplicantsProvider(parsedJobId).notifier).updateStatusLocally(applicantId, newStatus);
        }
      } else {
        ref.invalidate(jobApplicantsProvider);
      }
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
