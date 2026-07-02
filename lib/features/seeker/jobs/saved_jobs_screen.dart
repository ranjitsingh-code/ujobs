import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/application.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/l10n_extensions.dart';
import '../../../core/widgets/ujob_app_bar.dart';
import '../../../core/widgets/ujob_error.dart';
import '../../../core/widgets/ujob_job_card.dart';
import '../../../core/widgets/ujob_loading.dart';
import '../../../core/widgets/ujob_toast.dart';
import '../applications/seeker_application_provider.dart';

class SavedJobsScreen extends ConsumerWidget {
  const SavedJobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedAsync = ref.watch(seekerApplicationsProvider(null));

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: UJobAppBar(title: context.l10n.savedJobs),
      body: savedAsync.when(
        loading: () => const UJobLoading(),
        error: (err, stack) => UJobError(
          message: context.l10n.error,
          onRetry: () => ref.invalidate(seekerApplicationsProvider(null)),
        ),
        data: (applications) {
          final savedJobs = applications
              .where((a) => a.status == ApplicationStatus.saved)
              .toList();

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(seekerApplicationsProvider(null));
            },
            color: AppColors.seekPrimary,
            child: savedJobs.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: AppSpacing.pagePad,
                    children: [
                      _SavedJobsHeader(count: 0),
                      SizedBox(height: 100.h),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              context.l10n.noSavedJobsYet,
                              style: AppText.heading2,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              context.l10n.savedJobsEmptySubtitle,
                              textAlign: TextAlign.center,
                              style: AppText.body.copyWith(
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: AppSpacing.pagePad,
                    itemCount: savedJobs.length + 1,
                    separatorBuilder: (_, index) => index == 0
                        ? SizedBox(height: 16.h)
                        : const SizedBox.shrink(),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _SavedJobsHeader(count: savedJobs.length);
                      }
                      final item = savedJobs[index - 1];
                      return UJobJobCard(
                        job: item.job.copyWith(isSaved: true),
                        onTap: () => context.push(
                          '/seeker/jobs/${item.job.id}',
                          extra: {'source': 'saved'},
                        ),
                        onSaveTap: () {
                          ref
                              .read(seekerApplicationsProvider(null).notifier)
                              .toggleSave(item.job);
                          UJobToast.success(
                            context,
                            context.l10n.jobUnsavedTitle,
                            sub: context.l10n.savedJobRemovedSubtitle,
                          );
                        },
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}

class _SavedJobsHeader extends StatelessWidget {
  final int count;

  const _SavedJobsHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.xl2,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.savedJobs,
                  style: AppText.heading3.copyWith(color: AppColors.text),
                ),
                SizedBox(height: 4.h),
                Text(
                  context.l10n.savedJobsCount(count),
                  style: AppText.body.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: AppRadius.pill,
            ),
            child: Text(
              '$count',
              style: AppText.label.copyWith(color: AppColors.seekPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
