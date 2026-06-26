import re

with open("lib/core/widgets/ujob_dropdown_field.dart", "r") as f:
    content = f.read()

# Add isRequired to UJobCountryDropdown
content = content.replace("final String? errorText;", "final String? errorText;\n  final bool isRequired;")
content = content.replace("this.errorText,", "this.errorText,\n    this.isRequired = false,")

# Add isRequired to UJobDropdownField invocation inside UJobCountryDropdown
content = content.replace("hint: l10n.countryHint,", "hint: l10n.countryHint,\n          isRequired: isRequired,")

# Fix l10n nullability in label
content = content.replace("label: l10n.country,", "label: l10n.country ?? '',")

with open("lib/core/widgets/ujob_dropdown_field.dart", "w") as f:
    f.write(content)

