import re

with open('lib/features/employer/applicants/applicant_detail_screen.dart', 'r') as f:
    text = f.read()

target = """          // Sticky Bottom Bar
          _buildStickyBottomBar(applicant),
        ],
      ),
    );
  }"""

replacement = """          // Sticky Bottom Bar
          _buildStickyBottomBar(applicant),
        ],
      ),
      ),
    );
  }"""

text = text.replace(target, replacement)

with open('lib/features/employer/applicants/applicant_detail_screen.dart', 'w') as f:
    f.write(text)
