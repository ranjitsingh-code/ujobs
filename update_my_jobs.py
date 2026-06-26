import re

with open('lib/features/employer/jobs/my_jobs_screen.dart', 'r') as f:
    text = f.read()

target = """  @override
  Widget build(BuildContext context) {
    final isProfileComplete = ref.watch(isCompanyProfileCompleteProvider);
    return Scaffold("""

replacement = """  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(employerDashboardProvider);
    final isVerified = dashboardAsync.valueOrNull?.isVerified ?? false;

    return Scaffold("""

text = text.replace(target, replacement)

target2 = """      floatingActionButton: _CompactPostJobButton(
        isProfileComplete: isProfileComplete,
        onTap: () {
          if (!isProfileComplete) {
            showDialog(
              context: context,
              builder: (ctx) => UJobAlertDialog(
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedAlert02,
                  color: AppColors.warning,
                  size: 32.r,
                ),
                iconBgColor: AppColors.warning,
                title: 'Action Required',
                description:
                    'You must complete your company profile before you can post a new job.',
                confirmText: 'Setup Profile',
                confirmColor: AppColors.primary,
                cancelText: 'Cancel',
                onConfirm: () {
                  Navigator.pop(ctx);
                  context.push('/employer/profile');
                },
              ),
            );
            return;
          }
          context.push('/employer/post-job');
        },
      ),"""

replacement2 = """      floatingActionButton: _CompactPostJobButton(
        isProfileComplete: isVerified,
        onTap: () {
          if (!isVerified) {
            showDialog(
              context: context,
              builder: (ctx) => UJobAlertDialog(
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedAlert02,
                  color: AppColors.warning,
                  size: 32.r,
                ),
                iconBgColor: AppColors.warning,
                title: 'Verification Required',
                description:
                    'Your employer profile must be verified before you can post a new job. Please update your company profile to proceed.',
                confirmText: 'Setup Profile',
                confirmColor: AppColors.primary,
                cancelText: 'Cancel',
                onConfirm: () {
                  Navigator.pop(ctx);
                  context.push('/employer/profile');
                },
              ),
            );
            return;
          }
          context.push('/employer/post-job');
        },
      ),"""

text = text.replace(target2, replacement2)

with open('lib/features/employer/jobs/my_jobs_screen.dart', 'w') as f:
    f.write(text)
