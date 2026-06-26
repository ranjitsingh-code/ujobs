import re

with open('lib/features/employer/jobs/employer_job_detail_screen.dart', 'r') as f:
    text = f.read()

target = """                },
              ),
        ),
      ),
    );
  }
}"""

replacement = """                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}"""

text = text.replace(target, replacement)

with open('lib/features/employer/jobs/employer_job_detail_screen.dart', 'w') as f:
    f.write(text)
