import re

with open('lib/features/employer/jobs/post_job_screen.dart', 'r') as f:
    text = f.read()

target = """UJobToast.success(context, targetStatus == 'draft' ? 'Job saved to drafts' : 'Job posted successfully');"""
replacement = """UJobToast.success(context, targetStatus == 'draft' ? 'Job saved to drafts' : (_isEditing ? 'Job updated successfully' : 'Job posted successfully'));"""

if target in text:
    text = text.replace(target, replacement)
    with open('lib/features/employer/jobs/post_job_screen.dart', 'w') as f:
        f.write(text)
    print("Success")
else:
    print("Target not found")
