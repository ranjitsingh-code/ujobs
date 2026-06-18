import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ujob_empty.dart';
import '../../../core/widgets/ujob_error.dart';
import '../../../core/widgets/ujob_loading.dart';
import '../../../core/widgets/ujob_job_card.dart';
import '../../../core/widgets/ujob_app_bar.dart';
import 'seeker_application_provider.dart';

class MyApplicationsScreen extends ConsumerWidget {
  const MyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => DefaultTabController(
    length: 5,
    child: Scaffold(
      appBar: UJobAppBar(
        title: 'My Applications',
        showBack: false,
        bottom: TabBar(
          isScrollable: true,
          indicatorColor: AppColors.seekPrimary,
          labelColor: AppColors.seekPrimary,
          unselectedLabelColor: AppColors.muted2,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Applied'),
            Tab(text: 'Reviewing'),
            Tab(text: 'Shortlisted'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: const TabBarView(
        children: [
          _ApplicationTabList(status: null),
          _ApplicationTabList(status: 'applied'),
          _ApplicationTabList(status: 'reviewing'),
          _ApplicationTabList(status: 'shortlisting'),
          _ApplicationTabList(status: 'rejected'),
        ],
      ),
    ),
  );
}

class _ApplicationTabList extends ConsumerWidget {
  final String? status;
  const _ApplicationTabList({this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsAsync = ref.watch(seekerApplicationsProvider(status));

    return appsAsync.when(
      loading: () => const UJobLoading(count: 3),
      error: (err, stack) => UJobError(
        message: 'Failed to load applications',
        onRetry: () => ref.refresh(seekerApplicationsProvider(status)),
      ),
      data: (apps) {
        if (apps.isEmpty) {
          return UJobEmpty(
            title: 'No ${status ?? ''} applications',
            subtitle: 'Start applying for jobs to see them here',
            icon: HugeIcons.strokeRoundedTask01,
          );
        }

        return ListView.builder(
          padding: AppSpacing.pagePad,
          itemCount: apps.length,
          itemBuilder: (context, index) => UJobJobCard(
            job: apps[index].job,
            onTap: () => context.push('/seeker/jobs/${apps[index].job.id}'),
          ),
        );
      },
    );
  }
}
