import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ujob_app_bar.dart';
import '../../../core/widgets/ujob_avatar.dart';

class ApplicantsScreen extends StatelessWidget {
  const ApplicantsScreen({super.key});

  static const applicants = [
    _DemoApplicant(
      name: 'Sarah Chen',
      initials: 'SC',
      role: 'Senior Flutter Developer',
      status: 'Shortlisted',
      appliedAgo: '2h ago',
      color: AppColors.stageShortlisted,
    ),
    _DemoApplicant(
      name: 'Ahmed Hasan',
      initials: 'AH',
      role: 'Senior Flutter Developer',
      status: 'Reviewing',
      appliedAgo: '5h ago',
      color: AppColors.stageReviewed,
    ),
    _DemoApplicant(
      name: 'Maria Garcia',
      initials: 'MG',
      role: 'Product Designer',
      status: 'Interview',
      appliedAgo: '1d ago',
      color: AppColors.stageInterviewed,
    ),
    _DemoApplicant(
      name: 'James Kim',
      initials: 'JK',
      role: 'Backend Engineer',
      status: 'Applied',
      appliedAgo: '2d ago',
      color: AppColors.stageApplied,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const UJobAppBar(title: 'Applicants', showBack: false),
      body: ListView.separated(
        padding: AppSpacing.pagePad,
        itemCount: applicants.length,
        separatorBuilder: (_, _) => SizedBox(height: 10.h),
        itemBuilder: (context, index) =>
            _ApplicantCard(applicant: applicants[index]),
      ),
    );
  }
}

class _DemoApplicant {
  final String name;
  final String initials;
  final String role;
  final String status;
  final String appliedAgo;
  final Color color;

  const _DemoApplicant({
    required this.name,
    required this.initials,
    required this.role,
    required this.status,
    required this.appliedAgo,
    required this.color,
  });
}

class _ApplicantCard extends StatelessWidget {
  final _DemoApplicant applicant;

  const _ApplicantCard({required this.applicant});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: AppRadius.md,
        boxShadow: AppShadow.card(),
      ),
      child: Row(
        children: [
          UJobAvatar(initials: applicant.initials, size: 46.r),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(applicant.name, style: AppText.titleSm),
                SizedBox(height: 3.h),
                Text(
                  applicant.role,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.small.copyWith(color: AppColors.muted),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Applied ${applicant.appliedAgo}',
                  style: AppText.caption.copyWith(color: AppColors.muted2),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: applicant.color.withValues(alpha: 0.1),
              borderRadius: AppRadius.pill,
            ),
            child: Text(
              applicant.status,
              style: AppText.labelSm.copyWith(
                color: applicant.color,
                fontSize: 10.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
