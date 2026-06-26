import re

with open('lib/features/employer/applicants/employer_applicant_provider.dart', 'r') as f:
    text = f.read()

text = text.replace("return await service.getApplicantDetails(jobId, applicant.id);", "return await service.getApplicantDetails(applicant.id);")

with open('lib/features/employer/applicants/employer_applicant_provider.dart', 'w') as f:
    f.write(text)

