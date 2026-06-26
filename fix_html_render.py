import re

with open('lib/features/employer/applicants/applicant_detail_screen.dart', 'r') as f:
    text = f.read()

import_statement = "import '../../../core/widgets/ujob_rich_text_display.dart';"
if import_statement not in text:
    text = text.replace("import 'package:flutter/material.dart';", f"import 'package:flutter/material.dart';\n{import_statement}")

target_about = """          _buildSectionCard(
            'About',
            Text(
              applicant.about!,
              style: AppText.body.copyWith(color: AppColors.text2, height: 1.6),
            ),
          ),"""

replacement_about = """          _buildSectionCard(
            'About',
            UJobRichTextDisplay(content: applicant.about!),
          ),"""

text = text.replace(target_about, replacement_about)

target_cover_letter = """          _buildSectionCard(
            'Cover Letter',
            Text(
              applicant.coverLetter!,
              style: AppText.body.copyWith(color: AppColors.text2, height: 1.6),
            ),
          ),"""

replacement_cover_letter = """          _buildSectionCard(
            'Cover Letter',
            UJobRichTextDisplay(content: applicant.coverLetter!),
          ),"""

text = text.replace(target_cover_letter, replacement_cover_letter)

with open('lib/features/employer/applicants/applicant_detail_screen.dart', 'w') as f:
    f.write(text)
