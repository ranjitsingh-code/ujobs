with open('lib/core/widgets/ujob_employer_job_actions_sheet.dart', 'r') as f:
    text = f.read()

# Fix Reopen / Publish / Reactivate which had swapped conditions
text = text.replace("if (onResume != null && job.status == JobStatus.paused)", "if (!jobApprovalRequired && onResume != null && job.status == JobStatus.paused)")
text = text.replace("if (onPublish != null && job.status == JobStatus.draft)", "if (!jobApprovalRequired && onPublish != null && job.status == JobStatus.draft)")
text = text.replace("if (onReopen != null && job.status == JobStatus.closed)", "if (!jobApprovalRequired && onReopen != null && job.status == JobStatus.closed)")

# Fix Close (should not show if already closed or rejected)
text = text.replace("if (onClose != null)", "if (onClose != null && job.status != JobStatus.closed && job.status != JobStatus.rejected)")

with open('lib/core/widgets/ujob_employer_job_actions_sheet.dart', 'w') as f:
    f.write(text)

