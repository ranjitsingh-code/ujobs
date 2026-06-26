import re

with open("lib/core/widgets/ujob_phone_number_field.dart", "r") as f:
    content = f.read()

# Fix _kCountries undefined identifier
content = content.replace("late List<Country> _filtered = _kCountries;", "late List<Country> _filtered;")

with open("lib/core/widgets/ujob_phone_number_field.dart", "w") as f:
    f.write(content)

