import re

with open("lib/core/widgets/ujob_phone_number_field.dart", "r") as f:
    content = f.read()

# Remove the flag and space from the phone number field row
content = content.replace("Text(_selected.flag, style: TextStyle(fontSize: 18.sp)),\n                      SizedBox(width: 6.w),", "")

with open("lib/core/widgets/ujob_phone_number_field.dart", "w") as f:
    f.write(content)

