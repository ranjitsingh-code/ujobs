import re

with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'r') as f:
    text = f.read()

target = """                                  if (context.mounted) {
                                    Navigator.pop(ctx);
                                  }
                                },
                              ),
                            );
                          } : null,
                          onDelete: () {"""

replacement = """                                  if (context.mounted) {
                                    Navigator.pop(ctx);
                                  }
                                },
                              ),
                            );
                          },
                          onDelete: () {"""

text = text.replace(target, replacement)

with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'w') as f:
    f.write(text)
