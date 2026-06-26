import re

# Fix my_jobs_screen.dart
with open('lib/features/employer/jobs/my_jobs_screen.dart', 'r') as f:
    text = f.read()
text = text.replace("onClose: (job.status != JobStatus.closed && job.status != JobStatus.rejected) ? () => _confirmClose(context, ref, job) : null,", "onClose: () => _confirmClose(context, ref, job),")
with open('lib/features/employer/jobs/my_jobs_screen.dart', 'w') as f:
    f.write(text)

# Fix employer_dashboard_screen.dart
with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'r') as f:
    text = f.read()

target = """                          onClose: (job.status != JobStatus.closed && job.status != JobStatus.rejected) ? () {
                            showDialog("""
replacement = """                          onClose: () {
                            showDialog("""
text = text.replace(target, replacement)
with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'w') as f:
    f.write(text)

# Also fix the label in UJobEmployerJobActionsSheet back to l10n.closeJob1
with open('lib/core/widgets/ujob_employer_job_actions_sheet.dart', 'r') as f:
    text = f.read()
text = text.replace("label: 'Close Job',", "label: context.l10n.closeJob1,")
with open('lib/core/widgets/ujob_employer_job_actions_sheet.dart', 'w') as f:
    f.write(text)

# Fix label in UJobEmployerJobCard back to l10n.closeJob1
with open('lib/core/widgets/ujob_employer_job_card.dart', 'r') as f:
    text = f.read()
text = text.replace("label: 'Close Job',", "label: l10n.closeJob1,")
with open('lib/core/widgets/ujob_employer_job_card.dart', 'w') as f:
    f.write(text)

