import re

with open('lib/features/employer/jobs/employer_job_detail_screen.dart', 'r') as f:
    text = f.read()

target = """        data: (job) => ListView(
          padding: AppSpacing.pagePad,
          children: ["""

replacement = """        data: (job) => RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(employerJobDetailProvider(jobId));
            try {
              await ref.read(employerJobDetailProvider(jobId).future);
            } catch (_) {}
          },
          child: ListView(
            padding: AppSpacing.pagePad,
            physics: const AlwaysScrollableScrollPhysics(),
            children: ["""

if target in text:
    text = text.replace(target, replacement)
    with open('lib/features/employer/jobs/employer_job_detail_screen.dart', 'w') as f:
        f.write(text)
    print("Success")
else:
    print("Target not found")
