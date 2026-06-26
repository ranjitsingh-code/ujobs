import re

with open("lib/features/employer/jobs/employer_job_provider.dart", "r") as f:
    content = f.read()

old_import = "import '../../../core/api/dio_client.dart';"
new_import = "import '../../../core/api/dio_client.dart';\nimport '../../../core/providers/auth_provider.dart';" # Assuming dioClientProvider is here

if "dioClientProvider" in content and "auth_provider.dart" not in content:
    content = content.replace(old_import, new_import)
    with open("lib/features/employer/jobs/employer_job_provider.dart", "w") as f:
        f.write(content)
