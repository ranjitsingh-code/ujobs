import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ujob_button.dart';
import '../../../core/widgets/ujob_error.dart';
import '../../../core/widgets/ujob_loading.dart';
import '../../../core/widgets/ujob_app_bar.dart';
import '../../../core/widgets/ujob_alert_dialog.dart';
import '../../../core/widgets/ujob_rich_text_editor.dart';
import '../../../core/widgets/ujob_rich_text_display.dart';
import '../../../core/utils/job_action_helpers.dart';
import '../../../core/models/job.dart';
import 'employer_job_provider.dart';
import 'post_job_screen.dart';

class EmployerJobDetailScreen extends ConsumerWidget {
  final int jobId;
  const EmployerJobDetailScreen({required this.jobId, super.key});

  Widget _buildSummaryRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppText.small.copyWith(color: AppColors.muted),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppText.bodyMedium.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobAsync = ref.watch(employerJobDetailProvider(jobId));

    return Scaffold(
      appBar: UJobAppBar(title: 'Job Details', rightWidget: null),
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
            Row(children: [_StatusBadge(status: job.status.name)]),
            SizedBox(height: 24.h),

            Text('Job Summary', style: AppText.heading3),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Job Title', job.title),
                  if (job.category != null)
                    _buildSummaryRow('Job Category', job.category!),
                  if (job.location != null)
                    _buildSummaryRow('Location', job.location!),
                  _buildSummaryRow('Employment Type', job.employmentType),
                  _buildSummaryRow('Workplace', job.workplaceType),
                  if (job.openings != null)
                    _buildSummaryRow('Vacancies', job.openings!),
                  if (job.salaryMin != null)
                    _buildSummaryRow(
                      'Salary',
                      job.salaryMax != null
                          ? '${job.salaryMin} - ${job.salaryMax}'
                          : job.salaryMin!,
                    ),
                  if (job.experienceLevel != null &&
                      job.experienceLevel!.isNotEmpty)
                    _buildSummaryRow(
                      'Experience',
                      '${job.experienceLevel} years',
                    ),
                  if (job.education != null)
                    _buildSummaryRow('Min Education', job.education!),
                  if (job.languages != null && job.languages!.isNotEmpty)
                    _buildSummaryRow('Languages', job.languages!.join(', ')),
                  if (job.certifications != null &&
                      job.certifications!.isNotEmpty)
                    _buildSummaryRow(
                      'Certifications',
                      job.certifications!.join(', '),
                    ),
                  if (job.ageMin != null || job.ageMax != null)
                    _buildSummaryRow(
                      'Age Limit',
                      '${job.ageMin ?? 'Any'} - ${job.ageMax ?? 'Any'}',
                    ),
                  if (job.preferredSkills != null &&
                      job.preferredSkills!.isNotEmpty)
                    _buildSummaryRow(
                      'Preferred Skills',
                      job.preferredSkills!.join(', '),
                    ),
                  if (job.applyVia != null)
                    _buildSummaryRow('Apply Via', job.applyVia!),
                  if (job.resumeRequirement != null)
                    _buildSummaryRow('Resume', job.resumeRequirement!),
                  if (job.coverLetterRequirement != null)
                    _buildSummaryRow(
                      'Cover Letter',
                      job.coverLetterRequirement!,
                    ),
                  if (job.closesAt != null)
                    _buildSummaryRow(
                      'Deadline',
                      '${job.closesAt!.day}/${job.closesAt!.month}/${job.closesAt!.year}',
                    ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            if (job.benefits != null && job.benefits!.isNotEmpty) ...[
              Text(
                'Benefits (${job.benefits!.length})',
                style: AppText.heading3,
              ),
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: job.benefits!
                      .map(
                        (benefit) => Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            benefit,
                            style: AppText.small.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              SizedBox(height: 24.h),
            ],

            if (job.description.isNotEmpty ||
                (job.responsibilities?.isNotEmpty ?? false) ||
                (job.requiredSkills?.isNotEmpty ?? false)) ...[
              Text('Description & Requirements', style: AppText.heading3),
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (job.description.isNotEmpty) ...[
                      Text(
                        'Job Description',
                        style: AppText.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      UJobRichTextDisplay(content: job.description),
                      if ((job.responsibilities?.isNotEmpty ?? false) ||
                          (job.requiredSkills?.isNotEmpty ?? false))
                        SizedBox(height: 16.h),
                    ],
                    if (job.responsibilities?.isNotEmpty ?? false) ...[
                      Text(
                        'Responsibilities',
                        style: AppText.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      UJobRichTextDisplay(content: job.responsibilities!),
                      if (job.requiredSkills?.isNotEmpty ?? false)
                        SizedBox(height: 16.h),
                    ],
                    if (job.requiredSkills?.isNotEmpty ?? false) ...[
                      Text(
                        'Required Skills',
                        style: AppText.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      UJobRichTextDisplay(content: job.requiredSkills!),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 32.h),
            ],

            if (job.screeningQuestions != null &&
                job.screeningQuestions!.isNotEmpty) ...[
              Text(
                'Screening Questions (${job.screeningQuestions!.length})',
                style: AppText.heading3,
              ),
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: job.screeningQuestions!.asMap().entries.map((
                    entry,
                  ) {
                    final idx = entry.key;
                    final q = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: idx == job.screeningQuestions!.length - 1
                            ? 0
                            : 12.h,
                      ),
                      child: Text(
                        '${idx + 1}. ${q['text']}',
                        style: AppText.bodyMedium.copyWith(
                          color: AppColors.text,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 24.h),
            ],

            // 1. PRIMARY ACTIONS
            if (job.status == JobStatus.draft) ...[
              UJobButton(
                label: context.l10n.publishJob1,
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedSent,
                  color: AppColors.surface,
                  size: 20.r,
                ),
                onTap: () {
                  JobActionHelpers.confirmPublish(
                    context,
                    () => ref
                        .read(demoEmployerJobsProvider.notifier)
                        .updateStatus(job.id, JobStatus.active),
                  );
                },
              ),
              SizedBox(height: 12.h),
            ],
            if (job.status == JobStatus.active ||
                job.status == JobStatus.paused ||
                job.status == JobStatus.closed) ...[
              UJobButton(
                label: context.l10n.viewApplicants,
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedUserGroup,
                  color: AppColors.surface,
                  size: 20.r,
                ),
                onTap: () {
                  context.push(
                    '/employer/jobs/${job.id}/applicants',
                    extra: job,
                  );
                },
              ),
              SizedBox(height: 12.h),
            ],

            // 2. SECONDARY ACTIONS (Resume, Re-open)
            if (job.status == JobStatus.paused) ...[
              UJobButton(
                label: context.l10n.republishJob,
                outlined: true,
                color: AppColors.success,
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedPlay,
                  color: AppColors.success,
                  size: 20.r,
                ),
                onTap: () {
                  JobActionHelpers.confirmResume(
                    context,
                    () => ref
                        .read(demoEmployerJobsProvider.notifier)
                        .updateStatus(job.id, JobStatus.active),
                  );
                },
              ),
              SizedBox(height: 12.h),
            ],
            if (job.status == JobStatus.closed) ...[
              UJobButton(
                label: context.l10n.reopenJob1,
                outlined: true,
                color: AppColors.success,
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedRefresh,
                  color: AppColors.success,
                  size: 20.r,
                ),
                onTap: () {
                  JobActionHelpers.confirmReopen(
                    context,
                    () => ref
                        .read(demoEmployerJobsProvider.notifier)
                        .updateStatus(job.id, JobStatus.active),
                  );
                },
              ),
              SizedBox(height: 12.h),
            ],

            // 3. EDIT ACTION
            if (job.status == JobStatus.active ||
                job.status == JobStatus.paused ||
                job.status == JobStatus.pending ||
                job.status == JobStatus.draft) ...[
              UJobButton(
                label: context.l10n.editJob,
                outlined: true,
                color: AppColors.primary,
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedPencilEdit01,
                  color: AppColors.primary,
                  size: 20.r,
                ),
                onTap: () {
                  JobActionHelpers.confirmEdit(
                    context,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostJobScreen(job: job),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 12.h),
            ],

            // 4. PAUSE ACTION
            if (job.status == JobStatus.active) ...[
              UJobButton(
                label: context.l10n.pauseJob1,
                outlined: true,
                color: AppColors.primary,
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedPauseCircle,
                  color: AppColors.primary,
                  size: 20.r,
                ),
                onTap: () {
                  JobActionHelpers.confirmPause(
                    context,
                    () => ref
                        .read(demoEmployerJobsProvider.notifier)
                        .updateStatus(job.id, JobStatus.paused),
                  );
                },
              ),
              SizedBox(height: 12.h),
            ],

            // 5. DESTRUCTIVE ACTIONS
            if (job.status == JobStatus.active ||
                job.status == JobStatus.paused ||
                job.status == JobStatus.pending ||
                job.status == JobStatus.draft) ...[
              UJobButton(
                label: context.l10n.closeJob1,
                outlined: true,
                color: AppColors.error,
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedAlert02,
                  color: AppColors.error,
                  size: 20.r,
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => UJobAlertDialog(
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedAlert02,
                        color: AppColors.error,
                        size: 32.r,
                      ),
                      iconBgColor: AppColors.error,
                      title: 'Close Job',
                      description:
                          'Are you sure you want to close this job? You will no longer receive new applications.',
                      cancelText: 'Cancel',
                      confirmText: 'Close Job',
                      onConfirm: () {
                        ref
                            .read(demoEmployerJobsProvider.notifier)
                            .updateStatus(jobId, JobStatus.closed);
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ],
            if (job.status == JobStatus.closed ||
                job.status == JobStatus.rejected) ...[
              UJobButton(
                label: context.l10n.deleteJob,
                outlined: true,
                color: AppColors.error,
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedDelete01,
                  color: AppColors.error,
                  size: 20.r,
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => UJobAlertDialog(
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedDelete01,
                        color: AppColors.error,
                        size: 32.r,
                      ),
                      iconBgColor: AppColors.error,
                      title: 'Delete Job',
                      description:
                          'Are you sure you want to permanently delete this job?',
                      cancelText: 'Cancel',
                      confirmText: 'Delete',
                      onConfirm: () {
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ],
          ],
        ),
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
      case 'active':
        color = AppColors.success;
        break;
      case 'pending':
        color = AppColors.warning;
        break;
      case 'closed':
        color = AppColors.error;
        break;
      default:
        color = AppColors.muted;
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
