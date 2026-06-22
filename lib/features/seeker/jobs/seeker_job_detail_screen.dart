import 'package:flutter/material.dart';
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

class _SeekerJobDetailScreenState extends ConsumerState<SeekerJobDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _hasApplied = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
              NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: AppSpacing.pagePad,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 12.h),
                            // Logo Box
                            Container(
                              width: 72.r,
                              height: 72.r,
                              decoration: BoxDecoration(
                                color: AppColors
                                    .error, // Just a placeholder color (red for Airbnb)
                                borderRadius: BorderRadius.circular(18.r),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                job.company?.name[0].toUpperCase() ?? 'C',
                                style: AppText.heading1.copyWith(
                                  color: AppColors.surface,
                                  fontSize: 32.sp,
                                ),
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              job.title,
                              style: AppText.heading1,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              job.company?.name ?? 'Company',
                              style: AppText.heading3.copyWith(
                                color: AppColors.seekPrimary,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedLocation01,
                                  color: AppColors.muted,
                                  size: 16.r,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  job.location ?? 'Remote',
                                  style: AppText.body.copyWith(
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            // Chips
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              alignment: WrapAlignment.center,
                              children: [
                                _TagChip(
                                  label: '\$120k-\$160k',
                                  color: AppColors.seekPrimary.withValues(
                                    alpha: 0.1,
                                  ),
                                  textColor: AppColors.seekPrimary,
                                ),
                                _TagChip(
                                  label: job.employmentType ?? 'Full-time',
                                  color: AppColors.borderLight,
                                  textColor: AppColors.text2,
                                ),
                                _TagChip(
                                  label: 'Remote',
                                  color: AppColors.success.withValues(
                                    alpha: 0.1,
                                  ),
                                  textColor: AppColors.success,
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Posted ${_formatDate(job.createdAt)} · 47 applicants',
                              style: AppText.small.copyWith(
                                color: AppColors.grey600,
                              ),
                            ),
                            SizedBox(height: 24.h),
                          ],
                        ),
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverTabBarDelegate(
                        TabBar(
                          controller: _tabController,
                          labelColor: AppColors.seekPrimary,
                          unselectedLabelColor: AppColors.muted,
                          indicatorColor: AppColors.seekPrimary,
                          indicatorWeight: 3,
                          labelStyle: AppText.bodyBold,
                          unselectedLabelStyle: AppText.body,
                          tabs: const [
                            Tab(text: 'Overview'),
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
                    _OverviewTab(job: job),
                    _RequirementsTab(job: job),
                    _CompanyTab(job: job),
                  ],
                ),
              ),

              // Fixed Bottom Bar
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
                          color: isApplied
                              ? AppColors.success
                              : AppColors.seekPrimary,
                          onTap: isApplied
                              ? null
                              : () async {
                                  final result = await context.push<bool>(
                                    '/seeker/jobs/${widget.jobId}/apply',
                                    extra: {
                                      'title': job.title,
                                      'company': job.company?.name ?? '',
                                    },
                                  );
                                  if (result == true) {
                                    setState(() {
                                      _hasApplied = true;
                                    });
                                  }
                                },
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
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _TagChip({
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(color: color, borderRadius: AppRadius.pill),
      child: Text(
        label,
        style: AppText.small
            .copyWith(fontWeight: FontWeight.bold)
            .copyWith(color: textColor),
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: AppColors.surface, child: tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}

class _OverviewTab extends StatelessWidget {
  final dynamic job;
  const _OverviewTab({required this.job});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 100.h),
      children: [
        Text('About the Role', style: AppText.heading2),
        SizedBox(height: 12.h),
        if (job.description != null && job.description!.isNotEmpty)
          job.description!.startsWith('{')
              ? UJobRichTextDisplay(content: job.description!)
              : Text(
                  job.description!,
                  style: AppText.body.copyWith(
                    color: AppColors.text2,
                    height: 1.5,
                  ),
                )
        else
          Text(
            'We are looking for an experienced professional to join our team.',
            style: AppText.body.copyWith(color: AppColors.text2, height: 1.5),
          ),

        SizedBox(height: 24.h),
        Text('Key Responsibilities', style: AppText.heading3),
        SizedBox(height: 12.h),
        // Placeholder for responsibilities if not in description json
        _BulletPoint(
          text: 'Lead product design end-to-end from concept to launch',
        ),
        _BulletPoint(
          text: 'Collaborate with cross-functional teams on product strategy',
        ),
        _BulletPoint(text: 'Build and maintain our core design system'),
        _BulletPoint(text: 'Conduct user research and usability testing'),
        _BulletPoint(text: 'Present design decisions to senior leadership'),
      ],
    );
  }
}

class _RequirementsTab extends StatelessWidget {
  final dynamic job;
  const _RequirementsTab({required this.job});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 100.h),
      children: [
        Text('Requirements', style: AppText.heading2),
        SizedBox(height: 12.h),
        _BulletPoint(text: 'Minimum 3 years of experience'),
        _BulletPoint(text: 'Strong communication skills'),
        _BulletPoint(text: 'Bachelor\'s degree or equivalent experience'),
      ],
    );
  }
}

class _CompanyTab extends StatelessWidget {
  final dynamic job;
  const _CompanyTab({required this.job});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 100.h),
      children: [
        Text(
          'About ${job.company?.name ?? 'Company'}',
          style: AppText.heading2,
        ),
        SizedBox(height: 12.h),
        Text(
          job.company?.description ??
              'No description available for this company.',
          style: AppText.body.copyWith(color: AppColors.text2, height: 1.5),
        ),
      ],
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;
  const _BulletPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Container(
              width: 6.r,
              height: 6.r,
              decoration: const BoxDecoration(
                color: AppColors.seekPrimary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: AppText.body.copyWith(color: AppColors.text2, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
