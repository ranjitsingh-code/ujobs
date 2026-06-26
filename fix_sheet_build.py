import re

with open('lib/core/widgets/ujob_employer_job_actions_sheet.dart', 'r') as f:
    text = f.read()

pat = r"@override\n  Widget build\(BuildContext context, WidgetRef ref\) \{\n    final featureFlags = ref.watch\(featureFlagsProvider\);\n    final bool jobApprovalRequired = featureFlags.maybeWhen\(\n      data: \(flags\) => flags.jobApprovalRequired,\n      orElse: \(\) => false,\n    \);\n    final foreground = color"
rep = r"@override\n  Widget build(BuildContext context) {\n    final foreground = color"
text = re.sub(pat, rep, text)

with open('lib/core/widgets/ujob_employer_job_actions_sheet.dart', 'w') as f:
    f.write(text)

