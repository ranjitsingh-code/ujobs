import re

with open('lib/features/employer/applicants/employer_applicant_service.dart', 'r') as f:
    text = f.read()

target = """  Future<Applicant> getApplicantDetails(int jobId, String applicantId) async {
    try {
      final list = await getJobApplicants(jobId);
      return list.firstWhere((a) => a.id == applicantId);
    } catch (e) {
      rethrow;
    }
  }"""

replacement = """  Future<Applicant> getApplicantDetails(String applicantId) async {
    try {
      final response = await _client.dio.get('/employer/applicants/$applicantId');
      final data = response.data['data'];
      return Applicant.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }"""

text = text.replace(target, replacement)

with open('lib/features/employer/applicants/employer_applicant_service.dart', 'w') as f:
    f.write(text)

