import re

with open('lib/features/employer/jobs/my_jobs_screen.dart', 'r') as f:
    text = f.read()

target = """                confirmText: 'Setup Profile',
                confirmColor: AppColors.primary,
                cancelText: 'Cancel',
                onConfirm: () {
                  Navigator.pop(ctx);
                  context.push('/employer/profile');
                },"""

replacement = """                confirmText: 'Okay',
                confirmColor: AppColors.primary,
                onConfirm: () {
                  Navigator.pop(ctx);
                },"""

text = text.replace(target, replacement)

with open('lib/features/employer/jobs/my_jobs_screen.dart', 'w') as f:
    f.write(text)

