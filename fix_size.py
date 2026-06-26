import re

with open("lib/features/employer/company/company_profile_screen.dart", "r") as f:
    content = f.read()

# Fix Company Size options to use the backend value
content = content.replace("('1-10 Employees', '1-10 Employees')", "('1-10 employees', 'size_1_10')")
content = content.replace("('11-50 Employees', '11-50 Employees')", "('11-50 employees', 'size_11_50')")
content = content.replace("('51-200 Employees', '51-200 Employees')", "('51-200 employees', 'size_51_200')")
content = content.replace("('201-500 Employees', '201-500 Employees')", "('201-500 employees', 'size_201_500')")
content = content.replace("('501-1000 Employees', '501-1000 Employees')", "('501-1000 employees', 'size_501_1000')")
content = content.replace("('1000+ Employees', '1000+ Employees')", "('1000+ employees', 'size_1000_plus')")

with open("lib/features/employer/company/company_profile_screen.dart", "w") as f:
    f.write(content)

