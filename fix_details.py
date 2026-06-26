import re

with open('lib/features/employer/jobs/employer_job_detail_screen.dart', 'r') as f:
    text = f.read()

import_feature = "import '../../../core/providers/feature_flags_provider.dart';\n"
if "feature_flags_provider.dart" not in text:
    text = text.replace("import 'employer_job_provider.dart';", "import 'employer_job_provider.dart';\n" + import_feature)

text = text.replace("Widget build(BuildContext context) {", "Widget build(BuildContext context) {\n    final featureFlags = ref.watch(featureFlagsProvider);\n    final bool jobApprovalRequired = featureFlags.maybeWhen(\n      data: (flags) => flags.jobApprovalRequired,\n      orElse: () => false,\n    );")

# 1. PRIMARY ACTIONS - Publish Job
pat_publish = r"(if \(job.status == JobStatus.draft\) \.\.\.\[\n\s*UJobButton\(\n\s*label: context.l10n.publishJob1,)"
rep_publish = r"if (!jobApprovalRequired && job.status == JobStatus.draft) ...[\n              UJobButton(\n                label: context.l10n.publishJob1,"
text = re.sub(pat_publish, rep_publish, text)

# 2. SECONDARY ACTIONS - Republish Job
pat_republish = r"(if \(job.status == JobStatus.paused\) \.\.\.\[\n\s*UJobButton\(\n\s*label: context.l10n.republishJob,)"
rep_republish = r"if (!jobApprovalRequired && job.status == JobStatus.paused) ...[\n              UJobButton(\n                label: context.l10n.republishJob,"
text = re.sub(pat_republish, rep_republish, text)

# 3. SECONDARY ACTIONS - Reopen Job
pat_reopen = r"(if \(job.status == JobStatus.closed\) \.\.\.\[\n\s*UJobButton\(\n\s*label: context.l10n.reopenJob1,)"
rep_reopen = r"if (!jobApprovalRequired && job.status == JobStatus.closed) ...[\n              UJobButton(\n                label: context.l10n.reopenJob1,"
text = re.sub(pat_reopen, rep_reopen, text)

with open('lib/features/employer/jobs/employer_job_detail_screen.dart', 'w') as f:
    f.write(text)

