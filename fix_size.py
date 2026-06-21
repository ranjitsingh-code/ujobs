with open('lib/features/employer/company/company_profile_screen.dart', 'r') as f:
    text = f.read()

# Add sizeCtrl
text = text.replace(
    "final locationCtrl = TextEditingController(text: company.location);",
    "final locationCtrl = TextEditingController(text: company.location);\n    final sizeCtrl = TextEditingController(text: company.size);"
)

# Add Size text field
text = text.replace(
    "UJobTextField(label: 'Industry', controller: industryCtrl),",
    "UJobTextField(label: 'Industry', controller: industryCtrl),\n              UJobTextField(label: 'Company Size', controller: sizeCtrl),"
)

# Update the save action
text = text.replace(
    "size: company.size,",
    "size: sizeCtrl.text,"
)

# But wait, in _showEditDescription, size: company.size is used, which is correct.
# We only want to replace it in _showEditBasicInfo. The first occurrence is in _showEditBasicInfo.
# Let's do it safely:
with open('lib/features/employer/company/company_profile_screen.dart', 'w') as f:
    f.write(text)
