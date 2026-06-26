with open('lib/core/widgets/ujob_employer_job_actions_sheet.dart', 'r') as f:
    text = f.read()

text = text.replace("if (job.status == JobStatus.paused && onResume != null)", "if (!jobApprovalRequired && job.status == JobStatus.paused && onResume != null)")
text = text.replace("if (job.status == JobStatus.draft && onPublish != null)", "if (!jobApprovalRequired && job.status == JobStatus.draft && onPublish != null)")
text = text.replace("if (job.status == JobStatus.closed && onReopen != null)", "if (!jobApprovalRequired && job.status == JobStatus.closed && onReopen != null)")

with open('lib/core/widgets/ujob_employer_job_actions_sheet.dart', 'w') as f:
    f.write(text)

