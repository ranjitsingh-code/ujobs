import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ujob_button.dart';
import '../../../core/widgets/ujob_error.dart';
import '../../../core/widgets/ujob_loading.dart';
import '../../../core/widgets/ujob_app_bar.dart';
import '../../../core/widgets/ujob_image.dart';
import 'seeker_job_provider.dart';

class SeekerJobDetailScreen extends ConsumerWidget {
  final int jobId;
  const SeekerJobDetailScreen({required this.jobId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobAsync = ref.watch(seekerJobDetailProvider(jobId));

    return Scaffold(
      appBar: UJobAppBar(
        title: 'Job Details',
        rightWidget: IconButton(
          onPressed: () {}, // TODO: save/unsave via Ep.saveJob(jobId)
          icon: HugeIcon(icon: HugeIcons.strokeRoundedBookmark01, color: AppColors.text, size: 24),
        ),
      ),
      body: jobAsync.when(
        loading: () => const UJobLoading(count: 1),
        error: (err, stack) => UJobError(
          message: 'Failed to load job details',
          onRetry: () => ref.refresh(seekerJobDetailProvider(jobId)),
        ),
        data: (job) => Stack(
          children: [
            ListView(
              padding: AppSpacing.pagePad.copyWith(bottom: 100),
              children: [
                if (job.company?.logo != null)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: UJobImage(
                        path: job.company!.logo!,
                        width: 80.r,
                        height: 80.r,
                        fit: BoxFit.cover,
                        borderRadius: AppRadius.xl,
                      ),
                    ),
                  ),
                Center(child: Text(job.title, style: AppText.heading2, textAlign: TextAlign.center)),
                if (job.company != null)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Text(job.company!.name, style: AppText.bodyMd.copyWith(color: AppColors.muted)),
                    ),
                  ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Badge(label: job.employmentType.toUpperCase()),
                    SizedBox(width: 8.w),
                    _Badge(label: job.workplaceType.toUpperCase()),
                  ],
                ),
                SizedBox(height: 32.h),
                _Section(title: 'Description', content: job.description),
                if (job.location != null) _Section(title: 'Location', content: job.location!),
                if (job.salaryMin != null)
                  _Section(
                    title: 'Salary',
                    content: job.salaryMax != null
                        ? '${job.salaryMin} - ${job.salaryMax}'
                        : job.salaryMin!,
                  ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.borderLight)),
                ),
                child: SafeArea(
                  top: false,
                  child: UJobButton(
                    label: 'Apply Now',
                    onTap: () => context.push(
                      '/seeker/jobs/$jobId/apply',
                      extra: {
                        'title': job.title,
                        'company': job.company?.name,
                        'location': job.location,
                      },
                    ),
                  ),
                ),
              ),
            ),
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
  Widget build(BuildContext context) => Padding(
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

class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: AppRadius.pill,
        ),
        child: Text(label, style: AppText.overline.copyWith(color: AppColors.primary)),
      );
}
