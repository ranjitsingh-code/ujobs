import '../../../core/models/application.dart';
import '../applications/seeker_application_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/widgets/ujob_toast.dart';
import '../../../../core/utils/l10n_extensions.dart';

import '../../../core/models/company.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ujob_app_bar.dart';
import '../../../core/widgets/ujob_button.dart';
import '../../../core/widgets/ujob_loading.dart';
import '../../../core/widgets/ujob_alert_dialog.dart';
import '../../../core/widgets/ujob_job_card.dart';
import '../jobs/seeker_job_provider.dart';

class SeekerCompanyProfileScreen extends ConsumerStatefulWidget {
  final Company company;

  const SeekerCompanyProfileScreen({super.key, required this.company});

  @override
  ConsumerState<SeekerCompanyProfileScreen> createState() =>
      _SeekerCompanyProfileScreenState();
}

class _SeekerCompanyProfileScreenState
    extends ConsumerState<SeekerCompanyProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(seekerJobsProvider);
    final openPositionsCount = jobsAsync.when(
      data: (jobs) =>
          jobs.where((j) => j.company?.id == widget.company.id).length,
      loading: () => 0,
      error: (_, _) => 0,
    );

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: UJobAppBar(title: context.l10n.companyProfile),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Header Section
                  Container(
                    color: AppColors.surface,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 16.h,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 56.r,
                          height: 56.r,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          alignment: Alignment.center,
                          child: widget.company.logo != null &&
                                  widget.company.logo!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: Image.network(
                                    widget.company.logo!,
                                    width: 56.r,
                                    height: 56.r,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Text(
                                      widget.company.name.isNotEmpty
                                          ? widget.company.name[0]
                                              .toUpperCase()
                                          : 'C',
                                      style: AppText.heading2.copyWith(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                )
                              : Text(
                                  widget.company.name.isNotEmpty
                                      ? widget.company.name[0].toUpperCase()
                                      : 'C',
                                  style: AppText.heading2.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    widget.company.name,
                                    style: AppText.titleMd,
                                  ),
                                  if (widget.company.isVerified == true) ...[
                                    SizedBox(width: 8.w),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6.w,
                                        vertical: 2.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.successBg,
                                        borderRadius: BorderRadius.circular(
                                          4.r,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          HugeIcon(
                                            icon: HugeIcons
                                                .strokeRoundedCheckmarkBadge01,
                                            color: AppColors.success,
                                            size: 12.r,
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            'Verified',
                                            style: AppText.small.copyWith(
                                              color: AppColors.success,
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                widget.company.industry ??
                                    context.l10n.companyProfile,
                                style: AppText.small.copyWith(
                                  color: AppColors.muted2,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Row(
                                children: [
                                  HugeIcon(
                                    icon: HugeIcons.strokeRoundedLocation01,
                                    color: AppColors.muted,
                                    size: 12.r,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    widget.company.location ?? 'Worldwide',
                                    style: AppText.small.copyWith(
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6.h),
                              Row(
                                children: [
                                  HugeIcon(
                                    icon: HugeIcons.strokeRoundedBriefcase02,
                                    color: AppColors.seekPrimary,
                                    size: 12.r,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '$openPositionsCount Open Positions',
                                    style: AppText.small.copyWith(
                                      color: AppColors.seekPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: HugeIcon(
                                icon: HugeIcons.strokeRoundedInformationCircle,
                                color: AppColors.muted,
                                size: 24.r,
                              ),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: AppColors.surface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(24.r),
                                    ),
                                  ),
                                  builder: (context) =>
                                      _buildCompanyInfoModal(context),
                                );
                              },
                            ),
                            SizedBox(height: 8.h),
                            InkWell(
                              onTap: () {
                                UJobToast.info(
                                  context,
                                  'Not yet available',
                                  sub:
                                      'You can only message the company after being shortlisted for an interview.',
                                );
                              },
                              borderRadius: BorderRadius.circular(8.r),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4.w,
                                  vertical: 4.h,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    HugeIcon(
                                      icon: HugeIcons.strokeRoundedMessage02,
                                      color: AppColors.muted,
                                      size: 16.r,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      'Message',
                                      style: AppText.small.copyWith(
                                        color: AppColors.muted,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  // Actions Section
                  Container(
                    color: AppColors.surface,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 16.h,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: InkWell(
                            onTap: () => _showSocialsModal(context),
                            borderRadius: BorderRadius.circular(16.r),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              decoration: BoxDecoration(
                                color: AppColors.seekPrimary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  HugeIcon(
                                    icon: HugeIcons.strokeRoundedUserAdd01,
                                    color: AppColors.seekPrimary,
                                    size: 20.r,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Follow Us',
                                    style: AppText.bodyBold.copyWith(
                                      color: AppColors.seekPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          flex: 5,
                          child: UJobButton(
                            label: context.l10n.website,
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedLink01,
                              color: AppColors.surface,
                              size: 20.r,
                            ),
                            gradient: AppColors.authGradient,
                            onTap: () {
                              final url = widget.company.website;
                              if (url == null || url.isEmpty) {
                                UJobToast.info(context, 'Unavailable', sub: 'No website available for this company');
                                return;
                              }

                              showDialog(
                                context: context,
                                builder: (context) => UJobAlertDialog(
                                  icon: HugeIcon(
                                    icon: HugeIcons.strokeRoundedGlobal,
                                    color: AppColors.seekPrimary,
                                    size: 32.r,
                                  ),
                                  iconBgColor: AppColors.seekPrimary,
                                  title: 'Open Browser?',
                                  description:
                                      'This will open the company website in your external web browser. Do you want to continue?',
                                  confirmText: 'Open',
                                  confirmColor: AppColors.seekPrimary,
                                  onConfirm: () async {
                                    Navigator.pop(context);
                                    final uri = Uri.parse(url);
                                    try {
                                      final launched = await launchUrl(
                                        uri,
                                        mode: LaunchMode.externalApplication,
                                      );
                                      if (!launched) throw Exception('Could not launch');
                                    } catch (e) {
                                      if (context.mounted) {
                                        UJobToast.error(
                                          context,
                                          'Could not launch URL',
                                        );
                                      }
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],
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
                  labelStyle: AppText.bodyBold,
                  unselectedLabelStyle: AppText.body,
                  tabs: [
                    Tab(text: context.l10n.aboutCompany),
                    Tab(text: context.l10n.jobs),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildAboutTab(openPositionsCount),
            _buildJobsTab(jobsAsync),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyInfoModal(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24.w,
        24.h,
        24.w,
        MediaQuery.of(context).padding.bottom + 24.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Company Details', style: AppText.heading2),
              IconButton(
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedCancel01,
                  color: AppColors.text,
                  size: 24.r,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          _infoRow(
            HugeIcons.strokeRoundedBuilding03,
            'Industry',
            widget.company.industry ?? 'N/A',
          ),
          SizedBox(height: 16.h),
          _infoRow(
            HugeIcons.strokeRoundedLocation01,
            'Location',
            widget.company.location ?? 'Worldwide',
          ),
          SizedBox(height: 16.h),
          _infoRow(
            HugeIcons.strokeRoundedUserMultiple,
            'Team Size',
            widget.company.size ?? 'N/A',
          ),
          SizedBox(height: 16.h),
          _infoRow(
            HugeIcons.strokeRoundedCalendar01,
            'Founded',
            widget.company.founded ?? 'N/A',
          ),
          SizedBox(height: 16.h),
          _infoRow(
            HugeIcons.strokeRoundedGlobal,
            'Website',
            widget.company.website ?? 'N/A',
          ),
        ],
      ),
    );
  }

  void _showSocialsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        final hasLinkedIn =
            widget.company.linkedinUrl != null &&
            widget.company.linkedinUrl!.isNotEmpty;
        final hasFacebook =
            widget.company.facebookUrl != null &&
            widget.company.facebookUrl!.isNotEmpty;
        final linkedinUrl = hasLinkedIn
            ? widget.company.linkedinUrl!
            : 'https://linkedin.com/company/ujobs-demo';
        final facebookUrl = hasFacebook
            ? widget.company.facebookUrl!
            : 'https://facebook.com/ujobs-demo';

        return Padding(
          padding: EdgeInsets.fromLTRB(
            24.w,
            24.h,
            24.w,
            MediaQuery.of(context).padding.bottom + 24.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Follow Us', style: AppText.heading2),
                  IconButton(
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedCancel01,
                      color: AppColors.text,
                      size: 24.r,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              _socialRow(
                HugeIcons.strokeRoundedLinkedin01,
                'LinkedIn',
                AppColors.primary,
                linkedinUrl,
                context,
              ),
              SizedBox(height: 16.h),
              _socialRow(
                HugeIcons.strokeRoundedFacebook01,
                'Facebook',
                const Color(0xFF1877F2),
                facebookUrl,
                context,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _socialRow(
    List<List<dynamic>> icon,
    String label,
    Color brandColor,
    String url,
    BuildContext context,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final uri = Uri.parse(url);
            try {
              final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
              if (!launched) throw Exception('Could not launch');
            } catch (e) {
              if (context.mounted) {
                UJobToast.error(context, 'Error', sub: 'Could not launch URL');
              }
            }
          },
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                HugeIcon(icon: icon, color: brandColor, size: 24.r),
                SizedBox(width: 16.w),
                Expanded(child: Text(label, style: AppText.bodyBold)),
                IconButton(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: url));
                    if (context.mounted) {
                      UJobToast.success(context, 'Copied', sub: 'Link copied to clipboard!');
                    }
                  },
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedCopy01,
                    color: AppColors.muted,
                    size: 20.r,
                  ),
                  tooltip: 'Copy Link',
                ),
                HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowRight01,
                  color: AppColors.muted,
                  size: 20.r,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(List<List<dynamic>> icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: HugeIcon(icon: icon, color: AppColors.muted, size: 20.r),
        ),
        SizedBox(width: 16.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppText.small.copyWith(color: AppColors.muted)),
            SizedBox(height: 2.h),
            Text(value, style: AppText.bodyBold),
          ],
        ),
      ],
    );
  }

  Widget _buildAboutTab(int openPositionsCount) {
    return ListView(
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
              Text(context.l10n.aboutCompany, style: AppText.heading3),
              SizedBox(height: 12.h),
              Text(
                widget.company.description ??
                    context.l10n.noDescriptionAvailable,
                style: AppText.body.copyWith(
                  color: AppColors.text2,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
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
              Text('Work Culture', style: AppText.heading3),
              SizedBox(height: 16.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Team Size',
                          style: AppText.small.copyWith(color: AppColors.muted),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          widget.company.size ?? 'N/A',
                          style: AppText.bodyBold,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Founded',
                          style: AppText.small.copyWith(color: AppColors.muted),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          widget.company.founded ?? 'N/A',
                          style: AppText.bodyBold,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJobsTab(AsyncValue jobsAsync) {
    return jobsAsync.when(
      data: (jobs) {
        final companyJobs = jobs
            .where((j) => j.company?.id == widget.company.id)
            .toList();

        if (companyJobs.isEmpty) {
          return Center(
            child: Text(
              context.l10n.noOpenPositions,
              style: AppText.body.copyWith(color: AppColors.muted),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.all(20.r),
          itemCount: companyJobs.length,
          separatorBuilder: (context, index) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            final job = companyJobs[index];
            final apps =
                ref.watch(seekerApplicationsProvider(null)).value ?? [];
            final isSaved = apps.any(
              (a) => a.job.id == job.id && a.status == ApplicationStatus.saved,
            );

            return UJobJobCard(
              job: job.copyWith(isSaved: isSaved),
              onTap: () => context.push('/seeker/jobs/${job.id}'),
              onSaveTap: () {
                ref
                    .read(seekerApplicationsProvider(null).notifier)
                    .toggleSave(job);
                UJobToast.success(
                  context,
                  isSaved ? 'Job Unsaved' : 'Job Saved',
                  sub: isSaved ? 'This job has been removed from your saved jobs.' : 'This job has been saved to your list.',
                );
              },
            );
          },
        );
      },
      loading: () => UJobLoading(count: 1),
      error: (e, s) => Center(child: Text(context.l10n.errorLoadingJobs)),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

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
  bool shouldRebuild(_TabBarDelegate oldDelegate) {
    return false;
  }
}
