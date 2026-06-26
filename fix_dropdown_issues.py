import re

with open("lib/core/widgets/ujob_dropdown_field.dart", "r") as f:
    content = f.read()

# Fix isRequired duplication in UJobDropdownField class definition
content = re.sub(r"  final bool isRequired;\n  final T\? value;\n  final String\? hint;\n  final List<\(String label, T value\)> options;\n  final ValueChanged<T\?> onChanged;\n  final String\? errorText;\n  final bool isRequired;\n", r"  final bool isRequired;\n  final T? value;\n  final String? hint;\n  final List<(String label, T value)> options;\n  final ValueChanged<T?> onChanged;\n  final String? errorText;\n", content)

# Fix duplicate parameters in constructor
content = re.sub(r"    this\.isRequired = false,\n    required this\.onChanged,\n    this\.value,\n    this\.hint,\n    this\.errorText,\n    this\.isRequired = false,\n", r"    this.isRequired = false,\n    required this.onChanged,\n    this.value,\n    this.hint,\n    this.errorText,\n", content)

with open("lib/core/widgets/ujob_dropdown_field.dart", "w") as f:
    f.write(content)

