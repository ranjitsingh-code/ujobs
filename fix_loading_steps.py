import os

steps = [
    'lib/features/employer/jobs/post_job_steps/step1_job_details.dart',
    'lib/features/employer/jobs/post_job_steps/step2_requirements.dart',
    'lib/features/employer/jobs/post_job_steps/step3_benefits.dart',
    'lib/features/employer/jobs/post_job_steps/step4_application.dart',
]

for fpath in steps:
    with open(fpath, 'r') as f: text = f.read()
    if "import '../../../../core/widgets/ujob_loading.dart';" not in text:
        text = text.replace("import '../../../../core/widgets/ujob_text_field.dart';", "import '../../../../core/widgets/ujob_text_field.dart';\nimport '../../../../core/widgets/ujob_loading.dart';")
    
    text = text.replace("return Center(child: CircularProgressIndicator(color: AppColors.primary));", "return const UJobLoading(count: 3);")
    with open(fpath, 'w') as f: f.write(text)

