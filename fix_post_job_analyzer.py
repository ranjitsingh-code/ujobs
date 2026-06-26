import re

with open('lib/features/employer/jobs/post_job_screen.dart', 'r') as f:
    text = f.read()

imports = """import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../core/api/api_endpoints.dart';
"""
if "import 'package:flutter_easyloading/flutter_easyloading.dart';" not in text:
    text = text.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\n" + imports)

# Wrap BuildContext uses in mounted check
text = text.replace(
    "UJobToast.success(context, targetStatus == 'draft' ? 'Job saved to drafts' : 'Job posted successfully');\n      \n      // Optionally refresh provider list here\n      // ref.invalidate(employerJobsProvider);\n      \n      context.pop();",
    "if (mounted) {\n        UJobToast.success(context, targetStatus == 'draft' ? 'Job saved to drafts' : 'Job posted successfully');\n        context.pop();\n      }"
)

text = text.replace(
    "UJobToast.error(context, 'Failed to save job. Please try again.');",
    "if (mounted) UJobToast.error(context, 'Failed to save job. Please try again.');"
)

with open('lib/features/employer/jobs/post_job_screen.dart', 'w') as f:
    f.write(text)

