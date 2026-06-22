import re

with open('lib/features/seeker/dashboard/seeker_dashboard_screen.dart', 'r') as f:
    content = f.read()

# Let's find how we route to jobs, profile and messages
for route in ['/seeker/jobs', '/seeker/profile', '/seeker/messages']:
    lines = [line for line in content.split('\n') if route in line]
    print(f"Route {route}: {lines}")
