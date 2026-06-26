import re

with open('lib/features/employer/jobs/post_job_steps/step4_application.dart', 'r') as f:
    text = f.read()

target = """    if (options == null) {
      return UJobLoading(count: 3);
    }
    
    final currentApplyVia = state.applyVia.isEmpty && options.applicationMethods.isNotEmpty 
        ? options.applicationMethods.first.value 
        : state.applyVia;
    final currentResume = state.resumeRequirement.isEmpty && options.resumeRequirements.isNotEmpty 
        ? options.resumeRequirements.first.value 
        : state.resumeRequirement;
    final currentCoverLetter = state.coverLetterRequirement.isEmpty && options.coverLetterPolicies.isNotEmpty 
        ? options.coverLetterPolicies.first.value 
        : state.coverLetterRequirement;"""

replacement = """    if (options == null) {
      return UJobLoading(count: 3);
    }
    
    if (state.applyVia.isEmpty && options.applicationMethods.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.updateField(state.copyWith(
          applyVia: options.applicationMethods.first.value,
          resumeRequirement: options.resumeRequirements.isNotEmpty ? options.resumeRequirements.first.value : state.resumeRequirement,
          coverLetterRequirement: options.coverLetterPolicies.isNotEmpty ? options.coverLetterPolicies.first.value : state.coverLetterRequirement,
        ));
      });
    }

    final currentApplyVia = state.applyVia.isEmpty && options.applicationMethods.isNotEmpty 
        ? options.applicationMethods.first.value 
        : state.applyVia;
    final currentResume = state.resumeRequirement.isEmpty && options.resumeRequirements.isNotEmpty 
        ? options.resumeRequirements.first.value 
        : state.resumeRequirement;
    final currentCoverLetter = state.coverLetterRequirement.isEmpty && options.coverLetterPolicies.isNotEmpty 
        ? options.coverLetterPolicies.first.value 
        : state.coverLetterRequirement;"""

text = text.replace(target, replacement)

with open('lib/features/employer/jobs/post_job_steps/step4_application.dart', 'w') as f:
    f.write(text)

with open('lib/features/employer/jobs/post_job_wizard_provider.dart', 'r') as f:
    prov_text = f.read()

prov_text = prov_text.replace("this.resumeRequirement = 'Required',", "this.resumeRequirement = '',")
prov_text = prov_text.replace("this.coverLetterRequirement = 'Optional',", "this.coverLetterRequirement = '',")

with open('lib/features/employer/jobs/post_job_wizard_provider.dart', 'w') as f:
    f.write(prov_text)

