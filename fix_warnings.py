import re

with open("lib/features/employer/company/company_profile_screen.dart", "r") as f:
    content = f.read()

# Fix unused import
content = content.replace("import '../../../../core/models/category.dart';", "")

# Fix unused catch clause
content = content.replace("on DioException catch (e) {", "on DioException {")

# Fix unnecessary string interpolation
content = content.replace('subtitle: _cityController.text.isNotEmpty ? "${_cityController.text}" : null,', 'subtitle: _cityController.text.isNotEmpty ? _cityController.text : null,')

# Fix unused local variable company
content = content.replace("final company = ref.watch(companyProfileProvider);", "")
content = content.replace("CompanyProfileHeader(\n              company: company,\n              completeness: completeness,\n            ),", "CompanyProfileHeader(\n              company: ref.watch(companyProfileProvider),\n              completeness: completeness,\n            ),")

# Fix withOpacity
content = content.replace("withOpacity(_isExpanded ? 0.08 : 0.02)", "withValues(alpha: _isExpanded ? 0.08 : 0.02)")

with open("lib/features/employer/company/company_profile_screen.dart", "w") as f:
    f.write(content)

