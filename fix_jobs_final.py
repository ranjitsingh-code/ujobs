with open('lib/features/employer/jobs/my_jobs_screen.dart', 'r') as f:
    text = f.read()

# 1. Update the main build method to watch the provider
old_build = "  Widget build(BuildContext context) {\n    return Scaffold("
new_build = "  Widget build(BuildContext context) {\n    final isProfileComplete = ref.watch(isCompanyProfileCompleteProvider);\n    return Scaffold("
text = text.replace(old_build, new_build)

# 2. Update the floating action button to pass the provider value
old_fab = """      floatingActionButton: _CompactPostJobButton(
        onTap: () => context.push('/employer/post-job'),
      ),"""
new_fab = """      floatingActionButton: _CompactPostJobButton(
        isProfileComplete: isProfileComplete,
        onTap: () {
          if (!isProfileComplete) {
            showDialog(
              context: context,
              builder: (ctx) => UJobAlertDialog(
                icon: HugeIcon(icon: HugeIcons.strokeRoundedAlert02, color: AppColors.warning, size: 32.r),
                iconBgColor: AppColors.warning,
                title: 'Action Required',
                description: 'You must complete your company profile before you can post a new job.',
                confirmText: 'Setup Profile',
                confirmColor: AppColors.primary,
                cancelText: 'Cancel',
                onConfirm: () {
                  Navigator.pop(ctx);
                  ref.read(isCompanyProfileCompleteProvider.notifier).state = true;
                },
              ),
            );
            return;
          }
          context.push('/employer/post-job');
        },
      ),"""
text = text.replace(old_fab, new_fab)

# 3. Update the _CompactPostJobButton constructor
old_class = """class _CompactPostJobButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CompactPostJobButton({required this.onTap});"""
new_class = """class _CompactPostJobButton extends StatelessWidget {
  final bool isProfileComplete;
  final VoidCallback onTap;

  const _CompactPostJobButton({required this.isProfileComplete, required this.onTap});"""
text = text.replace(old_class, new_class)

# 4. Add the Opacity widget inside _CompactPostJobButton
old_btn = """  Widget build(BuildContext context) => SizedBox(
    width: 162.w,
    child: UJobButton("""
new_btn = """  Widget build(BuildContext context) => Opacity(
    opacity: isProfileComplete ? 1.0 : 0.5,
    child: SizedBox(
      width: 162.w,
      child: UJobButton("""
text = text.replace(old_btn, new_btn)

old_btn_end = """        size: 19.r,
      ),
    ),
  );
}"""
new_btn_end = """        size: 19.r,
      ),
    ),
  ));
}"""
text = text.replace(old_btn_end, new_btn_end)

with open('lib/features/employer/jobs/my_jobs_screen.dart', 'w') as f:
    f.write(text)
