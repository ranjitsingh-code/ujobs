import re

with open("lib/features/employer/jobs/employer_job_detail_screen.dart", "r") as f:
    emp = f.read()

# 1. Remove them from the summary block
emp = emp.replace("""                  if (job.languages != null && job.languages!.isNotEmpty)
                    _buildSummaryRow('Languages', job.languages!.join(', ')),""", "")
emp = emp.replace("""                  if (job.preferredSkills != null &&
                      job.preferredSkills!.isNotEmpty)
                    _buildSummaryRow(
                      'Preferred Skills',
                      job.preferredSkills!.join(', '),
                    ),""", "")

# 2. Add them to their own prominent sections after Requirements
requirements_marker = """            if (job.requiredSkills != null && job.requiredSkills!.isNotEmpty) ...[
              Text('Requirements', style: AppText.heading3),
              SizedBox(height: 12.h),
              UJobRichTextDisplay(content: job.requiredSkills!),
              SizedBox(height: 24.h),
            ],"""

new_sections = """            if (job.requiredSkills != null && job.requiredSkills!.isNotEmpty) ...[
              Text('Requirements', style: AppText.heading3),
              SizedBox(height: 12.h),
              UJobRichTextDisplay(content: job.requiredSkills!),
              SizedBox(height: 24.h),
            ],
            
            if (job.preferredSkills != null && job.preferredSkills!.isNotEmpty) ...[
              Text('Preferred Skills', style: AppText.heading3),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: job.preferredSkills!
                      .map(
                        (s) => Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: AppRadius.pill,
                          ),
                          child: Text(
                            s,
                            style: AppText.bodyMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              SizedBox(height: 24.h),
            ],

            if (job.languages != null && job.languages!.isNotEmpty) ...[
              Text('Languages Required', style: AppText.heading3),
              SizedBox(height: 12.h),
              Text(
                job.languages!.join(', '),
                style: AppText.body.copyWith(color: AppColors.text2),
              ),
              SizedBox(height: 24.h),
            ],"""

emp = emp.replace(requirements_marker, new_sections)

with open("lib/features/employer/jobs/employer_job_detail_screen.dart", "w") as f:
    f.write(emp)
