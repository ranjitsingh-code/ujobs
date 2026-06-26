import re

with open("lib/core/widgets/ujob_text_field.dart", "r") as f:
    content = f.read()

replacement = """              RichText(
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
              ),"""

content = re.sub(
    r"Text\(\s*widget\.label,\s*style:\s*AppText\.label\.copyWith\(color:\s*AppColors\.muted\),\s*\),",
    replacement,
    content
)

with open("lib/core/widgets/ujob_text_field.dart", "w") as f:
    f.write(content)
