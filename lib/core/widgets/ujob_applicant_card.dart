import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/applicant.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'ujob_avatar.dart';
import 'ujob_button.dart';
import 'ujob_alert_dialog.dart';
import 'ujob_pdf_viewer_screen.dart';
import '../../features/employer/applicants/employer_applicant_provider.dart';

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
                  UJobAvatar(initials: applicant.initials, imageUrl: applicant.avatarUrl, size: 48.r),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                applicant.name,
                                style: AppText.titleMd.copyWith(color: AppColors.text2),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: applicant.statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                applicant.status,
                                style: AppText.caption.copyWith(color: applicant.statusColor, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          applicant.targetJobTitle != null 
                              ? 'Applied for: ${applicant.targetJobTitle} · ${applicant.appliedAgo}'
                              : '${applicant.role} · Applied ${applicant.appliedAgo}',
                          style: AppText.small.copyWith(color: AppColors.muted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (applicant.skills.isNotEmpty) ...[
                SizedBox(height: 16.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 6.h,
                  children: applicant.skills.take(3).map((s) => Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.bg,
                      borderRadius: AppRadius.sm,
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Text(s, style: AppText.small.copyWith(color: AppColors.text)),
                  )).toList(),
                ),
              ],
              SizedBox(height: 16.h),
              Divider(height: 1.h, color: AppColors.borderLight),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: UJobButton(
                      label: 'Profile',
                      outlined: true,
                      height: 36,
                      textStyle: AppText.caption.copyWith(fontWeight: FontWeight.bold),
                      onTap: onTap,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: UJobButton(
                      label: 'Resume',
                      outlined: true,
                      height: 36,
                      textStyle: AppText.caption.copyWith(fontWeight: FontWeight.bold),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UJobPdfViewerScreen(
                              title: '${applicant.name} - Resume',
                              pdfUrl: 'assets/images/job_resume_md_azad_hossain_tutul.pdf',
                              isAsset: true,
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
                      textStyle: AppText.caption.copyWith(fontWeight: FontWeight.bold),
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

  void _showStageSelectorSheet(BuildContext context, WidgetRef ref, Applicant applicant) {
    final List<String> availableStages = [
      'Shortlisted',
      'Interview',
      'Offered',
      'Hired',
      'Rejected',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 40.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Update Application Stage', style: AppText.heading3),
              SizedBox(height: 16.h),
              ...availableStages.map((stage) {
                final isCurrent = applicant.status.toLowerCase() == stage.toLowerCase();
                return ListTile(
                  title: Text(
                    stage,
                    style: AppText.bodyBold.copyWith(
                      color: stage == 'Rejected' ? AppColors.error : AppColors.text,
                    ),
                  ),
                  trailing: isCurrent ? HugeIcon(icon: HugeIcons.strokeRoundedCheckmarkCircle02, color: AppColors.primary, size: 24.r) : null,
                  onTap: () {
                    Navigator.pop(context); // Close bottom sheet
                    showDialog(
                      context: context,
                      builder: (ctx) => UJobAlertDialog(
                        icon: HugeIcon(
                          icon: stage == 'Rejected' ? HugeIcons.strokeRoundedCancel01 : HugeIcons.strokeRoundedCheckmarkBadge01,
                          color: stage == 'Rejected' ? AppColors.error : AppColors.primary,
                          size: 32.r,
                        ),
                        iconBgColor: stage == 'Rejected' ? AppColors.error : AppColors.primary,
                        confirmColor: stage == 'Rejected' ? AppColors.error : AppColors.primary,
                        title: stage == 'Rejected' ? 'Reject Applicant' : 'Update Stage',
                        description: stage == 'Rejected'
                            ? 'Are you sure you want to reject ${applicant.name}? This action cannot be undone.'
                            : 'Are you sure you want to advance this application to the $stage stage?',
                        cancelText: 'Cancel',
                        confirmText: 'Confirm',
                        onConfirm: () {
                          ref.read(employerApplicantsProvider.notifier).updateStatus(applicant.id, stage);
                          Navigator.pop(ctx);
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
