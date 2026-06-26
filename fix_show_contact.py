import re

with open("lib/features/employer/company/company_profile_screen.dart", "r") as f:
    content = f.read()

# Add variable
if "bool _showContactInfo" not in content:
    content = content.replace("  String? _selectedWorkType;", "  String? _selectedWorkType;\n  bool _showContactInfo = false;")

# Populate in _initFromProvider
old_init = """    _linkedInController.text = company.linkedInUrl ?? '';
    _facebookController.text = company.facebookUrl ?? '';
    if (mounted) setState(() {});"""

new_init = """    _linkedInController.text = company.linkedInUrl ?? '';
    _facebookController.text = company.facebookUrl ?? '';
    _showContactInfo = company.showContactInfo;
    if (mounted) setState(() {});"""

content = content.replace(old_init, new_init)

with open("lib/features/employer/company/company_profile_screen.dart", "w") as f:
    f.write(content)

