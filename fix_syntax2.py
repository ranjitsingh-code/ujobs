import re

with open("lib/features/employer/jobs/my_jobs_screen.dart", "r") as f:
    content = f.read()

content = content.replace("""          },
        );
        // Close RefreshIndicator
        );
      },""", """          },
        ),
        // Close RefreshIndicator
        );
      },""")

with open("lib/features/employer/jobs/my_jobs_screen.dart", "w") as f:
    f.write(content)

