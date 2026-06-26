import re

with open('lib/features/employer/applicants/employer_applicant_service.dart', 'r') as f:
    text = f.read()

target = """  Future<List<Applicant>> getAllApplicants() async {"""

replacement = """  Future<void> updateApplicantStage(String appId, String stage) async {
    try {
      await _client.dio.patch(
        '/employer/applications/$appId/stage',
        data: {'stage': stage.toLowerCase()},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Applicant>> getAllApplicants() async {"""

text = text.replace(target, replacement)

with open('lib/features/employer/applicants/employer_applicant_service.dart', 'w') as f:
    f.write(text)

