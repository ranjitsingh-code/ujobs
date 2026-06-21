import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';

import '../models/job.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/l10n_extensions.dart';

class UJobEmployerJobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onTap;
  final VoidCallback? onMoreTap;
  final VoidCallback? onApplicantsTap;
  final bool isManaging;
  final VoidCallback? onEdit;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onPublish;
  final VoidCallback? onReopen;
  final VoidCallback? onDelete;

  const UJobEmployerJobCard({
    required this.job,
    required this.onTap,
    this.onMoreTap,
    this.onApplicantsTap,
    this.isManaging = false,
    this.onEdit,
    this.onPause,
    this.onResume,
    this.onPublish,
    this.onReopen,
    this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final statusColor = _statusColor(job.status);

    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.xl,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.xl,
        child: Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: AppRadius.xl,
            boxShadow: AppShadow.card(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40.r,
                    height: 40.r,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: AppRadius.sm,
                    ),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedBriefcase01,
                      color: AppColors.primary,
                      size: 21.r,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.titleMd.copyWith(
                            color: AppColors.text2,
                            letterSpacing: 0,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          l10n.jobTiming(
                            _postedLabel(context, job.createdAt),
                            _closingLabel(context, job.status, job.closesAt),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.caption.copyWith(
                            color: AppColors.muted2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onMoreTap != null && !isManaging)
                    IconButton(
                      onPressed: onMoreTap,
                      tooltip: l10n.jobActions,
                      visualDensity: VisualDensity.compact,
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedMoreVertical,
                        color: AppColors.muted,
                        size: 21.r,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 7.w,
                runSpacing: 7.h,
                children: [
                  _InfoChip(
                    label: _statusLabel(context, job.status),
                    color: statusColor,
                  ),
                  _InfoChip(
                    label: _employmentLabel(context, job.employmentType),
                    color: AppColors.muted,
                  ),
                  _InfoChip(
                    label: _workplaceLabel(context, job.workplaceType),
                    color: AppColors.info,
                  ),
                ],
              ),
              if (job.location?.trim().isNotEmpty == true) ...[
                SizedBox(height: 11.h),
                _MetaLine(
                  icon: HugeIcons.strokeRoundedLocation01,
                  text: job.location!,
                ),
              ],
              Divider(height: 24.h, color: AppColors.borderLight, thickness: 1),
              if (isManaging)
                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    if (job.status == JobStatus.active && onPause != null)
                      _ActionButton(
                        label: l10n.pauseJob,
                        icon: HugeIcons.strokeRoundedPauseCircle,
                        onTap: onPause!,
                      ),
                    if (job.status == JobStatus.paused && onResume != null)
                      _ActionButton(
                        label: l10n.reactivateJob,
                        icon: HugeIcons.strokeRoundedPlay,
                        onTap: onResume!,
                      ),
                    if (job.status == JobStatus.draft && onPublish != null)
                      _ActionButton(
                        label: l10n.publishJob,
                        icon: HugeIcons.strokeRoundedSent,
                        onTap: onPublish!,
                      ),
                    if (job.status == JobStatus.closed && onReopen != null)
                      _ActionButton(
                        label: l10n.reopenJob,
                        icon: HugeIcons.strokeRoundedRefresh,
                        onTap: onReopen!,
                      ),
                    if (job.status != JobStatus.closed && job.status != JobStatus.rejected && onEdit != null)
                      _ActionButton(
                        label: l10n.edit,
                        icon: HugeIcons.strokeRoundedPencilEdit01,
                        onTap: onEdit!,
                      ),
                    if (onDelete != null)
                      if (job.status == JobStatus.closed || job.status == JobStatus.rejected)
                        _ActionButton(
                          label: l10n.delete,
                          icon: HugeIcons.strokeRoundedDelete01,
                          color: AppColors.error,
                          onTap: onDelete!,
                        )
                      else
                        _ActionButton(
                          label: l10n.closeJob,
                          icon: HugeIcons.strokeRoundedAlert02,
                          color: AppColors.error,
                          onTap: onDelete!,
                        ),
                  ],
                  ),
                )
              else if (job.status != JobStatus.draft && job.status != JobStatus.pending)
                Row(
                  children: [
                    InkWell(
                      onTap: onApplicantsTap,
                      borderRadius: AppRadius.sm,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 2.w),
                        child: _StatItem(
                          icon: HugeIcons.strokeRoundedUserGroup,
                          count: job.applicantCount,
                          label: l10n.applicants,
                          countColor: AppColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(width: 20.w),
                    _StatItem(
                      icon: HugeIcons.strokeRoundedChartBarIncreasing,
                      count: job.viewCount,
                      label: l10n.views,
                      countColor: AppColors.text,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final List<List<dynamic>> icon;
  final int count;
  final String label;
  final Color countColor;

  const _StatItem({
    required this.icon,
    required this.count,
    required this.label,
    required this.countColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        HugeIcon(icon: icon, color: AppColors.muted2, size: 16.r),
        SizedBox(width: 6.w),
        RichText(
          text: TextSpan(
            style: AppText.small.copyWith(color: AppColors.muted),
            children: [
              TextSpan(
                text: '$count ',
                style: TextStyle(
                  color: countColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(text: label),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final List<List<dynamic>> icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.pill,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: AppRadius.pill,
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(icon: icon, color: color, size: 14.r),
            SizedBox(width: 4.w),
            Text(
              label,
              style: AppText.small.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.09),
      borderRadius: AppRadius.pill,
    ),
    child: Text(
      label,
      style: AppText.caption.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _MetaLine extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String text;

  const _MetaLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      HugeIcon(icon: icon, color: AppColors.muted2, size: 15.r),
      SizedBox(width: 6.w),
      Expanded(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppText.small.copyWith(color: AppColors.muted),
        ),
      ),
    ],
  );
}

String _postedLabel(BuildContext context, DateTime? createdAt) {
  final l10n = context.l10n;
  if (createdAt == null) return l10n.recentlyPosted;
  final days = _dateDifference(createdAt, DateTime.now());
  if (days <= 0) return l10n.postedToday;
  return l10n.postedDaysAgo(days);
}

String _closingLabel(
  BuildContext context,
  JobStatus status,
  DateTime? closesAt,
) {
  final l10n = context.l10n;
  if (status == JobStatus.closed || status == JobStatus.rejected) {
    return l10n.applicationsClosed;
  }
  if (closesAt == null) return l10n.closingDateNotSet;
  final days = _dateDifference(DateTime.now(), closesAt);
  if (days < 0) return l10n.applicationsClosed;
  if (days == 0) return l10n.closesToday;
  return l10n.closesInDays(days);
}

int _dateDifference(DateTime from, DateTime to) {
  final start = DateTime(from.year, from.month, from.day);
  final end = DateTime(to.year, to.month, to.day);
  return end.difference(start).inDays;
}

String _employmentLabel(BuildContext context, String type) {
  final l10n = context.l10n;
  return switch (type) {
    'full_time' => l10n.fullTime,
    'part_time' => l10n.partTime,
    'contract' => l10n.contract,
    'internship' => l10n.internship,
    _ => type,
  };
}

String _workplaceLabel(BuildContext context, String workplaceType) {
  final l10n = context.l10n;
  return switch (workplaceType) {
    'remote' => l10n.remote,
    'hybrid' => l10n.hybrid,
    'onsite' || 'on_site' => l10n.onsite,
    _ => workplaceType,
  };
}

String _statusLabel(BuildContext context, JobStatus status) {
  final l10n = context.l10n;
  return switch (status) {
    JobStatus.active => l10n.activeTab,
    JobStatus.pending => l10n.pendingTab,
    JobStatus.paused => l10n.pausedTab,
    JobStatus.closed => l10n.closedTab,
    JobStatus.draft => l10n.draftTab,
    JobStatus.rejected => l10n.rejectedTab,
  };
}

Color _statusColor(JobStatus status) {
  return switch (status) {
    JobStatus.active => AppColors.success,
    JobStatus.pending => AppColors.warning,
    JobStatus.paused => AppColors.info,
    JobStatus.closed => AppColors.error,
    JobStatus.draft => AppColors.muted,
    JobStatus.rejected => AppColors.error,
  };
}
