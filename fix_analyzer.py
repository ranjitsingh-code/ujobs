import re

# Fix step1_job_details.dart
with open('lib/features/employer/jobs/post_job_steps/step1_job_details.dart', 'r') as f:
    text = f.read()
text = text.replace("import '../../../../core/widgets/ujob_country_dropdown.dart';\n", "")
with open('lib/features/employer/jobs/post_job_steps/step1_job_details.dart', 'w') as f:
    f.write(text)

# Fix step6_review.dart
with open('lib/features/employer/jobs/post_job_steps/step6_review.dart', 'r') as f:
    text = f.read()
text = text.replace("import '../../../../core/widgets/ujob_rich_text_editor.dart';", "import '../../../../core/widgets/ujob_rich_text_display.dart';")
with open('lib/features/employer/jobs/post_job_steps/step6_review.dart', 'w') as f:
    f.write(text)

