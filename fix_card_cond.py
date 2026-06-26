import re

with open('lib/core/widgets/ujob_employer_job_card.dart', 'r') as f:
    text = f.read()

# Fix _ActionButton build method signature
pat_action = r"@override\n  Widget build\(BuildContext context, WidgetRef ref\) \{\n    final featureFlags = ref.watch\(featureFlagsProvider\);\n    final bool jobApprovalRequired = featureFlags.maybeWhen\(\n      data: \(flags\) => flags.jobApprovalRequired,\n      orElse: \(\) => false,\n    \);\n    return Expanded\("
rep_action = r"@override\n  Widget build(BuildContext context) {\n    return Expanded("
text = re.sub(pat_action, rep_action, text)

with open('lib/core/widgets/ujob_employer_job_card.dart', 'w') as f:
    f.write(text)

