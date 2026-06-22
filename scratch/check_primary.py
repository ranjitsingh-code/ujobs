import os
import re

file_path = 'lib/features/seeker/jobs/find_jobs_screen.dart'
with open(file_path, 'r') as f:
    content = f.read()

# Replace all SliverAppBar( to SliverAppBar(primary: false,
content = content.replace("SliverAppBar(", "SliverAppBar(\n                primary: false,")

with open(file_path, 'w') as f:
    f.write(content)
print("Added primary: false to SliverAppBars")
