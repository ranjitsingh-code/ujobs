import re

with open("lib/features/employer/company/company_profile_screen.dart", "r") as f:
    content = f.read()

# Fix string interpolation '${percentCompleted}%' to '$percentCompleted%'
content = content.replace("'${percentCompleted}%'", "'$percentCompleted%'")

with open("lib/features/employer/company/company_profile_screen.dart", "w") as f:
    f.write(content)

