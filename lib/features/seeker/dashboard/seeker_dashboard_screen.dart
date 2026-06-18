import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/l10n_extensions.dart';
import '../../../core/widgets/ujob_app_bar.dart';
import '../../../core/widgets/ujob_loading.dart';
import '../../../core/widgets/ujob_error.dart';
import '../../../core/widgets/ujob_job_card.dart';
import 'seeker_dashboard_provider.dart';

// TODO: build from 3 API calls (GET /seeker/dashboard → 404, build manually):
// 1. GET /seeker/me           → profile_completed %
// 2. GET /seeker/applications → applications count
// 3. GET /seeker/matching-jobs?limit=5 → recommended jobs
class SeekerDashboardScreen extends ConsumerWidget {
  const SeekerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final dashboardAsync = ref.watch(seekerDashboardProvider);
    final l10n = context.l10n;

    final String appBarTitle = auth.when(
      data: (u) => u != null ? l10n.greetingName(u.firstName) : l10n.greetingFallback,
      loading: () => l10n.loading,
      error: (_, _) => l10n.appName,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: UJobAppBar(
        title: appBarTitle,
        showBack: false,
        rightWidget: IconButton(
          icon: const HugeIcon(icon: HugeIcons.strokeRoundedNotification01, color: AppColors.text, size: 24),
          onPressed: () => context.push('/seeker/notifications'),
        ),
      ),
      body: dashboardAsync.when(
        loading: () => const UJobLoading(),
        error: (e, st) => UJobError(
          message: 'Failed to load dashboard',
          onRetry: () => ref.refresh(seekerDashboardProvider),
        ),
        data: (data) => SingleChildScrollView(
          padding: AppSpacing.pagePad,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(height: 8.h),
            // Profile completion card
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.seekPrimary.withValues(alpha: 0.08),
                borderRadius: AppRadius.md,
                border: Border.all(color: AppColors.seekPrimary.withValues(alpha: 0.2)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l10n.completeYourProfile, style: AppText.bodyBold),
                SizedBox(height: 8.h),
                LinearProgressIndicator(
                  value: data.profileCompletion / 100,
                  backgroundColor: AppColors.grey100,
                  color: AppColors.seekPrimary,
                  borderRadius: AppRadius.pill,
                  minHeight: 6.h,
                ),
                SizedBox(height: 8.h),
                Text('${data.profileCompletion}% Complete',
                    style: AppText.small.copyWith(color: AppColors.grey600)),
              ]),
            ),
            SizedBox(height: 24.h),
            Text(l10n.quickActions, style: AppText.heading3),
            SizedBox(height: 12.h),
            Row(children: [
              _QuickAction(icon: HugeIcons.strokeRoundedSearch01, label: l10n.browseJobs, color: AppColors.seekPrimary, onTap: () => context.go('/seeker/jobs')),
              SizedBox(width: 12.w),
              _QuickAction(icon: HugeIcons.strokeRoundedTask01, label: '${data.applicationsCount} Applications', color: AppColors.info, onTap: () => context.go('/seeker/applied')),
              SizedBox(width: 12.w),
              _QuickAction(icon: HugeIcons.strokeRoundedUpload01, label: l10n.resume, color: AppColors.success, onTap: () => context.push('/seeker/resume')),
            ]),
            SizedBox(height: 24.h),
            Text(l10n.recommendedJobs, style: AppText.heading3),
            SizedBox(height: 12.h),
            if (data.recommendedJobs.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text('No matching jobs found')),
              )
            else
              ...data.recommendedJobs.map((j) => UJobJobCard(
                job: j,
                onTap: () => context.push('/seeker/jobs/${j.id}'),
              )),
          ]),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: AppRadius.md,
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: AppRadius.md,
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(children: [
          HugeIcon(icon: icon, color: color, size: 28.r),
          SizedBox(height: 8.h),
          Text(label, style: AppText.caption.copyWith(color: color, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
        ]),
      ),
    ),
  );
}
