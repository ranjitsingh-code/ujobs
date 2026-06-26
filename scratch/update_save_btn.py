import re

with open('lib/features/seeker/jobs/seeker_job_detail_screen.dart', 'r') as f:
    content = f.read()

# Add imports
if "import '../applications/seeker_application_provider.dart';" not in content:
    content = content.replace("import 'seeker_job_provider.dart';", "import 'seeker_job_provider.dart';\nimport '../applications/seeker_application_provider.dart';\nimport '../../../core/models/application.dart';")


orig_build = """  @override
  Widget build(BuildContext context) {
    final jobAsync = ref.watch(seekerJobDetailProvider(widget.jobId));
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: UJobAppBar(
        title: '',
        rightWidget: IconButton(
          onPressed: () {},
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedBookmark01,
            color: AppColors.text,
            size: 24.r,
          ),
        ),
      ),"""

new_build = """  @override
  Widget build(BuildContext context) {
    final jobAsync = ref.watch(seekerJobDetailProvider(widget.jobId));
    final l10n = context.l10n;
    
    final apps = ref.watch(seekerApplicationsProvider(null)).value ?? [];
    final isSaved = apps.any((a) => a.job.id == widget.jobId && a.status == ApplicationStatus.saved);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: UJobAppBar(
        title: '',
        rightWidget: IconButton(
          onPressed: () {
            if (jobAsync.value != null) {
              ref.read(seekerApplicationsProvider(null).notifier).toggleSave(jobAsync.value!);
              UJobToast.success(context, isSaved ? 'Job removed from saved' : 'Job saved successfully!');
            }
          },
          icon: HugeIcon(
            icon: isSaved ? HugeIcons.solidRoundedBookmark01 : HugeIcons.strokeRoundedBookmark01,
            color: isSaved ? AppColors.seekPrimary : AppColors.text,
            size: 24.r,
          ),
        ),
      ),"""

content = content.replace(orig_build, new_build)

with open('lib/features/seeker/jobs/seeker_job_detail_screen.dart', 'w') as f:
    f.write(content)
