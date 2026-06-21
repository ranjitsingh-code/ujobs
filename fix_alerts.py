import os

files = [
    'lib/features/employer/dashboard/employer_dashboard_screen.dart',
    'lib/features/employer/jobs/my_jobs_screen.dart'
]

for file in files:
    with open(file, 'r') as f:
        text = f.read()

    # Update Setup action in UJobAlertDialog
    old_action = """                onConfirm: () {
                  Navigator.pop(ctx);
                  ref.read(isCompanyProfileCompleteProvider.notifier).state = true;
                },"""
    new_action = """                onConfirm: () {
                  Navigator.pop(ctx);
                  context.push('/employer/profile');
                },"""
    text = text.replace(old_action, new_action)
    
    # Update Setup action in Dashboard UJobAlertDialog
    old_action2 = """                          onConfirm: () {
                            Navigator.pop(ctx);
                            ref.read(isCompanyProfileCompleteProvider.notifier).state = true;
                          },"""
    new_action2 = """                          onConfirm: () {
                            Navigator.pop(ctx);
                            context.push('/employer/profile');
                          },"""
    text = text.replace(old_action2, new_action2)

    # Update Setup action in _CompanyProfileSetup (Dashboard)
    old_setup = """                  _CompanyProfileSetup(
                    onSetup: () {
                      ref.read(isCompanyProfileCompleteProvider.notifier).state = true;
                    },
                  ),"""
    new_setup = """                  _CompanyProfileSetup(
                    onSetup: () {
                      context.push('/employer/profile');
                    },
                  ),"""
    text = text.replace(old_setup, new_setup)

    with open(file, 'w') as f:
        f.write(text)
