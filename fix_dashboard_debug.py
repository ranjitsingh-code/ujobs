import re

with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'r') as f:
    text = f.read()

# Debug mode: Always allow posting job.
debug_target = """                  onPostJob: () {
                    if (!dashboard.isVerified) {"""
debug_replace = """                  onPostJob: () {
                    if (false) {"""

text = text.replace(debug_target, debug_replace)

with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'w') as f:
    f.write(text)

