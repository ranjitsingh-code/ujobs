import re

with open("lib/features/seeker/jobs/seeker_job_detail_screen.dart", "r") as f:
    seek = f.read()

seek = seek.replace(
"""                              job.description!.startsWith('{')
                                  ? UJobRichTextDisplay(
                                      content: job.description!,
                                    )
                                  : Text(
                                      job.description!,
                                      style: AppText.body.copyWith(
                                        color: AppColors.text2,
                                        height: 1.5,
                                      ),
                                    ),""",
"""                              UJobRichTextDisplay(content: job.description!),"""
)

seek = seek.replace(
"""                                Text(
                                  job.responsibilities!,
                                  style: AppText.body.copyWith(
                                    color: AppColors.text2,
                                    height: 1.5,
                                  ),
                                ),""",
"""                                UJobRichTextDisplay(content: job.responsibilities!),"""
)

seek = seek.replace(
"""                                Text(
                                  job.requiredSkills!,
                                  style: AppText.body.copyWith(
                                    color: AppColors.text2,
                                    height: 1.5,
                                  ),
                                ),""",
"""                                UJobRichTextDisplay(content: job.requiredSkills!),"""
)

with open("lib/features/seeker/jobs/seeker_job_detail_screen.dart", "w") as f:
    f.write(seek)
