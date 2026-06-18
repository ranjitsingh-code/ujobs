import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ujob_button.dart';
import '../../../core/widgets/ujob_error.dart';
import '../../../core/widgets/ujob_loading.dart';
import '../../../core/widgets/ujob_app_bar.dart';
import 'employer_job_provider.dart';

class EmployerJobDetailScreen extends ConsumerWidget {
  final int jobId;
  const EmployerJobDetailScreen({required this.jobId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobAsync = ref.watch(employerJobDetailProvider(jobId));

    return Scaffold(
      appBar: UJobAppBar(
        title: 'Job Details',
        rightWidget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {}, // TODO: edit job
              icon: HugeIcon(icon: HugeIcons.strokeRoundedPencilEdit01, color: AppColors.text, size: 22),
            ),
            IconButton(
              onPressed: () {}, // TODO: delete job
              icon: HugeIcon(icon: HugeIcons.strokeRoundedDelete01, color: AppColors.text, size: 22),
            ),
          ],
        ),
      ),
      body: jobAsync.when(
        loading: () => const UJobLoading(count: 1),
        error: (err, stack) => UJobError(
          message: 'Failed to load job details',
          onRetry: () => ref.refresh(employerJobDetailProvider(jobId)),
        ),
        data: (job) => ListView(
          padding: AppSpacing.pagePad,
          children: [
            Text(job.title, style: AppText.heading2),
            SizedBox(height: 8.h),
            Row(
              children: [
                _StatusBadge(status: job.status.name),
                SizedBox(width: 8.w),
                Text(job.employmentType.toUpperCase(), style: AppText.label),
              ],
            ),
            SizedBox(height: 24.h),
            _Section(title: 'Description', content: job.description),
            if (job.location != null) _Section(title: 'Location', content: job.location!),
            if (job.salaryMin != null) 
              _Section(
                title: 'Salary', 
                content: job.salaryMax != null ? '${job.salaryMin} - ${job.salaryMax}' : job.salaryMin!,
              ),
            SizedBox(height: 32.h),
            UJobButton(label: 'View Applicants', onTap: () {}),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String content;
  const _Section({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.titleSm.copyWith(color: AppColors.muted)),
          SizedBox(height: 8.h),
          Text(content, style: AppText.body),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'active': color = AppColors.success; break;
      case 'pending': color = AppColors.warning; break;
      case 'closed': color = AppColors.error; break;
      default: color = AppColors.muted;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.pill,
      ),
      child: Text(
        status.toUpperCase(),
        style: AppText.overline.copyWith(color: color),
      ),
    );
  }
}
