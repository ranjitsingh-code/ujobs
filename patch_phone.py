import re

with open("lib/core/widgets/ujob_phone_number_field.dart", "r") as f:
    content = f.read()

# Add isRequired parameter
content = re.sub(
    r"(required this\.controller,\s*\n)",
    r"\1    this.isRequired = false,\n",
    content
)
content = re.sub(
    r"(final String label;\s*\n)",
    r"\1  final bool isRequired;\n",
    content
)

# Replace Text(widget.label, style: AppText.label.copyWith(color: AppColors.muted))
replacement = """RichText(
            text: TextSpan(
              text: widget.label,
              style: AppText.label.copyWith(color: AppColors.muted),
              children: [
                if (widget.isRequired)
                  TextSpan(
                    text: ' *',
                    style: AppText.label.copyWith(color: AppColors.error),
                  ),
              ],
            ),
          )"""

content = re.sub(
    r"Text\(widget\.label,\s*style:\s*AppText\.label\.copyWith\(color:\s*AppColors\.muted\)\)",
    replacement,
    content
)

with open("lib/core/widgets/ujob_phone_number_field.dart", "w") as f:
    f.write(content)
