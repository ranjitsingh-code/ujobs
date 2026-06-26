import re

with open('lib/features/employer/jobs/employer_job_detail_screen.dart', 'r') as f:
    text = f.read()

# Undo the wrong build method replacements
text = text.replace("""Widget build(BuildContext context) {
    final featureFlags = ref.watch(featureFlagsProvider);
    final bool jobApprovalRequired = featureFlags.maybeWhen(
      data: (flags) => flags.jobApprovalRequired,
      orElse: () => false,
    );""", """Widget build(BuildContext context) {""")

# Add the correct one to _EmployerJobDetailScreenState build method
pat_build = r"(\s*Widget build\(BuildContext context, WidgetRef ref\) \{\n\s*final jobAsync = ref.watch\(employerJobDetailProvider\(jobId\)\);)"
rep_build = r"\1\n    final featureFlags = ref.watch(featureFlagsProvider);\n    final bool jobApprovalRequired = featureFlags.maybeWhen(\n      data: (flags) => flags.jobApprovalRequired,\n      orElse: () => false,\n    );"
text = re.sub(pat_build, rep_build, text)

with open('lib/features/employer/jobs/employer_job_detail_screen.dart', 'w') as f:
    f.write(text)

