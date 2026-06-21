with open('lib/features/employer/jobs/my_jobs_screen.dart', 'r') as f:
    text = f.read()

import_statement = "import '../dashboard/employer_dashboard_provider.dart';"
if import_statement not in text:
    last_import = text.rfind("import '")
    end_of_line = text.find('\n', last_import)
    text = text[:end_of_line] + f"\n{import_statement}" + text[end_of_line:]

build_start = text.find('  Widget build(BuildContext context) {')
build_new = """  Widget build(BuildContext context) {
    final isProfileComplete = ref.watch(isCompanyProfileCompleteProvider);"""
if build_start != -1:
    text = text[:build_start] + build_new + text[build_start + len('  Widget build(BuildContext context) {'):]

button_call = """      floatingActionButton: _CompactPostJobButton(
        onTap: () => context.push('/employer/post-job'),
      ),"""
button_new = """      floatingActionButton: _CompactPostJobButton(
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
text = text.replace(button_call, button_new)


class_old = """class _CompactPostJobButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CompactPostJobButton({required this.onTap});"""
class_new = """class _CompactPostJobButton extends StatelessWidget {
  final bool isProfileComplete;
  final VoidCallback onTap;

  const _CompactPostJobButton({required this.isProfileComplete, required this.onTap});"""
text = text.replace(class_old, class_new)

btn_old = """  Widget build(BuildContext context) => SizedBox(
    width: 162.w,
    child: UJobButton("""
btn_new = """  Widget build(BuildContext context) => Opacity(
    opacity: isProfileComplete ? 1.0 : 0.5,
    child: SizedBox(
      width: 162.w,
      child: UJobButton("""
text = text.replace(btn_old, btn_new)

btn_end_old = """        size: 19.r,
      ),
    ),
  );
}"""
btn_end_new = """        size: 19.r,
      ),
    ),
  ));
}"""
text = text.replace(btn_end_old, btn_end_new)

with open('lib/features/employer/jobs/my_jobs_screen.dart', 'w') as f:
    f.write(text)
