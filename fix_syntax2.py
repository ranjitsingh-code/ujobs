import re

with open('lib/features/employer/company/company_profile_screen.dart', 'r') as f:
    text = f.read()

old_end = """                  SizedBox(height: 40.h),
                ],
              ),
            ),
    );
  }"""

new_end = """                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }"""

text = text.replace(old_end, new_end)

with open('lib/features/employer/company/company_profile_screen.dart', 'w') as f:
    f.write(text)
