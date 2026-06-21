with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'r') as f:
    text = f.read()

# Replace the specific occurrences
# Total Jobs -> onTap: () => context.go('/employer/jobs', extra: 0),
text = text.replace(
    """                      label: 'Total Jobs',
                      icon: Icons.work_outline_rounded,
                      onTap: onJobsTap,""",
    """                      label: 'Total Jobs',
                      icon: Icons.work_outline_rounded,
                      onTap: () => context.go('/employer/jobs', extra: 0),"""
)

# Active Jobs -> onTap: () => context.go('/employer/jobs', extra: 1),
text = text.replace(
    """                      label: 'Active Jobs',
                      icon: Icons.work_history_outlined,
                      onTap: onJobsTap,""",
    """                      label: 'Active Jobs',
                      icon: Icons.work_history_outlined,
                      onTap: () => context.go('/employer/jobs', extra: 1),"""
)

# Total Applicants -> onTap: () => context.push('/employer/applicants', extra: 0),
text = text.replace(
    """                      label: 'Total Applicants',
                      icon: Icons.groups_outlined,
                      onTap: onApplicantsTap,""",
    """                      label: 'Total Applicants',
                      icon: Icons.groups_outlined,
                      onTap: () => context.push('/employer/applicants', extra: 0),"""
)

# Shortlisted -> onTap: () => context.push('/employer/applicants', extra: 2),
text = text.replace(
    """                      label: 'Shortlisted',
                      icon: Icons.bookmark_added_outlined,
                      onTap: onApplicantsTap,""",
    """                      label: 'Shortlisted',
                      icon: Icons.bookmark_added_outlined,
                      onTap: () => context.push('/employer/applicants', extra: 2),"""
)

with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'w') as f:
    f.write(text)
