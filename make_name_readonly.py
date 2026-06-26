import re

with open("lib/features/employer/company/company_profile_screen.dart", "r") as f:
    content = f.read()

old_name_field = """                          UJobTextField(
                            label: context.l10n.companyNameLabel,
                            isRequired: true,
                            controller: _nameController,
                          ),"""

new_name_field = """                          UJobTextField(
                            label: context.l10n.companyNameLabel,
                            isRequired: true,
                            readOnly: true,
                            controller: _nameController,
                          ),"""

content = content.replace(old_name_field, new_name_field)

with open("lib/features/employer/company/company_profile_screen.dart", "w") as f:
    f.write(content)

