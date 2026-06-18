import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/l10n_extensions.dart';
import '../../../core/widgets/ujob_empty.dart';
import '../../../core/widgets/ujob_error.dart';
import '../../../core/widgets/ujob_loading.dart';
import '../../../core/widgets/ujob_job_card.dart';
import 'employer_job_provider.dart';

class MyJobsScreen extends ConsumerWidget {
  const MyJobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => DefaultTabController(
    length: 5,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('My Jobs'),
        bottom: TabBar(
          isScrollable: true,
          indicatorColor: AppColors.empPrimary,
          labelColor: AppColors.empPrimary,
          unselectedLabelColor: AppColors.muted2,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Active'),
            Tab(text: 'Pending'),
            Tab(text: 'Draft'),
            Tab(text: 'Closed'),
          ],
        ),
      ),
      body: const TabBarView(
        children: [
          _JobTabList(status: null),
          _JobTabList(status: 'active'),
          _JobTabList(status: 'pending'),
          _JobTabList(status: 'draft'),
          _JobTabList(status: 'closed'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/employer/post-job'),
        backgroundColor: AppColors.empPrimary,
        icon: HugeIcon(icon: HugeIcons.strokeRoundedPlusSign, color: AppColors.white, size: 24.r),
        label: Text(context.l10n.postJob, style: AppText.button.copyWith(color: AppColors.white)),
      ),
    ),
  );
}

class _JobTabList extends ConsumerWidget {
  final String? status;
  const _JobTabList({this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(employerJobsProvider(status));

    return jobsAsync.when(
      loading: () => const UJobLoading(count: 3),
      error: (err, stack) => UJobError(
        message: 'Failed to load jobs',
        onRetry: () => ref.refresh(employerJobsProvider(status)),
      ),
      data: (jobs) {
        if (jobs.isEmpty) {
          return UJobEmpty(
            title: 'No ${status ?? ''} jobs found',
            subtitle: 'Try posting a new job or changing the filter',
            icon: HugeIcons.strokeRoundedJobSearch,
          );
        }

        return ListView.builder(
          padding: AppSpacing.pagePad,
          itemCount: jobs.length,
          itemBuilder: (context, index) => UJobJobCard(
            job: jobs[index],
            onTap: () => context.push('/employer/jobs/${jobs[index].id}'),
          ),
        );
      },
    );
  }
}
