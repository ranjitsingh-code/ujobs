import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/l10n_extensions.dart';
import '../../../core/widgets/ujob_app_bar.dart';
import '../../../core/widgets/ujob_job_card.dart';
import '../../../core/widgets/ujob_loading.dart';
import '../../../core/widgets/ujob_error.dart';
import 'seeker_job_provider.dart';

class BrowseJobsScreen extends ConsumerStatefulWidget {
  const BrowseJobsScreen({super.key});

  @override
  ConsumerState<BrowseJobsScreen> createState() => _BrowseJobsScreenState();
}

class _BrowseJobsScreenState extends ConsumerState<BrowseJobsScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['All', 'Full-time', 'Remote', 'Freelance'];

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(seekerJobsProvider(JobFilter()));
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: UJobAppBar(
        title: l10n.browseJobs,
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            color: AppColors.surface,
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 52.h,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search jobs, skills...',
                            hintStyle: AppText.body.copyWith(color: AppColors.muted),
                            prefixIcon: HugeIcon(icon: HugeIcons.strokeRoundedSearch01, color: AppColors.muted, size: 24.r),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Container(
                      height: 52.h,
                      width: 52.h,
                      decoration: BoxDecoration(
                        color: AppColors.seekPrimary,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: IconButton(
                        icon: HugeIcon(icon: HugeIcons.strokeRoundedFilterHorizontal, color: AppColors.surface),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  height: 36.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (_, __) => SizedBox(width: 8.w),
                    itemBuilder: (context, index) {
                      final isSelected = _selectedFilterIndex == index;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedFilterIndex = index),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.seekPrimary : AppColors.background,
                            borderRadius: AppRadius.pill,
                          ),
                          child: Text(
                            _filters[index],
                            style: AppText.bodyBold.copyWith(
                              color: isSelected ? AppColors.surface : AppColors.text2,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: jobsAsync.when(
              loading: () => const UJobLoading(count: 3),
              error: (err, stack) => UJobError(
                message: l10n.error,
                onRetry: () => ref.refresh(seekerJobsProvider(JobFilter())),
              ),
              data: (jobs) {
                if (jobs.isEmpty) {
                  return Center(
                    child: Text(l10n.noMatchingJobsFound, style: AppText.body.copyWith(color: AppColors.muted)),
                  );
                }
                return ListView.separated(
                  padding: AppSpacing.pagePad,
                  itemCount: jobs.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    return UJobJobCard(
                      job: job,
                      onTap: () => context.push('/seeker/jobs/${job.id}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
