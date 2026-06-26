import re

with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'r') as f:
    text = f.read()

target = "'You are not allowed to post a job until you verify your profile. Please wait for the admin to verify your account.'"
replacement = "'Your company profile must be 100% complete and verified by an admin before you can post jobs. If you have already completed your profile, please wait for admin approval.'"

text = text.replace(target, replacement)

with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'w') as f:
    f.write(text)


with open('lib/features/employer/jobs/my_jobs_screen.dart', 'r') as f:
    text = f.read()

target2 = "'Your employer profile must be verified before you can post a new job. Please update your company profile to proceed.'"

text = text.replace(target2, replacement)

with open('lib/features/employer/jobs/my_jobs_screen.dart', 'w') as f:
    f.write(text)

