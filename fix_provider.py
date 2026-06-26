import re

with open('lib/core/providers/job_form_options_provider.dart', 'r') as f:
    text = f.read()

text = text.replace(
    "import '../api/dio_client.dart';",
    "import '../api/dio_client.dart';\nimport 'auth_provider.dart';"
)

with open('lib/core/providers/job_form_options_provider.dart', 'w') as f:
    f.write(text)

