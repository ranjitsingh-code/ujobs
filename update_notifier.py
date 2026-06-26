import re

with open('lib/features/employer/applicants/employer_applicant_provider.dart', 'r') as f:
    text = f.read()

target = """  void updateStatus(String applicantId, String newStatus) {
    if (state.value == null) return;
    state = AsyncValue.data(
      state.value!.map((applicant) {
        if (applicant.id == applicantId) {
          return applicant.copyWith(status: newStatus);
        }
        return applicant;
      }).toList(),
    );
  }"""

replacement = """  Future<void> updateStatus(String applicantId, String newStatus) async {
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
  }"""

text = text.replace(target, replacement)

with open('lib/features/employer/applicants/employer_applicant_provider.dart', 'w') as f:
    f.write(text)

