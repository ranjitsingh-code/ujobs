import re

file_path = 'lib/features/seeker/jobs/find_jobs_screen.dart'
with open(file_path, 'r') as f:
    content = f.read()

content = content.replace(
    "Widget build(BuildContext context, WidgetRef ref) {", 
    "Widget build(BuildContext context) {"
)

with open(file_path, 'w') as f:
    f.write(content)

