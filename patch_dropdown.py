import re

with open("lib/core/widgets/ujob_dropdown_field.dart", "r") as f:
    content = f.read()

# Add isRequired parameter
content = re.sub(
    r"(required this\.options,\s*\n)",
    r"\1    this.isRequired = false,\n",
    content
)
content = re.sub(
    r"(final String label;\s*\n)",
    r"\1  final bool isRequired;\n",
    content
)
# We also have UJobDropdownField and UJobSearchableDropdownField, we should patch both.
content = re.sub(
    r"(required String label,\s*\n)",
    r"\1    bool isRequired = false,\n",
    content
)

# Replace Text(label, style: AppText.label.copyWith(color: AppColors.muted))
replacement = """RichText(
            text: TextSpan(
              text: label,
              style: AppText.label.copyWith(color: AppColors.muted),
              children: [
                if (isRequired)
                  TextSpan(
                    text: ' *',
                    style: AppText.label.copyWith(color: AppColors.error),
                  ),
              ],
            ),
          )"""

content = re.sub(
    r"Text\(label,\s*style:\s*AppText\.label\.copyWith\(color:\s*AppColors\.muted\)\)",
    replacement,
    content
)

with open("lib/core/widgets/ujob_dropdown_field.dart", "w") as f:
    f.write(content)
