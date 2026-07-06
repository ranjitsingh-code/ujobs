// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_endpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ujob_button.dart';
import '../../../core/widgets/ujob_error.dart';
import '../../../core/widgets/ujob_toast.dart';
import '../../../core/widgets/ujob_loading.dart';
import '../../../core/widgets/ujob_app_bar.dart';
import '../../../core/widgets/ujob_alert_dialog.dart';
import '../../../core/widgets/ujob_image.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/widgets/ujob_rich_text_display.dart';
import '../../../core/widgets/ujob_verification_banners.dart';
import 'seeker_job_provider.dart';
import '../applications/seeker_application_provider.dart';
import '../profile/seeker_profile_provider.dart';

class SeekerJobDetailScreen extends ConsumerStatefulWidget {
  final int jobId;
  final String? source;
  const SeekerJobDetailScreen({
    required this.jobId,
    this.source,
    super.key,
  });

  @override
  ConsumerState<SeekerJobDetailScreen> createState() =>
      _SeekerJobDetailScreenState();
}

class _SeekerJobDetailScreenState extends ConsumerState<SeekerJobDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _hasApplied = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && ref.read(seekerProfileProvider) == null) {
        ref.read(fetchSeekerProfileProvider.future).catchError((_) {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Today';
    return '${diff.inDays}d ago';
  }

  String _formatDeadline(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  bool _isDeadlineSoon(DateTime date) =>
      date.difference(DateTime.now()).inDays <= 7;

  bool _isDeadlinePassed(DateTime date) => date.isBefore(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final jobAsync = ref.watch(seekerJobDetailProvider(widget.jobId));
    final l10n = context.l10n;
    final profileStatus = ref.watch(seekerProfileProvider)?.status;

    final isSaved = jobAsync.valueOrNull?.isSaved ?? false;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: UJobAppBar(
        title: '',
        rightWidget: IconButton(
          onPressed: () {
            if (jobAsync.value != null) {
              ref
                  .read(seekerApplicationsProvider(null).notifier)
                  .toggleSave(jobAsync.value!);
              // Give backend a moment to process the save/unsave before refetching
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) {
                  ref.invalidate(seekerJobDetailProvider(widget.jobId));
                }
              });
              UJobToast.success(
                context,
                isSaved ? context.l10n.jobUnsavedTitle : context.l10n.jobSavedTitle,
                sub: isSaved ? context.l10n.savedJobRemovedSubtitle : context.l10n.savedJobAddedSubtitle,
              );
            }
          },
          icon: HugeIcon(
            icon: isSaved
                ? HugeIcons.strokeRoundedBookmark01
                : HugeIcons.strokeRoundedBookmark02,
            color: isSaved ? AppColors.seekPrimary : AppColors.text,
            size: 24.r,
          ),
        ),
      ),
      body: jobAsync.when(
        loading: () => const UJobLoading(count: 1),
        error: (err, stack) {
          if (err is DioException && err.response?.statusCode == 404) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedFileRemove,
                    color: AppColors.muted,
                    size: 64.r,
                  ),
                  SizedBox(height: 16.h),
                  Text('Job Unavailable', style: AppText.heading2),
                  SizedBox(height: 8.h),
                  Text(
                    'This job might have been removed or closed.',
                    style: AppText.body.copyWith(color: AppColors.muted),
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: 160.w,
                    child: UJobButton(
                      label: 'Go Back',
                      onTap: () => context.pop(),
                    ),
                  ),
                ],
              ),
            );
          }
          return UJobError(
            message: l10n.error,
            onRetry: () => ref.refresh(seekerJobDetailProvider(widget.jobId)),
          );
        },
        data: (job) {
          final isApplied = _hasApplied || job.isApplied;
          final isDeadlineExpired =
              job.closesAt != null && _isDeadlinePassed(job.closesAt!);
          String applyLabel = 'Applied';
          if (job.applicationStatus != null && job.applicationStatus!.isNotEmpty) {
            applyLabel = 'Status: ${job.applicationStatus![0].toUpperCase()}${job.applicationStatus!.substring(1)}';
          }

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(seekerJobDetailProvider(widget.jobId));
                },
                color: AppColors.seekPrimary,
                child: NestedScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // --- HEADER ---
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (job.company?.logo != null && job.company!.logo!.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12.r),
                                    child: UJobImage(
                                      path: job.company!.logo!,
                                      width: 56.r,
                                      height: 56.r,
                                      fit: BoxFit.contain,
                                    ),
                                  )
                                else
                                  Container(
                                    width: 56.r,
                                    height: 56.r,
                                    decoration: BoxDecoration(
                                      color: AppColors.seekPrimary,
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      job.company?.name.isNotEmpty == true ? job.company!.name[0].toUpperCase() : 'C',
                                      style: AppText.heading2.copyWith(
                                        color: AppColors.surface,
                                      ),
                                    ),
                                  ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      Wrap(
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        children: [
                                          HugeIcon(
                                            icon: HugeIcons
                                                .strokeRoundedLocation01,
                                            color: AppColors.muted,
                                            size: 12.r,
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            job.location ?? 'Remote',
                                            style: AppText.small.copyWith(
                                              color: AppColors.muted,
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          HugeIcon(
                                            icon:
                                                HugeIcons.strokeRoundedClock01,
                                            color: AppColors.muted,
                                            size: 12.r,
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            _formatDate(job.createdAt),
                                            style: AppText.small.copyWith(
                                              color: AppColors.muted,
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          Container(
                                            width: 3.r,
                                            height: 3.r,
                                            decoration: const BoxDecoration(
                                              color: AppColors.border,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            '${job.applicantCount} applied',
                                            style: AppText.small.copyWith(
                                              color: AppColors.muted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Share.share('Check out this job on UJobs: ${job.title} at ${job.company?.name ?? 'Company'}! ${Ep.webUrl}/jobs/${job.id}');
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12.w,
                                          vertical: 6.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          borderRadius: BorderRadius.circular(
                                            20.r,
                                          ),
                                          border: Border.all(
                                            color: AppColors.borderLight,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            HugeIcon(
                                              icon: HugeIcons
                                                  .strokeRoundedShare01,
                                              color: AppColors.text,
                                              size: 16.r,
                                            ),
                                            SizedBox(width: 6.w),
                                            Text(
                                              'Share',
                                              style: AppText.small.copyWith(
                                                color: AppColors.text,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    /*
                                    SizedBox(height: 8.h),
                                    GestureDetector(
                                      onTap: () {
                                        UJobToast.info(
                                          context,
                                          'Not yet available',
                                          sub:
                                              'You can only message the company after being shortlisted for an interview.',
                                        );
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12.w,
                                          vertical: 6.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          borderRadius: BorderRadius.circular(
                                            20.r,
                                          ),
                                          border: Border.all(
                                            color: AppColors.borderLight,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            HugeIcon(
                                              icon: HugeIcons
                                                  .strokeRoundedMessage02,
                                              color: AppColors.muted,
                                              size: 16.r,
                                            ),
                                            SizedBox(width: 6.w),
                                            Text(
                                              'Message',
                                              style: AppText.small.copyWith(
                                                color: AppColors.muted,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    */
                                  ],
                                ),
                              ],
                            ),

                            SizedBox(height: 24.h),

                            // --- QUICK FACTS ---
                            Container(
                              padding: EdgeInsets.all(16.r),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: AppColors.borderLight,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _QuickFactItem(
                                      icon: HugeIcons.strokeRoundedMoney01,
                                      label: l10n.salary,
                                      value: job.salaryMin != null
                                          ? '${job.salaryCurrency ?? '\$'}${job.salaryMin} - ${job.salaryCurrency ?? '\$'}${job.salaryMax}${job.salaryPeriod != null ? ' / ${job.salaryPeriod}' : ''}'
                                          : l10n.notSpecified,
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 40.h,
                                    color: AppColors.borderLight,
                                  ),
                                  Expanded(
                                    child: _QuickFactItem(
                                      icon: HugeIcons.strokeRoundedBriefcase01,
                                      label: l10n.jobType,
                                      value: job.employmentType.replaceAll('_', ' ').toUpperCase(),
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 40.h,
                                    color: AppColors.borderLight,
                                  ),
                                  Expanded(
                                    child: _QuickFactItem(
                                      icon: HugeIcons.strokeRoundedLocation01,
                                      label: l10n.workplace,
                                      value: job.workplaceType.replaceAll('_', ' ').toUpperCase(),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // --- ACCOUNT STATUS BANNER ---
                            if (profileStatus == 'inactive') ...[
                              SizedBox(height: 12.h),
                              UJobAccountStatusBanner(
                                status: profileStatus!,
                                title: context.l10n.accountInactiveTitle,
                                message: context.l10n.accountInactiveSubtitle,
                              ),
                            ] else if (profileStatus == 'pending') ...[
                              SizedBox(height: 12.h),
                              UJobAccountStatusBanner(
                                status: profileStatus!,
                                title: context.l10n.accountReviewingTitle,
                                message: context.l10n.accountReviewingSubtitle,
                              ),
                            ],

                            // --- DEADLINE BANNER ---
                            if (job.closesAt != null) ...[
                              SizedBox(height: 12.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 10.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(alpha: 0.07),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: AppColors.error.withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    HugeIcon(
                                      icon: HugeIcons.strokeRoundedCalendar03,
                                      color: AppColors.error,
                                      size: 18.r,
                                    ),
                                    SizedBox(width: 10.w),
                                    Text(
                                      'Deadline',
                                      style: AppText.small.copyWith(
                                        color: AppColors.error,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    Container(
                                      width: 1,
                                      height: 14.h,
                                      color: AppColors.error.withValues(alpha: 0.3),
                                    ),
                                    SizedBox(width: 6.w),
                                    Text(
                                      _formatDeadline(job.closesAt!),
                                      style: AppText.small.copyWith(
                                        color: AppColors.error,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (_isDeadlinePassed(job.closesAt!))
                                      _DeadlineBadge(label: 'Expired')
                                    else if (_isDeadlineSoon(job.closesAt!))
                                      _DeadlineBadge(label: 'Closing Soon'),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _TabBarDelegate(
                        TabBar(
                          controller: _tabController,
                          labelColor: AppColors.seekPrimary,
                          unselectedLabelColor: AppColors.muted,
                          indicatorColor: AppColors.seekPrimary,
                          indicatorWeight: 3,
                          tabs: const [
                            Tab(text: 'Job Details'),
                            Tab(text: 'Requirements'),
                            Tab(text: 'Company'),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    // --- TAB 1: JOB DETAILS ---
                    ListView(
                      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 120.h),
                      children: [
                        Container(
                          padding: EdgeInsets.all(16.r),
                          margin: EdgeInsets.only(bottom: 24.h),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Job Description', style: AppText.heading3),
                              SizedBox(height: 12.h),
                              UJobRichTextDisplay(content: job.description),
                            ],
                          ),
                        ),

                        if (job.benefits != null && job.benefits!.isNotEmpty)
                          Container(
                            padding: EdgeInsets.all(16.r),
                            margin: EdgeInsets.only(bottom: 24.h),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Benefits', style: AppText.heading3),
                                SizedBox(height: 12.h),
                                Wrap(
                                  spacing: 8.w,
                                  runSpacing: 8.h,
                                  children: job.benefits!
                                      .map((b) => _BenefitChip(label: b))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),

                        if (job.screeningQuestions != null &&
                            job.screeningQuestions!.isNotEmpty)
                          Container(
                            padding: EdgeInsets.all(16.r),
                            margin: EdgeInsets.only(bottom: 24.h),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Screening Questions',
                                  style: AppText.heading3,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  '${job.screeningQuestions!.length} questions required by employer.',
                                  style: AppText.small.copyWith(
                                    color: AppColors.muted,
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                ...job.screeningQuestions!.asMap().entries.map((
                                  entry,
                                ) {
                                  final q = entry.value;
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 12.h),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${entry.key + 1}. ',
                                          style: AppText.body.copyWith(
                                            color: AppColors.text,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            q['question_text'] ?? q['text'] ?? q['question'] ?? '',
                                            style: AppText.body.copyWith(
                                              color: AppColors.text,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),

                        Text('Job Overview', style: AppText.heading3),
                        SizedBox(height: 16.h),
                        Container(
                          padding: EdgeInsets.all(16.r),
                          margin: EdgeInsets.only(bottom: 24.h),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _OverviewRow('Employment', job.employmentType.replaceAll('_', ' ').toUpperCase()),
                              _OverviewRow('Workplace', job.workplaceType.replaceAll('_', ' ').toUpperCase()),
                              if (job.category != null)
                                _OverviewRow('Job Category', job.category!),
                              if (job.location != null)
                                _OverviewRow('Location', job.location!),
                              if (job.openings != null)
                                _OverviewRow(
                                  'Vacancies',
                                  '${job.openings} positions',
                                ),
                              if (job.salaryMin != null)
                                _OverviewRow(
                                  'Salary',
                                  '${job.salaryCurrency ?? '\$'}${job.salaryMin} - ${job.salaryCurrency ?? '\$'}${job.salaryMax}${job.salaryPeriod != null ? ' / ${job.salaryPeriod}' : ''}',
                                ),
                              if (job.closesAt != null)
                                _OverviewRow(
                                  'Deadline',
                                  '${job.closesAt!.day}/${job.closesAt!.month}/${job.closesAt!.year}',
                                ),
                              if (job.experienceLevel != null &&
                                  job.experienceLevel!.isNotEmpty)
                                _OverviewRow(
                                  'Experience',
                                  '${job.experienceLevel} years',
                                ),
                              if (job.education != null)
                                _OverviewRow('Min Education', job.education!),
                              if (job.languages != null &&
                                  job.languages!.isNotEmpty)
                                _OverviewRow(
                                  'Languages',
                                  job.languages!.join(', '),
                                ),
                              if (job.certifications != null &&
                                  job.certifications!.isNotEmpty)
                                _OverviewRow(
                                  'Certifications',
                                  job.certifications!.join(', '),
                                ),
                              if (job.ageMin != null || job.ageMax != null)
                                _OverviewRow(
                                  'Age Limit',
                                  '${job.ageMin ?? 'Any'} - ${job.ageMax ?? 'Any'}',
                                ),
                              if (job.applyVia != null)
                                _OverviewRow('Apply Via', job.applyVia!),
                              if (job.resumeRequirement != null)
                                _OverviewRow('Resume', job.resumeRequirement!),
                              if (job.coverLetterRequirement != null)
                                _OverviewRow(
                                  'Cover Letter',
                                  job.coverLetterRequirement!,
                                  isLast: true,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // --- TAB 2: REQUIREMENTS ---
                    ListView(
                      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 120.h),
                      children: [
                        if (job.responsibilities != null &&
                            job.responsibilities!.isNotEmpty)
                          Container(
                            padding: EdgeInsets.all(16.r),
                            margin: EdgeInsets.only(bottom: 24.h),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Responsibilities',
                                  style: AppText.heading3,
                                ),
                                SizedBox(height: 12.h),
                                UJobRichTextDisplay(content: job.responsibilities!),
                              ],
                            ),
                          ),
                        if (job.requiredSkills != null &&
                            job.requiredSkills!.isNotEmpty)
                          Container(
                            padding: EdgeInsets.all(16.r),
                            margin: EdgeInsets.only(bottom: 24.h),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Required Skills',
                                  style: AppText.heading3,
                                ),
                                SizedBox(height: 12.h),
                                UJobRichTextDisplay(content: job.requiredSkills!),
                              ],
                            ),
                          ),
                        if (job.preferredSkills != null &&
                            job.preferredSkills!.isNotEmpty)
                          Container(
                            padding: EdgeInsets.all(16.r),
                            margin: EdgeInsets.only(bottom: 24.h),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Preferred Skills',
                                  style: AppText.heading3,
                                ),
                                SizedBox(height: 12.h),
                                Wrap(
                                  spacing: 8.w,
                                  runSpacing: 8.h,
                                  children: job.preferredSkills!
                                      .map((s) => _SkillChip(label: s))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        if (job.languages != null && job.languages!.isNotEmpty)
                          Container(
                            padding: EdgeInsets.all(16.r),
                            margin: EdgeInsets.only(bottom: 24.h),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Languages Required',
                                  style: AppText.heading3,
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  job.languages!.join(', '),
                                  style: AppText.body.copyWith(
                                    color: AppColors.text2,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (job.responsibilities == null &&
                            job.requiredSkills == null &&
                            job.preferredSkills == null)
                          Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 40.h),
                              child: Text(
                                'No specific requirements listed.',
                                style: AppText.body.copyWith(
                                  color: AppColors.muted,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    // --- TAB 3: COMPANY ---
                    ListView(
                      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 120.h),
                      children: [
                        Container(
                          padding: EdgeInsets.all(16.r),
                          margin: EdgeInsets.only(bottom: 24.h),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'About ${job.company?.name ?? 'Company'}',
                                style: AppText.heading3,
                              ),
                              SizedBox(height: 16.h),
                              job.company?.description != null
                                  ? UJobRichTextDisplay(content: job.company!.description!)
                                  : Text(
                                      'No description available for this company.',
                                      style: AppText.body.copyWith(
                                        color: AppColors.text2,
                                        height: 1.5,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        
                        Builder(
                          builder: (context) {
                            String formatCompanySize(String size) {
                              if (size.trim().isEmpty) return size;
                              String s = size.toLowerCase();
                              if (s.startsWith('size_')) {
                                s = s.replaceAll('size_', '');
                              }
                              s = s.replaceAll('_plus', '+');
                              s = s.replaceAll('_', '-');
                              if (!s.contains('employee')) {
                                s = '$s Employees';
                              }
                              return s.split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
                            }

                            String formatIndustry(String ind) {
                              if (ind.trim().isEmpty) return ind;
                              String s = ind.toLowerCase();
                              if (s.startsWith('industry_')) {
                                s = s.replaceAll('industry_', '');
                              }
                              s = s.replaceAll('_', ' ');
                              return s.split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
                            }

                            final Map<String, String> details = {};
                            if (job.company?.industry != null) details['Industry'] = formatIndustry(job.company!.industry!);
                            if (job.company?.size != null) details['Company Size'] = formatCompanySize(job.company!.size!);
                            if (job.company?.founded != null) details['Founded'] = job.company!.founded!;
                            if (job.company?.location != null) details['Location'] = job.company!.location!;
                            if (job.company?.website != null) details['Website'] = job.company!.website!;
                            if (job.company?.linkedinUrl != null) details['LinkedIn'] = job.company!.linkedinUrl!;
                            if (job.company?.facebookUrl != null) details['Facebook'] = job.company!.facebookUrl!;

                            if (details.isEmpty) return const SizedBox.shrink();

                            final entries = details.entries.toList();
                            return Container(
                              padding: EdgeInsets.all(16.r),
                              margin: EdgeInsets.only(bottom: 24.h),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(color: AppColors.borderLight),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Company Overview', style: AppText.heading3),
                                  SizedBox(height: 16.h),
                                  ...entries.asMap().entries.map((entry) {
                                    return _OverviewRow(
                                      entry.value.key,
                                      entry.value.value,
                                      isLast: entry.key == entries.length - 1,
                                    );
                                  }),
                                ],
                              ),
                            );
                          }
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ),

              // --- BOTTOM BAR ---
              if (!isDeadlineExpired || isApplied)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border(
                        top: BorderSide(color: AppColors.borderLight),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: UJobButton(
                            label: isApplied
                                ? applyLabel
                                : 'Apply for this Position',
                            color: isApplied
                                ? AppColors.success
                                : AppColors.seekPrimary,
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
    if (job.closesAt != null && _isDeadlinePassed(job.closesAt!)) {
      return;
    }

    // 0. Resolve profile + account status
    var profileData = ref.read(seekerProfileProvider);

    if (profileData == null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const PopScope(
          canPop: false,
          child: Center(child: CircularProgressIndicator(color: AppColors.seekPrimary)),
        ),
      );
      try { await ref.read(fetchSeekerProfileProvider.future); } catch (_) {}
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      profileData = ref.read(seekerProfileProvider);
    }

    final status = profileData?.status ?? 'pending';

    if (profileData != null && !profileData.isProfileComplete) {
      UJobToast.error(
        context,
        context.l10n.profileIncompleteTitle,
        sub: context.l10n.profileIncompleteSubtitle,
      );
      return;
    }

    if (status == 'suspended') {
      context.go('/suspended');
      return;
    }

    if (status == 'inactive') {
      UJobToast.error(
        context,
        context.l10n.accountInactiveTitle,
        sub: context.l10n.accountInactiveSubtitle,
      );
      return;
    }

    if (status == 'pending') {
      UJobToast.error(
        context,
        context.l10n.accountReviewingTitle,
        sub: context.l10n.accountReviewingSubtitle,
      );
      return;
    }

    // 1. Initial Confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => UJobAlertDialog(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedBriefcase01,
          color: AppColors.seekPrimary,
          size: 32.r,
        ),
        iconBgColor: AppColors.seekPrimary,
        title: 'Apply for this Job?',
        description: 'Are you sure you want to submit your application for ${job.title} at ${job.company?.name ?? 'Company'}?',
        confirmText: 'Apply',
        confirmColor: AppColors.seekPrimary,
        onConfirm: () => Navigator.of(context, rootNavigator: true).pop(true),
      ),
    );

    if (confirmed != true) return;

    // 2. Check Resume Requirement
    final needsResume = job.resumeRequirement != null && 
        job.resumeRequirement!.toLowerCase() != 'optional' && 
        job.resumeRequirement!.toLowerCase() != 'disabled' &&
        job.resumeRequirement!.toLowerCase() != 'false' &&
        job.resumeRequirement!.toLowerCase() != 'no';

    if (needsResume) {
      // Show non-dismissible loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            child: Padding(
              padding: EdgeInsets.all(24.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.seekPrimary),
                  SizedBox(height: 16.h),
                  Text(
                    'Verifying your documents...\nPlease wait a bit.',
                    textAlign: TextAlign.center,
                    style: AppText.bodyBold,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      try {
        await ref.read(fetchSeekerProfileProvider.future);
      } catch (_) {}
      
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog
      
      final profile = ref.read(seekerProfileProvider)?.profile;
      final hasResume = profile?.resumes.isNotEmpty == true;

      if (!hasResume) {
        showDialog(
          context: context,
          builder: (context) => UJobAlertDialog(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedFile02,
              color: AppColors.error,
              size: 32.r,
            ),
            iconBgColor: AppColors.error,
            title: 'Resume Required',
            description: 'This position requires a resume. Please upload your CV in your profile before applying.',
            confirmText: 'Go to Profile',
            confirmColor: AppColors.seekPrimary,
            onConfirm: () {
              Navigator.of(context, rootNavigator: true).pop();
              context.go('/seeker/profile');
            },
            cancelText: 'Cancel',
          ),
        );
        return; // Stop applying
      }
    }

    // 3. Check Cover Letter / Questions
    final hasQuestions = job.screeningQuestions?.isNotEmpty == true;
    final needsCoverLetter = job.coverLetterRequirement != null && 
        job.coverLetterRequirement!.toLowerCase() != 'disabled' &&
        job.coverLetterRequirement!.toLowerCase() != 'false' &&
        job.coverLetterRequirement!.toLowerCase() != 'no';

    if (!hasQuestions && !needsCoverLetter) {
      // Instant Apply API call
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const PopScope(
          canPop: false,
          child: Center(child: CircularProgressIndicator(color: AppColors.seekPrimary)),
        ),
      );

      try {
        await ref.read(seekerJobServiceProvider).applyJob(widget.jobId);
        ref.invalidate(seekerJobDetailProvider(widget.jobId));
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog
          setState(() => _hasApplied = true);
          UJobToast.success(context, 'Success', sub: 'Application Submitted!');
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog
          UJobToast.error(context, 'Error', sub: 'Failed to submit application.');
        }
      }
      return;
    }

    // 4. Navigate to ApplyScreen
    final result = await context.push<bool>(
      '/seeker/jobs/${widget.jobId}/apply',
      extra: {
        'title': job.title,
        'company': job.company?.name ?? '',
        'source': widget.source ?? 'jobs',
      },
    );
    if (result == true) {
      setState(() => _hasApplied = true);
    }
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _TabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: AppColors.surface, child: _tabBar);
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}

class _QuickFactItem extends StatelessWidget {
  final dynamic icon;
  final String label;
  final String value;

  const _QuickFactItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        HugeIcon(icon: icon, color: AppColors.seekPrimary, size: 24.r),
        SizedBox(height: 8.h),
        Text(label, style: AppText.small.copyWith(color: AppColors.muted)),
        SizedBox(height: 4.h),
        Text(
          value,
          style: AppText.small.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
          textAlign: TextAlign.center,
        ),
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
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedTick02,
            color: AppColors.success,
            size: 16.r,
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: AppText.small.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
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
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        label,
        style: AppText.small.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DeadlineBadge extends StatelessWidget {
  final String label;
  const _DeadlineBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: AppText.small.copyWith(
          color: AppColors.surface,
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
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
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.small.copyWith(color: AppColors.muted)),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              value, 
              style: AppText.bodyBold.copyWith(
                color: (value.startsWith('http')) ? AppColors.seekPrimary : AppColors.text,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
