import re

with open('lib/features/employer/company/company_profile_screen.dart', 'r') as f:
    text = f.read()

old_inkwell_child = """            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Row(
                children: [
                  Container("""

new_inkwell_child = """            child: Padding(
              padding: EdgeInsets.fromLTRB(20.r, 20.r, 20.r, _isExpanded ? 12.r : 20.r),
              child: Row(
                children: [
                  Container("""

text = text.replace(old_inkwell_child, new_inkwell_child)

with open('lib/features/employer/company/company_profile_screen.dart', 'w') as f:
    f.write(text)
