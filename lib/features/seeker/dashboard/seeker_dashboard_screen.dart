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

class SeekerDashboardScreen extends ConsumerWidget {
  const SeekerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final dashboardAsync = ref.watch(seekerDashboardProvider);
    final l10n = context.l10n;

    final String greeting = 'Good morning'; // Static for now, can be dynamic based on time
    final String name = auth.when(
      data: (u) => u != null ? u.firstName : 'Seeker',
      loading: () => '...',
      error: (_, _) => 'Seeker',
    );
    
    final String initials = auth.when(
      data: (u) => u != null ? '${u.firstName[0]}${u.lastName[0]}'.toUpperCase() : 'AJ',
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
        data: (data) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _DashboardHeader(
                greeting: greeting,
                name: name,
                initials: initials,
                dashboard: data,
                onNotificationsTap: () => context.push('/seeker/notifications'),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: AppSpacing.pagePad,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    

                    
                    _SectionHeader(
                      title: 'Latest Jobs',
                      actionLabel: 'See all',
                      onActionTap: () => context.go('/seeker/jobs'),
                    ),
                    SizedBox(height: 16.h),
                    if (data.recommendedJobs.isEmpty)
                      const _EmptyState(
                        title: 'No recent jobs found',
                        subtitle: 'Check back later or adjust your profile preferences.',
                        icon: HugeIcons.strokeRoundedSearchMinus,
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: data.recommendedJobs.length,
                        separatorBuilder: (_, __) => SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          final job = data.recommendedJobs[index];
                          return UJobJobCard(
                            job: job,
                            onTap: () => context.push('/seeker/jobs/${job.id}'),
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
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final String greeting;
  final String name;
  final String initials;
  final SeekerDashboardData dashboard;
  final VoidCallback onNotificationsTap;

  const _DashboardHeader({
    required this.greeting,
    required this.name,
    required this.initials,
    required this.dashboard,
    required this.onNotificationsTap,
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
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 48.h),
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
                      _NotificationButton(onTap: onNotificationsTap),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      _StatCard(title: '${dashboard.applicationsCount}', subtitle: 'Applied', isSelected: false, onTap: () {}),
                      SizedBox(width: 12.w),
                      _StatCard(title: '47', subtitle: 'Matches', isSelected: false, onTap: () {}),
                      SizedBox(width: 12.w),
                      _StatCard(title: '12', subtitle: 'Saved', isSelected: false, onTap: () {}),
                    ],
                  ),
                  SizedBox(height: 24.h), // extra space for overlap
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
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surface : AppColors.surface.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isSelected ? Colors.transparent : AppColors.surface.withValues(alpha: 0.2),
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
                  color: isSelected ? AppColors.muted : AppColors.surface.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  const _SectionHeader({
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppText.heading2.copyWith(color: AppColors.text2)),
            if (subtitle != null) ...[
              SizedBox(height: 4.h),
              Row(
                children: [
                  Container(
                    width: 6.r,
                    height: 6.r,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(subtitle!, style: AppText.small.copyWith(color: AppColors.muted)),
                ],
              ),
            ],
          ],
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onActionTap,
            child: Text(
              actionLabel!,
              style: AppText.bodyBold.copyWith(color: AppColors.seekPrimary),
            ),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final dynamic icon;
  
  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 48.h, horizontal: 24.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.xl,
        border: Border.all(color: AppColors.borderLight),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(
            icon: icon,
            color: AppColors.muted2,
            size: 48.r,
          ),
          SizedBox(height: 16.h),
          Text(
            title,
            style: AppText.heading3.copyWith(color: AppColors.text2),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: AppText.body.copyWith(color: AppColors.muted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  final VoidCallback onTap;

  const _NotificationButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onTap,
          tooltip: 'Notifications',
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface.withValues(alpha: 0.12),
            fixedSize: Size(44.r, 44.r),
          ),
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedNotification01,
            color: AppColors.surface,
            size: 23,
          ),
        ),
        Positioned(
          right: -1.w,
          top: -3.h,
          child: Container(
            width: 20.r,
            height: 20.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.seekPrimary, width: 2),
            ),
            child: Text(
              '2',
              style: AppText.caption.copyWith(
                color: AppColors.surface,
                fontSize: 9.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
