import re

with open("lib/features/employer/company/company_profile_screen.dart", "r") as f:
    content = f.read()

# Replace the subtitle construction to remove size
old_subtitle = """    // Construct the subtitle (Industry · Size)
    List<String> subtitleParts = [];
    if (company.industry != null && company.industry!.isNotEmpty) {
      subtitleParts.add(company.industry!);
    }
    if (company.size != null && company.size!.isNotEmpty) {
      subtitleParts.add(company.size!);
    }"""

new_subtitle = """    // Construct the subtitle (Industry)
    List<String> subtitleParts = [];
    if (company.industry != null && company.industry!.isNotEmpty) {
      subtitleParts.add(company.industry!);
    }"""

content = content.replace(old_subtitle, new_subtitle)

with open("lib/features/employer/company/company_profile_screen.dart", "w") as f:
    f.write(content)

