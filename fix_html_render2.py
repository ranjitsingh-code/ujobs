import re

with open('lib/features/employer/applicants/applicant_detail_screen.dart', 'r') as f:
    text = f.read()

target = """            child: Text(
              applicant.coverLetter!,
              style: AppText.body.copyWith(color: AppColors.text2, height: 1.6),
            ),"""

replacement = """            child: UJobRichTextDisplay(content: applicant.coverLetter!),"""

text = text.replace(target, replacement)

with open('lib/features/employer/applicants/applicant_detail_screen.dart', 'w') as f:
    f.write(text)
