import os

files = [
    'lib/features/employer/applicants/applicant_detail_screen.dart',
    'lib/features/employer/applicants/applicants_screen.dart',
    'lib/features/seeker/company/seeker_company_profile_screen.dart',
    'lib/features/seeker/apply/apply_screen.dart',
    'lib/features/employer/jobs/post_job_steps/step1_job_details.dart',
    'lib/features/employer/jobs/post_job_steps/step2_requirements.dart',
    'lib/features/employer/jobs/post_job_steps/step3_benefits.dart',
    'lib/features/employer/jobs/post_job_steps/step4_application.dart',
]

for fpath in files:
    if not os.path.exists(fpath): continue
    with open(fpath, 'r') as f:
        text = f.read()
    
    text = text.replace("const UJobLoading", "UJobLoading")
    
    with open(fpath, 'w') as f:
        f.write(text)

