import re

with open('lib/features/seeker/jobs/seeker_job_detail_screen.dart', 'r') as f:
    content = f.read()

orig_apply = """  void _apply(BuildContext context, dynamic job) async {
    final result = await context.push<bool>(
      '/seeker/jobs/${widget.jobId}/apply',
      extra: {'title': job.title, 'company': job.company?.name ?? ''},
    );
    if (result == true) {
      setState(() => _hasApplied = true);
    }
  }"""

new_apply = """  void _apply(BuildContext context, dynamic job) async {
    final hasQuestions = job.screeningQuestions?.isNotEmpty == true;
    final needsCoverLetter = job.coverLetterRequirement != 'Disabled';

    if (!hasQuestions && !needsCoverLetter) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => UJobAlertDialog(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedBriefcase01,
            color: AppColors.seekPrimary,
            size: 32.r,
          ),
          iconBgColor: AppColors.seekPrimary,
          title: 'Apply for this Job?',
          description: 'Are you sure you want to submit your application for ${job.title} at ${job.company?.name ?? 'Company'}?',
          confirmText: 'Apply',
          confirmColor: AppColors.seekPrimary,
          onConfirm: () => Navigator.pop(context, true),
        ),
      );

      if (confirmed == true) {
        setState(() => _hasApplied = true);
        if (mounted) UJobToast.success(context, 'Application Submitted!');
      }
      return;
    }

    final result = await context.push<bool>(
      '/seeker/jobs/${widget.jobId}/apply',
      extra: {'title': job.title, 'company': job.company?.name ?? ''},
    );
    if (result == true) {
      setState(() => _hasApplied = true);
    }
  }"""

content = content.replace(orig_apply, new_apply)
if "import '../../../core/widgets/ujob_alert_dialog.dart';" not in content:
    content = content.replace("import '../../../core/widgets/ujob_app_bar.dart';", "import '../../../core/widgets/ujob_app_bar.dart';\nimport '../../../core/widgets/ujob_alert_dialog.dart';")

with open('lib/features/seeker/jobs/seeker_job_detail_screen.dart', 'w') as f:
    f.write(content)

