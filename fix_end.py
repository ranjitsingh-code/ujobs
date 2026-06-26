import re

with open('lib/features/employer/jobs/employer_job_detail_screen.dart', 'r') as f:
    text = f.read()

target = """              ),
          ],
        ),
      ),
    );
  }
}"""

replacement = """              ),
          ],
        ),
      ),
      ),
    );
  }
}"""

if target in text:
    text = text.replace(target, replacement)
    with open('lib/features/employer/jobs/employer_job_detail_screen.dart', 'w') as f:
        f.write(text)
    print("Success")
else:
    print("Target not found")
