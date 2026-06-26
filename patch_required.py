with open("lib/features/employer/company/company_profile_screen.dart", "r") as f:
    content = f.read()

# Add isRequired: true
content = content.replace(
    'label: context.l10n.companyNameLabel,',
    'label: context.l10n.companyNameLabel,\n                    isRequired: true,'
)
content = content.replace(
    'label: context.l10n.industryLabel,',
    'label: context.l10n.industryLabel,\n                    isRequired: true,'
)
content = content.replace(
    'label: "Contact Name",',
    'label: "Contact Name",\n                    isRequired: true,'
)
content = content.replace(
    'label: "Contact Email",',
    'label: "Contact Email",\n                    isRequired: true,'
)
content = content.replace(
    'label: "Contact Phone",',
    'label: "Contact Phone",\n                    isRequired: true,'
)

with open("lib/features/employer/company/company_profile_screen.dart", "w") as f:
    f.write(content)
