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

// TODO: build from 3 API calls (GET /seeker/dashboard → 404, build manually):
// 1. GET /seeker/me           → profile_completed %
// 2. GET /seeker/applications → applications count
// 3. GET /seeker/matching-jobs?limit=5 → recommended jobs
class SeekerDashboardScreen extends ConsumerWidget {
  const SeekerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: auth.when(
          data: (u) => Text(
            u != null ? l10n.greetingName(u.firstName) : l10n.greetingFallback,
            style: AppText.bodyBold.copyWith(color: AppColors.white),
          ),
          loading: () => Text(l10n.loading, style: const TextStyle(color: AppColors.white)),
          error: (_, _) => Text(l10n.appName, style: const TextStyle(color: AppColors.white)),
        ),
        actions: [
          IconButton(
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedNotification01, color: AppColors.white, size: 24),
            onPressed: () => context.push('/seeker/notifications'),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                value: 0.0, // TODO: from GET /seeker/me → profile_completed
                backgroundColor: AppColors.grey100,
                color: AppColors.seekPrimary,
                borderRadius: AppRadius.pill,
                minHeight: 6.h,
              ),
              SizedBox(height: 8.h),
              Text(l10n.profileCompletionHint,
                  style: AppText.small.copyWith(color: AppColors.grey600)),
            ]),
          ),
          SizedBox(height: 24.h),
          Text(l10n.quickActions, style: AppText.heading3),
          SizedBox(height: 12.h),
          Row(children: [
            _QuickAction(icon: HugeIcons.strokeRoundedSearch01, label: l10n.browseJobs, color: AppColors.seekPrimary, onTap: () => context.go('/seeker/jobs')),
            SizedBox(width: 12.w),
            _QuickAction(icon: HugeIcons.strokeRoundedTask01, label: l10n.myApplications, color: AppColors.info, onTap: () => context.go('/seeker/applied')),
            SizedBox(width: 12.w),
            _QuickAction(icon: HugeIcons.strokeRoundedUpload01, label: l10n.resume, color: AppColors.success, onTap: () => context.push('/seeker/resume')),
          ]),
          SizedBox(height: 24.h),
          Text(l10n.recommendedJobs, style: AppText.heading3),
          SizedBox(height: 12.h),
          // TODO: replace with actual job cards from GET /seeker/matching-jobs?limit=5
          const UJobLoading(count: 3),
        ]),
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
