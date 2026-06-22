import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import '../widgets/ujob_alert_dialog.dart';
import '../theme/app_colors.dart';
import 'l10n_extensions.dart';

class JobActionHelpers {
  static void confirmEdit(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => UJobAlertDialog(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedPencilEdit01,
          color: AppColors.primary,
          size: 32.r,
        ),
        iconBgColor: AppColors.primary,
        confirmColor: AppColors.primary,
        title: context.l10n.edit,
        description: 'Do you want to edit this job?',
        confirmText: context.l10n.edit,
        onConfirm: () {
          Navigator.pop(ctx);
          onConfirm();
        },
      ),
    );
  }

  static void confirmPause(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => UJobAlertDialog(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedPauseCircle,
          color: AppColors.warning,
          size: 32.r,
        ),
        iconBgColor: AppColors.warning,
        confirmColor: AppColors.warning,
        title: context.l10n.pauseJob,
        description:
            'Do you want to pause this job? It will temporarily be hidden from job seekers.',
        confirmText: context.l10n.pauseJob,
        onConfirm: () {
          Navigator.pop(ctx);
          onConfirm();
        },
      ),
    );
  }

  static void confirmResume(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => UJobAlertDialog(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedPlay,
          color: AppColors.success,
          size: 32.r,
        ),
        iconBgColor: AppColors.success,
        confirmColor: AppColors.success,
        title: context.l10n.reactivateJob,
        description: 'Do you want to reactivate this job?',
        confirmText: context.l10n.reactivateJob,
        onConfirm: () {
          Navigator.pop(ctx);
          onConfirm();
        },
      ),
    );
  }

  static void confirmPublish(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => UJobAlertDialog(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedSent,
          color: AppColors.success,
          size: 32.r,
        ),
        iconBgColor: AppColors.success,
        confirmColor: AppColors.success,
        title: context.l10n.publishJob,
        description: 'Do you want to publish this job?',
        confirmText: context.l10n.publishJob,
        onConfirm: () {
          Navigator.pop(ctx);
          onConfirm();
        },
      ),
    );
  }

  static void confirmReopen(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => UJobAlertDialog(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedRefresh,
          color: AppColors.success,
          size: 32.r,
        ),
        iconBgColor: AppColors.success,
        confirmColor: AppColors.success,
        title: context.l10n.reopenJob,
        description: 'Do you want to reopen this job?',
        confirmText: context.l10n.reopenJob,
        onConfirm: () {
          Navigator.pop(ctx);
          onConfirm();
        },
      ),
    );
  }
}
