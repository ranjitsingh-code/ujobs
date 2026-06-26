import re

file_path = 'lib/features/seeker/company/seeker_company_profile_screen.dart'
with open(file_path, 'r') as f:
    content = f.read()

# 1. Add import
if 'l10n_extensions.dart' not in content:
    content = content.replace("import 'package:hugeicons/hugeicons.dart';", "import 'package:hugeicons/hugeicons.dart';\nimport '../../../../core/utils/l10n_extensions.dart';")

# 2. Replace strings
replacements = [
    ("title: 'Company Profile'", "title: context.l10n.companyProfile"),
    ("?? 'Company'", "?? context.l10n.companyProfile"),
    ("label: 'Follow'", "label: context.l10n.follow"),
    ("label: 'Website'", "label: context.l10n.website"),
    ("Tab(text: 'About')", "Tab(text: context.l10n.aboutCompany)"),
    ("Tab(text: 'Jobs')", "Tab(text: context.l10n.jobs)"),
    ("Text('About Company', style: AppText.heading3)", "Text(context.l10n.aboutCompany, style: AppText.heading3)"),
    ("?? 'No description available.'", "?? context.l10n.noDescriptionAvailable"),
    ("Text('Industry', style: AppText.heading3)", "Text(context.l10n.industryLabel, style: AppText.heading3)"),
    ("Text('Company Size', style: AppText.heading3)", "Text(context.l10n.companySize, style: AppText.heading3)"),
    ("'No open positions.'", "context.l10n.noOpenPositions"),
    ("'Error loading jobs'", "context.l10n.errorLoadingJobs")
]

for old, new in replacements:
    content = content.replace(old, new)

with open(file_path, 'w') as f:
    f.write(content)
