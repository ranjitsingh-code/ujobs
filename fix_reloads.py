import re

with open('lib/features/employer/jobs/post_job_screen.dart', 'r') as f:
    text = f.read()

import_target = "import 'employer_job_provider.dart';"
import_replace = "import 'employer_job_provider.dart';\nimport '../dashboard/employer_dashboard_provider.dart';"
if import_target in text and "employer_dashboard_provider.dart" not in text:
    text = text.replace(import_target, import_replace)

success_target = """      EasyLoading.dismiss();
      if (mounted) {
        UJobToast.success(context, targetStatus == 'draft' ? 'Job saved to drafts' : 'Job posted successfully');
        context.pop();
      }"""

success_replace = """      EasyLoading.dismiss();
      
      // Reload Dashboard & Jobs lists
      ref.invalidate(employerDashboardProvider);
      ref.invalidate(employerJobsProvider);
      
      // Clear wizard state for next time
      ref.invalidate(postJobWizardProvider);

      if (mounted) {
        UJobToast.success(context, targetStatus == 'draft' ? 'Job saved to drafts' : 'Job posted successfully');
        context.pop();
      }"""

if success_target in text:
    text = text.replace(success_target, success_replace)
    
with open('lib/features/employer/jobs/post_job_screen.dart', 'w') as f:
    f.write(text)
    
