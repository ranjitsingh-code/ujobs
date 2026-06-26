import os

file_path = 'lib/features/seeker/jobs/seeker_job_detail_screen.dart'

with open(file_path, 'r') as f:
    content = f.read()

# Instead of regex, let's just do an intelligent replace.
# The `NestedScrollView` starts around `NestedScrollView(`.
# We will replace `NestedScrollView(` with `ListView(`.
# And we remove `headerSliverBuilder: ... return [ SliverToBoxAdapter( child: Padding( padding: AppSpacing.pagePad, child: Column(`
# and replace with just `children: [`

import re

# We will completely replace the build method's body from `NestedScrollView` down to the end of the `TabBarView`.
# It's easier to just overwrite the entire file with a new version because we are removing tabs and controllers.

new_content = """import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
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
import '../../../core/widgets/ujob_rich_text_display.dart';
import 'seeker_job_provider.dart';

class SeekerJobDetailScreen extends ConsumerStatefulWidget {
  final int jobId;
  const SeekerJobDetailScreen({required this.jobId, super.key});

  @override
  ConsumerState<SeekerJobDetailScreen> createState() =>
      _SeekerJobDetailScreenState();
}

class _SeekerJobDetailScreenState extends ConsumerState<SeekerJobDetailScreen> {
  bool _hasApplied = false;

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Today';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final jobAsync = ref.watch(seekerJobDetailProvider(widget.jobId));
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: UJobAppBar(
        title: '',
        rightWidget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {},
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedShare01,
                color: AppColors.text,
                size: 24.r,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedBookmark01,
                color: AppColors.text,
                size: 24.r,
              ),
            ),
          ],
        ),
      ),
      body: jobAsync.when(
        loading: () => const UJobLoading(count: 1),
        error: (err, stack) => UJobError(
          message: l10n.error,
          onRetry: () => ref.refresh(seekerJobDetailProvider(widget.jobId)),
        ),
        data: (job) {
          final isApplied = _hasApplied;

          return Stack(
            children: [
              ListView(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 120.h),
                children: [
                  // --- HEADER ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 56.r,
                        height: 56.r,
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          job.company?.name[0].toUpperCase() ?? 'C',
                          style: AppText.heading2.copyWith(color: AppColors.surface),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(job.title, style: AppText.titleMd),
                            SizedBox(height: 2.h),
                            Text(
                              job.company?.name ?? 'Company',
                              style: AppText.small.copyWith(
                                color: AppColors.seekPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Row(
                              children: [
                                HugeIcon(icon: HugeIcons.strokeRoundedLocation01, color: AppColors.muted, size: 12.r),
                                SizedBox(width: 4.w),
                                Text(job.location ?? 'Remote', style: AppText.small.copyWith(color: AppColors.muted)),
                                SizedBox(width: 8.w),
                                HugeIcon(icon: HugeIcons.strokeRoundedClock01, color: AppColors.muted, size: 12.r),
                                SizedBox(width: 4.w),
                                Text(_formatDate(job.createdAt), style: AppText.small.copyWith(color: AppColors.muted)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  
                  // --- QUICK FACTS ---
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _QuickFactItem(
                            icon: HugeIcons.strokeRoundedMoney01,
                            label: l10n.salary,
                            value: job.salaryMin != null ? '\\$${job.salaryMin} - \\$${job.salaryMax}' : l10n.notSpecified,
                          ),
                        ),
                        Container(width: 1, height: 40.h, color: AppColors.borderLight),
                        Expanded(
                          child: _QuickFactItem(
                            icon: HugeIcons.strokeRoundedBriefcase01,
                            label: l10n.jobType,
                            value: job.employmentType ?? 'Full-time',
                          ),
                        ),
                        Container(width: 1, height: 40.h, color: AppColors.borderLight),
                        Expanded(
                          child: _QuickFactItem(
                            icon: HugeIcons.strokeRoundedLocation01,
                            label: l10n.workplace,
                            value: job.workplaceType ?? 'Remote',
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  
                  // --- SOCIAL PROOF ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (job.applicantCount > 0) ...[
                        SizedBox(
                          width: (24 + ((job.applicantCount > 3 ? 3 : job.applicantCount) - 1) * 16).w,
                          height: 24.r,
                          child: Stack(
                            children: List.generate(
                              job.applicantCount > 3 ? 3 : job.applicantCount,
                              (index) => Positioned(
                                left: (index * 16).w,
                                child: Container(
                                  width: 24.r,
                                  height: 24.r,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.surface, width: 2),
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    image: DecorationImage(
                                      image: NetworkImage('https://i.pravatar.cc/100?img=${index + 10}'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ).reversed.toList(),
                          ),
                        ),
                        SizedBox(width: 8.w),
                      ],
                      Text(
                        l10n.applicantCount(job.applicantCount),
                        style: AppText.small.copyWith(color: AppColors.text, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(width: 12.w),
                      Container(width: 4.r, height: 4.r, decoration: const BoxDecoration(color: AppColors.borderLight, shape: BoxShape.circle)),
                      SizedBox(width: 12.w),
                      HugeIcon(icon: HugeIcons.strokeRoundedView, color: AppColors.muted, size: 14.r),
                      SizedBox(width: 4.w),
                      Text(l10n.viewsCount(job.viewCount), style: AppText.small.copyWith(color: AppColors.muted)),
                    ],
                  ),
                  SizedBox(height: 32.h),
                  
                  // --- CONTENT BODY ---
                  Text('Job Description', style: AppText.heading3),
                  SizedBox(height: 12.h),
                  job.description.startsWith('{') 
                      ? UJobRichTextDisplay(content: job.description)
                      : Text(job.description, style: AppText.body.copyWith(color: AppColors.text2, height: 1.5)),
                  SizedBox(height: 24.h),

                  if (job.responsibilities != null && job.responsibilities!.isNotEmpty) ...[
                    Text('Responsibilities', style: AppText.heading3),
                    SizedBox(height: 12.h),
                    Text(job.responsibilities!, style: AppText.body.copyWith(color: AppColors.text2, height: 1.5)),
                    SizedBox(height: 24.h),
                  ],

                  if (job.requiredSkills != null && job.requiredSkills!.isNotEmpty) ...[
                    Text('Required Skills', style: AppText.heading3),
                    SizedBox(height: 12.h),
                    Text(job.requiredSkills!, style: AppText.body.copyWith(color: AppColors.text2, height: 1.5)),
                    SizedBox(height: 24.h),
                  ],

                  if (job.benefits != null && job.benefits!.isNotEmpty) ...[
                    Text('Benefits', style: AppText.heading3),
                    SizedBox(height: 12.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: job.benefits!.map((b) => _BenefitChip(label: b)).toList(),
                    ),
                    SizedBox(height: 24.h),
                  ],

                  if (job.preferredSkills != null && job.preferredSkills!.isNotEmpty) ...[
                    Text('Preferred Skills', style: AppText.heading3),
                    SizedBox(height: 12.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: job.preferredSkills!.map((s) => _SkillChip(label: s)).toList(),
                    ),
                    SizedBox(height: 24.h),
                  ],

                  // --- MID-PAGE CTA ---
                  Container(
                    padding: EdgeInsets.all(20.r),
                    decoration: BoxDecoration(
                      color: AppColors.seekPrimary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: AppColors.seekPrimary.withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      children: [
                        Text('Interested in this role?', style: AppText.titleMd),
                        SizedBox(height: 8.h),
                        Text('Apply now and get noticed by the hiring team.', style: AppText.small.copyWith(color: AppColors.text2), textAlign: TextAlign.center,),
                        SizedBox(height: 16.h),
                        UJobButton(
                          label: isApplied ? 'Applied' : 'Apply for this Position',
                          color: isApplied ? AppColors.success : AppColors.seekPrimary,
                          onTap: isApplied ? null : () => _apply(context, job),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // --- JOB OVERVIEW GRID ---
                  Text('Job Overview', style: AppText.heading3),
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      children: [
                        _OverviewRow('Employment', job.employmentType),
                        _OverviewRow('Workplace', job.workplaceType),
                        if (job.location != null) _OverviewRow('Location', job.location!),
                        if (job.openings != null) _OverviewRow('Vacancies', '${job.openings} positions'),
                        if (job.salaryMin != null) _OverviewRow('Salary', '\\$${job.salaryMin} - \\$${job.salaryMax}'),
                        if (job.closesAt != null) _OverviewRow('Deadline', '${job.closesAt!.day}/${job.closesAt!.month}/${job.closesAt!.year}', isLast: true),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // --- ABOUT COMPANY ---
                  Text('About ${job.company?.name ?? 'Company'}', style: AppText.heading3),
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48.r,
                              height: 48.r,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                job.company?.name[0].toUpperCase() ?? 'C',
                                style: AppText.heading3.copyWith(color: AppColors.primary),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(job.company?.name ?? 'Company', style: AppText.titleMd),
                                  if (job.company?.industry != null) ...[
                                    SizedBox(height: 2.h),
                                    Text(job.company!.industry!, style: AppText.small.copyWith(color: AppColors.muted)),
                                  ]
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          job.company?.description ?? 'No description available for this company.',
                          style: AppText.small.copyWith(color: AppColors.text2, height: 1.5),
                        ),
                        SizedBox(height: 16.h),
                        UJobButton(
                          label: 'Visit profile',
                          color: AppColors.seekPrimary,
                          outlined: true,
                          onTap: () {
                            if (job.company != null) {
                              context.push('/seeker/company', extra: {'company': job.company});
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // --- BOTTOM BAR ---
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border(top: BorderSide(color: AppColors.borderLight)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5)),
                    ],
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 100.w,
                        child: UJobButton(
                          label: 'Save',
                          outlined: true,
                          color: AppColors.seekPrimary,
                          onTap: () {},
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: UJobButton(
                          label: isApplied ? 'Applied' : 'Apply Now',
                          color: isApplied ? AppColors.success : AppColors.seekPrimary,
                          onTap: isApplied ? null : () => _apply(context, job),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _apply(BuildContext context, dynamic job) async {
    final result = await context.push<bool>(
      '/seeker/jobs/${widget.jobId}/apply',
      extra: {'title': job.title, 'company': job.company?.name ?? ''},
    );
    if (result == true) {
      setState(() => _hasApplied = true);
    }
  }
}

class _QuickFactItem extends StatelessWidget {
  final dynamic icon;
  final String label;
  final String value;

  const _QuickFactItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        HugeIcon(icon: icon, color: AppColors.seekPrimary, size: 24.r),
        SizedBox(height: 8.h),
        Text(label, style: AppText.small.copyWith(color: AppColors.muted)),
        SizedBox(height: 4.h),
        Text(value, style: AppText.small.copyWith(fontWeight: FontWeight.w600, color: AppColors.text), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

class _BenefitChip extends StatelessWidget {
  final String label;
  const _BenefitChip({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8.r)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(icon: HugeIcons.strokeRoundedTick02, color: AppColors.success, size: 16.r),
          SizedBox(width: 6.w),
          Text(label, style: AppText.small.copyWith(color: AppColors.success, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;
  const _SkillChip({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8.r)),
      child: Text(label, style: AppText.small.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
    );
  }
}

class _OverviewRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  const _OverviewRow(this.label, this.value, {this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppText.small.copyWith(color: AppColors.muted)),
          Text(value, style: AppText.bodyBold),
        ],
      ),
    );
  }
}
"""

with open(file_path, 'w') as f:
    f.write(new_content)
