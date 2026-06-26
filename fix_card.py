import re

with open('lib/core/widgets/ujob_employer_job_card.dart', 'r') as f:
    text = f.read()

# Change to ConsumerWidget
import_riverpod = "import 'package:flutter_riverpod/flutter_riverpod.dart';\nimport '../providers/feature_flags_provider.dart';\n"
if "flutter_riverpod.dart" not in text:
    text = text.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\n" + import_riverpod)

text = text.replace("class UJobEmployerJobCard extends StatelessWidget {", "class UJobEmployerJobCard extends ConsumerWidget {")
text = text.replace("Widget build(BuildContext context) {", "Widget build(BuildContext context, WidgetRef ref) {\n    final featureFlags = ref.watch(featureFlagsProvider);\n    final bool jobApprovalRequired = featureFlags.maybeWhen(\n      data: (flags) => flags.jobApprovalRequired,\n      orElse: () => false,\n    );")

# Update inline button visibility logic
# 1. onResume
pat_resume = r"(if \(job.status == JobStatus.paused && onResume != null\))"
rep_resume = r"if (!jobApprovalRequired && job.status == JobStatus.paused && onResume != null)"
text = re.sub(pat_resume, rep_resume, text)

# 2. onPublish
pat_publish = r"(if \(job.status == JobStatus.draft && onPublish != null\))"
rep_publish = r"if (!jobApprovalRequired && job.status == JobStatus.draft && onPublish != null)"
text = re.sub(pat_publish, rep_publish, text)

# 3. onReopen
pat_reopen = r"(if \(job.status == JobStatus.closed && onReopen != null\))"
rep_reopen = r"if (!jobApprovalRequired && job.status == JobStatus.closed && onReopen != null)"
text = re.sub(pat_reopen, rep_reopen, text)

with open('lib/core/widgets/ujob_employer_job_card.dart', 'w') as f:
    f.write(text)

