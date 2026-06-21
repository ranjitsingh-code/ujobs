import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ujob_button.dart';
import '../../../core/widgets/ujob_error.dart';
import '../../../core/widgets/ujob_loading.dart';
import '../../../core/widgets/ujob_app_bar.dart';
import '../../../core/widgets/ujob_image.dart';
import '../../../core/widgets/ujob_rich_text_editor.dart';
import '../../../core/widgets/ujob_rich_text_display.dart';
import 'seeker_job_provider.dart';

class SeekerJobDetailScreen extends ConsumerStatefulWidget {
  final int jobId;
  const SeekerJobDetailScreen({required this.jobId, super.key});

  @override
  ConsumerState<SeekerJobDetailScreen> createState() => _SeekerJobDetailScreenState();
}

class _SeekerJobDetailScreenState extends ConsumerState<SeekerJobDetailScreen> {
  // Mock applied state for testing as requested
  bool _hasApplied = false;

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final jobAsync = ref.watch(seekerJobDetailProvider(widget.jobId));

    return Scaffold(
      backgroundColor: AppColors.bg,
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
          onRetry: () => ref.refresh(seekerJobDetailProvider(widget.jobId)),
        ),
        data: (job) {
          final isApplied = _hasApplied;

          return Stack(
            children: [
              ListView(
                padding: AppSpacing.pagePad.copyWith(bottom: 120.h),
                children: [
                  if (isApplied)
                    Container(
                      margin: EdgeInsets.only(bottom: 16.h),
                      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: AppRadius.md,
                      ),
                      child: Row(
                        children: [
                          HugeIcon(icon: HugeIcons.strokeRoundedCheckmarkBadge01, color: AppColors.primary, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text('Application Submitted', style: AppText.bodyBold.copyWith(color: AppColors.primary)),
                        ],
                      ),
                    ),

                  // Header
                  Text(job.title, style: AppText.heading2),
                  SizedBox(height: 8.h),
                  if (job.company != null)
                    Text(job.company!.name, style: AppText.titleMd.copyWith(color: AppColors.primary)),
                  if (job.location != null) ...[
                    SizedBox(height: 4.h),
                    Text(job.location!, style: AppText.body.copyWith(color: AppColors.muted)),
                  ],
                  SizedBox(height: 4.h),
                  Text('Posted ${_formatDate(job.createdAt)}', style: AppText.small.copyWith(color: AppColors.muted)),
                  
                  SizedBox(height: 24.h),
                  // Top Apply Button
                  UJobButton(
                    label: isApplied ? 'Applied' : 'Apply Now',
                    onTap: isApplied ? null : () async {
                      final result = await context.push<bool>(
                        '/seeker/jobs/${widget.jobId}/apply',
                        extra: {
                          'title': job.title,
                          'company': job.company?.name,
                          'location': job.location,
                        },
                      );
                      if (result == true) {
                        setState(() => _hasApplied = true);
                      }
                    },
                    // outlined: isApplied,
                    // TODO: We can't pass arbitrary color to UJobButton without updating it, but it handles disabled state
                  ),

                  SizedBox(height: 24.h),
                  // Chips / Tags
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      _Badge(icon: HugeIcons.strokeRoundedBriefcase01, label: job.employmentType),
                      _Badge(icon: HugeIcons.strokeRoundedBuilding04, label: job.workplaceType),
                      if (job.category != null) _Badge(icon: HugeIcons.strokeRoundedFolder01, label: job.category!),
                      if (job.salaryMin != null)
                        _Badge(
                          icon: HugeIcons.strokeRoundedMoneyBag02, 
                          label: job.salaryMax != null ? '${job.salaryMin} - ${job.salaryMax}' : job.salaryMin!
                        ),
                    ],
                  ),
                  
                  if (job.closesAt != null) ...[
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        HugeIcon(icon: HugeIcons.strokeRoundedClock01, color: AppColors.warning, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text('Deadline: ${_formatDate(job.closesAt)}', style: AppText.bodyBold.copyWith(color: AppColors.warning)),
                      ],
                    ),
                  ],

                  SizedBox(height: 32.h),

                  // Content Sections
                  _Section(title: 'Job Description', content: job.description),
                  if (job.responsibilities != null) _Section(title: 'Responsibilities', content: job.responsibilities!),
                  if (job.requiredSkills != null) _Section(title: 'Required Skills', content: job.requiredSkills!),
                  if (job.benefits != null && job.benefits!.isNotEmpty) _SectionList(title: 'Benefits', items: job.benefits!),
                  if (job.preferredSkills != null && job.preferredSkills!.isNotEmpty) _SectionList(title: 'Preferred Skills', items: job.preferredSkills!),
                  if (job.languages != null && job.languages!.isNotEmpty) _SectionList(title: 'Languages Required', items: job.languages!),
                  if (job.certifications != null && job.certifications!.isNotEmpty) _SectionList(title: 'Certifications', items: job.certifications!),

                  if (job.screeningQuestions != null && job.screeningQuestions!.isNotEmpty) ...[
                    SizedBox(height: 24.h),
                    Text('Screening Questions', style: AppText.heading3),
                    SizedBox(height: 8.h),
                    Text('${job.screeningQuestions!.length} question(s)', style: AppText.small.copyWith(color: AppColors.primary)),
                    SizedBox(height: 8.h),
                    Text("You'll be asked to answer the following when you apply:", style: AppText.body.copyWith(color: AppColors.muted)),
                    SizedBox(height: 12.h),
                    ...job.screeningQuestions!.map((q) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ', style: AppText.body),
                          Expanded(child: Text(q['question'] ?? '', style: AppText.body)),
                        ],
                      ),
                    )),
                  ],

                  SizedBox(height: 32.h),
                  Container(
                    padding: EdgeInsets.all(20.r),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: AppRadius.lg,
                    ),
                    child: Column(
                      children: [
                        Text('Interested in this role?', style: AppText.heading3),
                        SizedBox(height: 8.h),
                        Text('Apply now and get noticed by the hiring team.', style: AppText.body.copyWith(color: AppColors.muted), textAlign: TextAlign.center),
                        SizedBox(height: 16.h),
                        UJobButton(
                          label: isApplied ? 'Applied' : 'Apply for this Position',
                          onTap: isApplied ? null : () async {
                            final result = await context.push<bool>(
                              '/seeker/jobs/${widget.jobId}/apply',
                              extra: {
                                'title': job.title,
                                'company': job.company?.name,
                                'location': job.location,
                              },
                            );
                            if (result == true) {
                              setState(() => _hasApplied = true);
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32.h),
                  Text('Job Overview', style: AppText.heading3),
                  SizedBox(height: 16.h),
                  // Mock stats or details could go here
                  _OverviewRow(label: context.l10n.experience, value: job.experienceLevel ?? 'Not specified'),
                  _OverviewRow(label: context.l10n.education, value: job.education ?? 'Not specified'),
                  _OverviewRow(label: context.l10n.openings, value: job.openings ?? '1'),
                  if (job.ageMin != null || job.ageMax != null)
                    _OverviewRow(
                      label: context.l10n.age,
                      value: job.ageMin != null && job.ageMax != null 
                          ? '${job.ageMin} - ${job.ageMax} years' 
                          : job.ageMin != null 
                              ? 'From ${job.ageMin} years'
                              : 'Up to ${job.ageMax} years'
                    ),

                  if (job.company != null) ...[
                    SizedBox(height: 32.h),
                    Text('About ${job.company!.name}', style: AppText.heading3),
                    SizedBox(height: 16.h),
                    if (job.company!.logo != null)
                      Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: UJobImage(
                          path: job.company!.logo!,
                          width: 64.r,
                          height: 64.r,
                          fit: BoxFit.cover,
                          borderRadius: AppRadius.md,
                        ),
                      ),
                    if (job.company!.description != null)
                      UJobRichTextDisplay(content: job.company!.description!),
                  ]
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(top: BorderSide(color: AppColors.borderLight)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        Expanded(
                          child: UJobButton(
                            label: isApplied ? 'Applied' : 'Apply for This Job',
                            onTap: isApplied ? null : () async {
                              final result = await context.push<bool>(
                                '/seeker/jobs/${widget.jobId}/apply',
                                extra: {
                                  'title': job.title,
                                  'company': job.company?.name,
                                  'location': job.location,
                                },
                              );
                              if (result == true) {
                                setState(() => _hasApplied = true);
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 12.w),
                        UJobButton(
                          label: context.l10n.saveJob,
                          outlined: true,
                          onTap: () {}, // TODO: save job
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String content;
  const _Section({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.heading3),
          SizedBox(height: 12.h),
          UJobRichTextDisplay(content: content),
        ],
      ),
    );
  }
}

class _SectionList extends StatelessWidget {
  final String title;
  final List<String> items;
  const _SectionList({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.heading3),
          SizedBox(height: 12.h),
          ...items.map((item) => Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: AppText.body),
                Expanded(child: Text(item, style: AppText.body)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _OverviewRow extends StatelessWidget {
  final String label;
  final String value;
  const _OverviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: 12.h),
    child: Row(
      children: [
        SizedBox(width: 120.w, child: Text(label, style: AppText.body.copyWith(color: AppColors.muted))),
        Expanded(child: Text(value, style: AppText.bodyBold)),
      ],
    ),
  );
}

class _Badge extends StatelessWidget {
  final dynamic icon;
  final String label;
  const _Badge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.sm,
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(icon: icon, color: AppColors.muted, size: 16.sp),
            SizedBox(width: 6.w),
            Text(label, style: AppText.small),
          ],
        ),
      );
}
