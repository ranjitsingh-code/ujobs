with open('lib/features/employer/company/company_profile_screen.dart', 'r') as f:
    text = f.read()

import re

# Add imports
imports = """import '../../../core/models/company_profile.dart';
import '../dashboard/employer_dashboard_provider.dart';"""

text = text.replace("import '../employer_shell.dart';", "import '../employer_shell.dart';\n" + imports)

# Remove the private _Company class and _companyProvider
class_start = text.find('class _Company {')
provider_end = text.find('});\n', text.find('final _companyProvider')) + 4
text = text[:class_start] + text[provider_end:]

# Replace _Company with CompanyProfile
text = text.replace('_Company', 'CompanyProfile')
text = text.replace('_companyProvider', 'companyProfileProvider')

# Find Profile Completeness text '0%'
text = text.replace("'0%'", "'${(ref.watch(companyProfileCompletenessProvider) * 100).toInt()}%'")
# Find value: 0.0,
text = text.replace("value: 0.0,", "value: ref.watch(companyProfileCompletenessProvider),")

# Replace the stateless widget _CompanyHeader with ConsumerWidget
header_class_old = """class _CompanyHeader extends StatelessWidget {
  final CompanyProfile company;
  const _CompanyHeader({required this.company});

  @override
  Widget build(BuildContext context) => Container("""
header_class_new = """class _CompanyHeader extends ConsumerWidget {
  final CompanyProfile company;
  const _CompanyHeader({required this.company});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Container("""
text = text.replace(header_class_old, header_class_new)

with open('lib/features/employer/company/company_profile_screen.dart', 'w') as f:
    f.write(text)
