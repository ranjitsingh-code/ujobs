import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/applicant.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'ujob_avatar.dart';
import 'ujob_button.dart';
import 'ujob_alert_dialog.dart';
import 'ujob_pdf_viewer_screen.dart';
import 'ujob_toast.dart';
import '../utils/l10n_extensions.dart';
import '../../features/employer/applicants/employer_applicant_provider.dart';
import '../../features/employer/applicants/employer_applicant_service.dart';
import '../../features/shared/chat/conversation_provider.dart';

class UJobApplicantCard extends ConsumerWidget {
  final Applicant applicant;
  final VoidCallback onTap;

  const UJobApplicantCard({
    super.key,
    required this.applicant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.xl,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.xl,
        child: Container(
          padding: EdgeInsets.all(16.r),
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
                  UJobAvatar(
                    initials: applicant.initials,
                    imageUrl: applicant.avatarUrl,
                    size: 48.r,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(right: 8.w),
                                child: Text(
                                  applicant.name,
                                  style: AppText.titleMd.copyWith(
                                    color: AppColors.text2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: applicant.statusColor.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                applicant.status,
                                style: AppText.caption.copyWith(
                                  color: applicant.statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            InkWell(
                              borderRadius: BorderRadius.circular(20.r),
                              onTap: () => _showActionsSheet(context, ref, applicant),
                              child: Padding(
                                padding: EdgeInsets.all(4.r),
                                child: HugeIcon(
                                  icon: HugeIcons.strokeRoundedMoreVertical,
                                  color: AppColors.muted,
                                  size: 18.r,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          applicant.role,
                          style: AppText.small.copyWith(color: AppColors.text),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (applicant.location.isNotEmpty == true) ...[
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedLocation01,
                                color: AppColors.muted,
                                size: 14.r,
                              ),
                              SizedBox(width: 4.w),
                              Flexible(
                                child: Text(
                                  applicant.location,
                                  style: AppText.small.copyWith(color: AppColors.muted),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedClock01,
                              color: AppColors.muted,
                              size: 14.r,
                            ),
                            SizedBox(width: 4.w),
                            Flexible(
                              child: Text(
                                'Applied ${_formatAppliedDate(applicant.appliedAt)}',
                                style: AppText.small.copyWith(color: AppColors.muted),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: UJobButton(
                      label: 'Resume',
                      outlined: true,
                      height: 36,
                      textStyle: AppText.caption.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      onTap: () {
                        final url = applicant.resumeUrl;
                        if (url == null || url.isEmpty) {
                          UJobToast.warning(
                            context,
                            context.l10n.noResumeTitle,
                            sub: context.l10n.noResumeSubtitle,
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UJobPdfViewerScreen(
                              title: '${applicant.name} - Resume',
                              pdfUrl: url,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: UJobButton(
                      label: 'Update Stage',
                      height: 36,
                      color: AppColors.primary,
                      textStyle: AppText.caption.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      onTap: () {
                        _showStageSelectorSheet(context, ref, applicant);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatAppliedDate(DateTime date) => DateFormat('d MMM yyyy').format(date);

  bool _isChatEnabled(WidgetRef ref, String conversationId) {
    final convs = [
      ...(ref.read(conversationsProvider).valueOrNull ?? const []),
      ...(ref.read(seekerConversationsProvider).valueOrNull ?? const []),
    ];
    for (final c in convs) {
      if (c.id == conversationId) return c.chatEnabled;
    }
    return true;
  }

  Future<void> _toggleChatStatus(
    BuildContext context,
    WidgetRef ref,
    String conversationId,
    bool enabled,
  ) async {
    try {
      await setChatStatus(ref, conversationId, enabled);
      ref
          .read(conversationsProvider.notifier)
          .updateChatEnabled(conversationId, enabled);
      ref
          .read(seekerConversationsProvider.notifier)
          .updateChatEnabled(conversationId, enabled);
    } catch (e) {
      if (!context.mounted) return;
      UJobToast.error(
        context,
        context.l10n.errorTitle,
        sub: context.l10n.tryAgainMessage,
      );
    }
  }

  void _showActionsSheet(
    BuildContext context,
    WidgetRef ref,
    Applicant applicant,
  ) {
    final conversationId = applicant.conversation;
    final hasConversation =
        applicant.hasMessaged && conversationId != null && conversationId.isNotEmpty;
    final chatEnabled =
        hasConversation ? _isChatEnabled(ref, conversationId) : true;
    final hasCoverLetter = (applicant.coverLetterUrl?.isNotEmpty ?? false) ||
        (applicant.coverLetter?.isNotEmpty ?? false);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedCancel01,
                      color: AppColors.muted,
                      size: 22.r,
                    ),
                  ),
                ),
                ListTile(
                  leading: HugeIcon(
                    icon: HugeIcons.strokeRoundedUser,
                    color: AppColors.text,
                    size: 22.r,
                  ),
                  title: Text(sheetContext.l10n.profile, style: AppText.bodyBold),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    onTap();
                  },
                ),
                if (hasCoverLetter)
                  ListTile(
                    leading: HugeIcon(
                      icon: HugeIcons.strokeRoundedPdf01,
                      color: AppColors.text,
                      size: 22.r,
                    ),
                    title: Text(sheetContext.l10n.coverLetterTitle, style: AppText.bodyBold),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _openCoverLetter(context, applicant);
                    },
                  ),
                ListTile(
                  leading: HugeIcon(
                    icon: HugeIcons.strokeRoundedMessage01,
                    color: AppColors.primary,
                    size: 22.r,
                  ),
                  title: Text(
                    hasConversation
                        ? sheetContext.l10n.openChatAction
                        : sheetContext.l10n.startMessageAction,
                    style: AppText.bodyBold.copyWith(color: AppColors.primary),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _openChat(context, ref, applicant);
                  },
                ),
                if (hasConversation)
                  ListTile(
                    leading: HugeIcon(
                      icon: HugeIcons.strokeRoundedLockPassword,
                      color: chatEnabled ? AppColors.error : AppColors.success,
                      size: 22.r,
                    ),
                    title: Text(
                      chatEnabled
                          ? sheetContext.l10n.stopMessageTitle
                          : sheetContext.l10n.reopenChatTitle,
                      style: AppText.bodyBold.copyWith(
                        color: chatEnabled ? AppColors.error : AppColors.success,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      if (chatEnabled) {
                        showDialog(
                          context: context,
                          builder: (ctx) => UJobAlertDialog(
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedLockPassword,
                              color: AppColors.error,
                              size: 28.r,
                            ),
                            title: context.l10n.stopMessageTitle,
                            description: context.l10n.stopMessageConfirmMessage,
                            confirmText: context.l10n.stopMessageTitle,
                            onConfirm: () {
                              Navigator.pop(ctx);
                              _toggleChatStatus(context, ref, conversationId, false);
                            },
                          ),
                        );
                      } else {
                        _toggleChatStatus(context, ref, conversationId, true);
                      }
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openChat(
    BuildContext context,
    WidgetRef ref,
    Applicant applicant,
  ) async {
    try {
      var seekerUserId = applicant.seekerUserId;
      // "All Applicants" list entries don't reliably carry seeker_user_id —
      // the per-job applicants endpoint does, so fall back to it.
      if (seekerUserId == null || seekerUserId.isEmpty) {
        final jobId = int.tryParse(applicant.jobId);
        if (jobId != null) {
          final jobApplicants = await ref
              .read(employerApplicantServiceProvider)
              .getJobApplicants(jobId);
          final match = jobApplicants.where((a) => a.id == applicant.id);
          if (match.isNotEmpty) {
            seekerUserId = match.first.seekerUserId;
          }
        }
      }
      if (seekerUserId == null || seekerUserId.isEmpty) {
        if (!context.mounted) return;
        UJobToast.error(
          context,
          context.l10n.errorTitle,
          sub: context.l10n.tryAgainMessage,
        );
        return;
      }
      final conversationId = await openConversation(
        ref,
        seekerUserId: seekerUserId,
        jobId: applicant.jobId,
      );
      if (!applicant.hasMessaged) {
        ref.read(employerApplicantsProvider.notifier).markAsMessaged(applicant.id);
      }
      if (!context.mounted) return;
      context.push(
        '/conversations/$conversationId',
        extra: {
          'otherId': seekerUserId,
          'name': applicant.name,
          'initials': applicant.initials,
          'avatar': applicant.avatarUrl,
          'applicantId': applicant.id,
        },
      );
    } catch (e) {
      if (!context.mounted) return;
      UJobToast.error(
        context,
        context.l10n.errorTitle,
        sub: context.l10n.tryAgainMessage,
      );
    }
  }

  // Cover letter is now always an uploaded PDF (backend no longer sends
  // free-text cover letters) — open it the exact same way Resume does.
  void _openCoverLetter(BuildContext context, Applicant applicant) {
    final url = applicant.coverLetterUrl;
    if (url == null || url.isEmpty) {
      UJobToast.warning(
        context,
        context.l10n.coverLetterTitle,
        sub: context.l10n.noCoverLetterProvidedMessage,
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UJobPdfViewerScreen(
          title: '${applicant.name} - ${context.l10n.coverLetterTitle}',
          pdfUrl: url,
        ),
      ),
    );
  }

  void _showStageSelectorSheet(
    BuildContext context,
    WidgetRef ref,
    Applicant applicant,
  ) {
    final orderedStages = ['Applied', 'Shortlisted', 'Interview', 'Offered', 'Hired'];
    final currentStatus = applicant.status.toLowerCase();
    final currentIndex = orderedStages.indexWhere((s) => s.toLowerCase() == currentStatus);

    final List<String> availableStages = [];
    if (currentIndex != -1 && currentIndex < orderedStages.length - 1) {
      availableStages.addAll(orderedStages.sublist(currentIndex + 1));
    } else if (currentIndex == -1 && currentStatus != 'rejected') {
      // Fallback if status is unknown, just show all forward stages
      availableStages.addAll(['Shortlisted', 'Interview', 'Offered', 'Hired']);
    }

    if (currentStatus != 'rejected' && currentStatus != 'hired') {
      if (!availableStages.contains('Rejected')) {
        availableStages.add('Rejected');
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 40.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Update Application Stage', style: AppText.heading3),
              SizedBox(height: 16.h),
              if (availableStages.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Text(
                    'No further stages available.',
                    style: AppText.bodyMedium.copyWith(color: AppColors.muted),
                  ),
                ),
              ...availableStages.map((stage) {
                final isCurrent =
                    applicant.status.toLowerCase() == stage.toLowerCase();
                return ListTile(
                  title: Text(
                    stage,
                    style: AppText.bodyBold.copyWith(
                      color: stage == 'Rejected'
                          ? AppColors.error
                          : AppColors.text,
                    ),
                  ),
                  trailing: isCurrent
                      ? HugeIcon(
                          icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                          color: AppColors.primary,
                          size: 24.r,
                        )
                      : null,
                  onTap: () {
                    Navigator.pop(sheetContext); // Close bottom sheet
                    showDialog(
                      context: context,
                      builder: (ctx) => UJobAlertDialog(
                        icon: HugeIcon(
                          icon: stage == 'Rejected'
                              ? HugeIcons.strokeRoundedCancel01
                              : HugeIcons.strokeRoundedCheckmarkBadge01,
                          color: stage == 'Rejected'
                              ? AppColors.error
                              : AppColors.primary,
                          size: 32.r,
                        ),
                        iconBgColor: stage == 'Rejected'
                            ? AppColors.error
                            : AppColors.primary,
                        confirmColor: stage == 'Rejected'
                            ? AppColors.error
                            : AppColors.primary,
                        title: stage == 'Rejected'
                            ? 'Reject Applicant'
                            : 'Update Stage',
                        description: stage == 'Rejected'
                            ? 'Are you sure you want to reject ${applicant.name}? This action cannot be undone.'
                            : 'Are you sure you want to advance this application to the $stage stage?',
                        cancelText: 'Cancel',
                        confirmText: 'Confirm',
                        onConfirm: () async {
                          Navigator.pop(ctx);
                          try {
                            await ref
                                .read(employerApplicantsProvider.notifier)
                                .updateStatus(applicant.id, stage, jobId: applicant.jobId);
                            if (context.mounted) {
                              UJobToast.success(
                                context,
                                'Stage Updated',
                                sub: 'Applicant moved to $stage.',
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              UJobToast.error(
                                context,
                                'Update Failed',
                                sub: 'Failed to update applicant stage.',
                              );
                            }
                          }
                        },
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
