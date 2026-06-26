import re

with open('lib/features/employer/applicants/applicant_detail_screen.dart', 'r') as f:
    text = f.read()

target = """    Applicant initialApplicant;
    if (widget.applicant != null) {
      initialApplicant = widget.applicant!;
    } else {
      final applicants = ref.watch(employerApplicantsProvider);
      initialApplicant = applicants.firstWhere(
        (a) => a.id == widget.applicantId,
        orElse: () => applicants.first,
      );
    }"""

replacement = """    Applicant initialApplicant;
    if (widget.applicant != null) {
      initialApplicant = widget.applicant!;
    } else {
      final asyncApplicants = ref.watch(employerApplicantsProvider);
      final applicants = asyncApplicants.value ?? [];
      if (applicants.isEmpty) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      initialApplicant = applicants.firstWhere(
        (a) => a.id == widget.applicantId,
        orElse: () => applicants.first,
      );
    }"""

text = text.replace(target, replacement)

with open('lib/features/employer/applicants/applicant_detail_screen.dart', 'w') as f:
    f.write(text)
