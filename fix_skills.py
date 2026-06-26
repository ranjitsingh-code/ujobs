import re

with open("lib/features/employer/jobs/employer_job_detail_screen.dart", "r") as f:
    lines = f.readlines()

insert_index = -1
for i, line in enumerate(lines):
    if "SizedBox(height: 32.h);" in line and "Description & Requirements" in "".join(lines[max(0, i-60):i]):
        insert_index = i + 1
        break

if insert_index != -1:
    to_insert = """            if (job.preferredSkills != null && job.preferredSkills!.isNotEmpty) ...[
              Text('Preferred Skills', style: AppText.heading3),
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
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
            ],
"""
    lines.insert(insert_index, to_insert)

with open("lib/features/employer/jobs/employer_job_detail_screen.dart", "w") as f:
    f.writelines(lines)
