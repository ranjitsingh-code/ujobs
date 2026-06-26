import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/feature_flags_provider.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';

import '../models/job.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/l10n_extensions.dart';

Future<void> showUJobEmployerJobActionsSheet({
  required BuildContext context,
  required Job job,
  VoidCallback? onEdit,
  VoidCallback? onViewApplicants,
  VoidCallback? onPause,
  VoidCallback? onResume,
  VoidCallback? onPublish,
  VoidCallback? onReopen,
  VoidCallback? onClose, VoidCallback? onDelete,
}) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _UJobEmployerJobActionsSheet(
      job: job,
      onEdit: onEdit == null
          ? null
          : () {
              Navigator.pop(ctx);
              onEdit();
            },
      onViewApplicants: onViewApplicants == null
          ? null
          : () {
              Navigator.pop(ctx);
              onViewApplicants();
            },
      onPause: onPause == null
          ? null
          : () {
              Navigator.pop(ctx);
              onPause();
            },
      onResume: onResume == null
          ? null
          : () {
              Navigator.pop(ctx);
              onResume();
            },
      onPublish: onPublish == null
          ? null
          : () {
              Navigator.pop(ctx);
              onPublish();
            },
      onReopen: onReopen == null
          ? null
          : () {
              Navigator.pop(ctx);
              onReopen();
            },
      onClose: onClose == null
          ? null
          : () {
              Navigator.pop(ctx);
              onClose();
            },
      onDelete: onDelete == null
          ? null
          : () {
              Navigator.pop(ctx);
              onDelete();
            },
    ),
  );
}

class _UJobEmployerJobActionsSheet extends ConsumerWidget {
  final Job job;
  final VoidCallback? onEdit;
  final VoidCallback? onViewApplicants;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onPublish;
  final VoidCallback? onReopen;
  final VoidCallback? onClose;
  final VoidCallback? onDelete;

  const _UJobEmployerJobActionsSheet({
    required this.job,
    this.onEdit,
    this.onViewApplicants,
    this.onPause,
    this.onResume,
    this.onPublish,
    this.onReopen,
    this.onClose,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featureFlags = ref.watch(featureFlagsProvider);
    final bool jobApprovalRequired = featureFlags.maybeWhen(
      data: (flags) => flags.jobApprovalRequired,
      orElse: () => false,
    );
    final l10n = context.l10n;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 12.h),
        Container(
          width: 40.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: AppRadius.pill,
          ),
        ),
        SizedBox(height: 20.h),
        Text(l10n.jobActions, style: AppText.heading3),
        SizedBox(height: 12.h),
        if (onViewApplicants != null &&
            (job.status == JobStatus.active ||
                job.status == JobStatus.paused ||
                job.status == JobStatus.closed))
          _ActionTile(
            icon: HugeIcons.strokeRoundedUserGroup,
            label: l10n.viewApplicants,
            onTap: onViewApplicants!,
          ),
        if (onEdit != null &&
            job.status != JobStatus.closed &&
            job.status != JobStatus.rejected)
          _ActionTile(
            icon: HugeIcons.strokeRoundedPencilEdit01,
            label: l10n.edit,
            onTap: onEdit!,
          ),
        if (onPause != null && job.status == JobStatus.active)
          _ActionTile(
            icon: HugeIcons.strokeRoundedPauseCircle,
            label: l10n.pauseJob,
            onTap: onPause!,
          ),
        if (!jobApprovalRequired && onResume != null && job.status == JobStatus.paused)
          _ActionTile(
            icon: HugeIcons.strokeRoundedPlay,
            label: l10n.reactivateJob,
            onTap: onResume!,
          ),
        if (!jobApprovalRequired && onPublish != null && job.status == JobStatus.draft)
          _ActionTile(
            icon: HugeIcons.strokeRoundedSent,
            label: l10n.publishJob,
            onTap: onPublish!,
          ),
        if (!jobApprovalRequired && onReopen != null && job.status == JobStatus.closed)
          _ActionTile(
            icon: HugeIcons.strokeRoundedRefresh,
            label: l10n.reopenJob,
            onTap: onReopen!,
          ),
        Divider(height: 1.h, color: AppColors.borderLight),
        if (onClose != null && job.status != JobStatus.closed && job.status != JobStatus.rejected)
          _ActionTile(
            icon: HugeIcons.strokeRoundedAlert02,
            label: context.l10n.closeJob1,
            color: AppColors.text,
            onTap: onClose!,
          ),
        if (onDelete != null)
          _ActionTile(
            icon: HugeIcons.strokeRoundedDelete01,
            label: l10n.delete,
            color: AppColors.error,
            onTap: onDelete!,
          ),
        SizedBox(height: 24.h),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = color ?? AppColors.text2;

    return ListTile(
      leading: HugeIcon(icon: icon, color: foreground, size: 22.r),
      title: Text(label, style: AppText.bodyMedium.copyWith(color: foreground)),
      onTap: onTap,
    );
  }
}
