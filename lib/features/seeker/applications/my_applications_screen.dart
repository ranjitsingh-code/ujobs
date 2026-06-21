import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/l10n_extensions.dart';
import '../../../core/widgets/ujob_app_bar.dart';
import '../../../core/widgets/ujob_loading.dart';
import '../../../core/widgets/ujob_error.dart';
import '../../../core/widgets/ujob_job_card.dart';
import 'seeker_application_provider.dart';

class MyApplicationsScreen extends ConsumerStatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  ConsumerState<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends ConsumerState<MyApplicationsScreen> with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    final appsAsync = ref.watch(seekerApplicationsProvider(null));
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: UJobAppBar(
        title: 'My Applications',
        showBack: false,
      ),
      body: appsAsync.when(
        loading: () => const UJobLoading(),
        error: (err, stack) => UJobError(
          message: l10n.error,
          onRetry: () => ref.refresh(seekerApplicationsProvider(null)),
        ),
        data: (applications) {
          if (applications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HugeIcon(icon: HugeIcons.strokeRoundedBriefcase01, color: AppColors.muted, size: 64.r),
                  SizedBox(height: 16.h),
                  Text('No Applications Yet', style: AppText.heading2),
                  SizedBox(height: 8.h),
                  Text('Start applying to jobs to see them here.', style: AppText.body.copyWith(color: AppColors.muted)),
                ],
              ),
            );
          }

          // Group applications by status for tabs (Pending, Interview, Rejected/Offered)
          // For now, just show all in a list with status chips

          return Column(
            children: [
              Container(
                color: AppColors.surface,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.seekPrimary,
                  unselectedLabelColor: AppColors.muted,
                  indicatorColor: AppColors.seekPrimary,
                  indicatorWeight: 3,
                  labelStyle: AppText.bodyBold,
                  unselectedLabelStyle: AppText.body,
                  tabs: const [
                    Tab(text: 'Active'),
                    Tab(text: 'Interview'),
                    Tab(text: 'Archived'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _ApplicationList(applications: applications, filter: 'Active'),
                    _ApplicationList(applications: applications, filter: 'Interview'),
                    _ApplicationList(applications: applications, filter: 'Archived'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ApplicationList extends StatelessWidget {
  final List<dynamic> applications;
  final String filter;

  const _ApplicationList({required this.applications, required this.filter});

  @override
  Widget build(BuildContext context) {
    // Fake filtering for visual completeness
    final filtered = applications; 

    if (filtered.isEmpty) {
      return Center(
        child: Text('No applications in this category.', style: AppText.body.copyWith(color: AppColors.muted)),
      );
    }

    return ListView.separated(
      padding: AppSpacing.pagePad,
      itemCount: filtered.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final app = filtered[index];
        return UJobJobCard(
          job: app.job,
          onTap: () => context.push('/seeker/jobs/${app.job.id}'),
          // add application status here ideally, or a custom wrapper
        );
      },
    );
  }
}
