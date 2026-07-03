import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/l10n_extensions.dart';
import '../../../core/widgets/ujob_loading.dart';
import '../../../core/widgets/ujob_error.dart';
import '../../../core/widgets/ujob_job_card.dart';
import 'seeker_dashboard_provider.dart';
import '../applications/seeker_application_provider.dart';
import '../../../core/models/application.dart';
import '../../../core/widgets/ujob_toast.dart';
import '../../../core/widgets/ujob_notification_button.dart';
import '../../../core/widgets/ujob_dashboard_section_header.dart';
import '../../../core/widgets/ujob_boxed_empty_state.dart';
import '../../../core/widgets/ujob_verification_banners.dart';

class SeekerDashboardScreen extends ConsumerWidget {
  const SeekerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final dashboardAsync = ref.watch(seekerDashboardProvider);
    final l10n = context.l10n;

    final int hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    final String name = auth.when(
      data: (u) => u != null ? u.firstName : 'Seeker',
      loading: () => '...',
      error: (_, _) => 'Seeker',
    );

    final String initials = auth.when(
      data: (u) => u != null && u.firstName.isNotEmpty && u.lastName.isNotEmpty
          ? '${u.firstName[0]}${u.lastName[0]}'.toUpperCase()
          : 'AJ',
      loading: () => '..',
      error: (_, _) => 'AJ',
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: dashboardAsync.when(
        loading: () => const UJobLoading(),
        error: (e, st) => UJobError(
          message: l10n.error,
          onRetry: () => ref.refresh(seekerDashboardProvider),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(seekerDashboardProvider);
          },
          color: AppColors.seekPrimary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
            SliverToBoxAdapter(
              child: _DashboardHeader(
                greeting: greeting,
                name: name,
                initials: initials,
                dashboard: data,
                onNotificationsTap: () => context.push('/seeker/notifications'),
                onAppliedTap: () => context.go('/seeker/applied', extra: 2),
                onMatchesTap: () => context.go('/seeker/jobs'),
                onSavedTap: () => context.push('/seeker/saved-jobs'),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: AppSpacing.pagePad,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Account status banner
                    if (data.status == 'inactive') ...[
                      UJobAccountStatusBanner(
                        status: data.status,
                        title: context.l10n.accountInactiveTitle,
                        message: context.l10n.accountInactiveSubtitle,
                      ),
                      SizedBox(height: 24.h),
                    ] else if (data.status == 'pending') ...[
                      UJobAccountStatusBanner(
                        status: data.status,
                        title: context.l10n.accountReviewingTitle,
                        message: context.l10n.accountReviewingSubtitle,
                      ),
                      SizedBox(height: 24.h),
                    ],

                    // Messages (Commented out as per user request)
                    /*
                    if (needsReply.isNotEmpty) ...[
                      UJobMessagesToReply(
                        conversations: needsReply,
                        onViewAll: () => context.go('/seeker/messages'),
                      ),
                      SizedBox(height: 32.h),
                    ],
                    */

                    UJobDashboardSectionHeader(
                      title: 'Latest Jobs',
                      actionLabel: 'See all',
                      onActionTap: () => context.go('/seeker/jobs'),
                    ),
                    SizedBox(height: 8.h),
                    if (data.recommendedJobs.isEmpty)
                      const UJobBoxedEmptyState(
                        title: 'No recent jobs found',
                        subtitle:
                            'Check back later or adjust your profile preferences.',
                        icon: HugeIcons.strokeRoundedSearchMinus,
                      )
                    else
                      ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: data.recommendedJobs.length,
                        separatorBuilder: (_, _) => const SizedBox.shrink(),
                        itemBuilder: (context, index) {
                          final job = data.recommendedJobs[index];
                          final apps =
                              ref
                                  .watch(seekerApplicationsProvider(null))
                                  .value ??
                              [];
                          final isSaved = apps.any(
                            (a) =>
                                a.job.id == job.id &&
                                a.status == ApplicationStatus.saved,
                          );
                          return UJobJobCard(
                            job: job.copyWith(isSaved: isSaved),
                            onTap: () => context.push(
                              '/seeker/jobs/${job.id}',
                              extra: {'source': 'dashboard'},
                            ),
                            onSaveTap: () {
                              ref
                                  .read(
                                    seekerApplicationsProvider(null).notifier,
                                  )
                                  .toggleSave(job);
                              UJobToast.success(
                                context,
                                isSaved ? context.l10n.jobUnsavedTitle : context.l10n.jobSavedTitle,
                                sub: isSaved ? context.l10n.savedJobRemovedSubtitle : context.l10n.savedJobAddedSubtitle,
                              );
                            },
                          );
                        },
                      ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final String greeting;
  final String name;
  final String initials;
  final SeekerDashboardData dashboard;
  final VoidCallback onNotificationsTap;
  final VoidCallback onAppliedTap;
  final VoidCallback onMatchesTap;
  final VoidCallback onSavedTap;

  const _DashboardHeader({
    required this.greeting,
    required this.name,
    required this.initials,
    required this.dashboard,
    required this.onNotificationsTap,
    required this.onAppliedTap,
    required this.onMatchesTap,
    required this.onSavedTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppColors.authGradient,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              greeting,
                              style: AppText.body.copyWith(
                                color: AppColors.surface.withValues(alpha: 0.8),
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.heading1.copyWith(
                                color: AppColors.surface,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      UJobNotificationButton(
                        onTap: onNotificationsTap,
                        borderColor: AppColors.seekPrimary,
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      _StatCard(
                        title: '${dashboard.applicationsCount}',
                        subtitle: 'Applied',
                        isSelected: false,
                        onTap: onAppliedTap,
                      ),
                      SizedBox(width: 12.w),
                      _StatCard(
                        title: '${dashboard.matchesCount}',
                        subtitle: 'Matches',
                        isSelected: false,
                        onTap: onMatchesTap,
                      ),
                      SizedBox(width: 12.w),
                      _StatCard(
                        title: '${dashboard.savedCount}',
                        subtitle: 'Saved',
                        isSelected: false,
                        onTap: onSavedTap,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatCard({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.surface
                : AppColors.surface.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : AppColors.surface.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: AppText.heading2.copyWith(
                  color: isSelected ? AppColors.seekPrimary : AppColors.surface,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: AppText.small.copyWith(
                  color: isSelected
                      ? AppColors.muted
                      : AppColors.surface.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
