import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/l10n_extensions.dart';
import '../../../core/widgets/ujob_loading.dart';
import '../../../core/widgets/ujob_error.dart';
import '../../../core/widgets/ujob_job_card.dart';
import '../../../core/widgets/ujob_pill_tab_bar.dart';
import '../../../core/models/application.dart';
import '../../../core/widgets/ujob_toast.dart';
import 'seeker_application_provider.dart';

class MyApplicationsScreen extends ConsumerStatefulWidget {
  final int initialIndex;
  const MyApplicationsScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<MyApplicationsScreen> createState() =>
      _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends ConsumerState<MyApplicationsScreen> {
  late final PageController _pageController;
  late int _selectedIndex;

  static const _filters = [
    'All',
    'Applied',
    'Saved',
    'Shortlisted',
    'Interview',
    'Offer',
    'Hired',
    'Rejected',
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectFilter(int index) {
    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appsAsync = ref.watch(seekerApplicationsProvider(null));
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: appsAsync.when(
          loading: () => const UJobLoading(),
          error: (err, stack) => UJobError(
            message: l10n.error,
            onRetry: () => ref.refresh(seekerApplicationsProvider(null)),
          ),
          data: (applications) {
            if (applications.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(seekerApplicationsProvider(null));
                },
                color: AppColors.seekPrimary,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: 200.h),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedBriefcase01,
                            color: AppColors.muted,
                            size: 64.r,
                          ),
                          SizedBox(height: 16.h),
                          Text('No Applications Yet', style: AppText.heading2),
                          SizedBox(height: 8.h),
                          Text(
                            'Start applying to jobs to see them here.',
                            style: AppText.body.copyWith(color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            final labels = _filters.map((f) {
              final count = f == 'All'
                  ? applications.map((a) => a.job.id).toSet().length
                  : applications.where((a) {
                      return a.status.name.toLowerCase() == f.toLowerCase() ||
                          (f == 'Interview' && a.status.name == 'interviewing') ||
                          (f == 'Offer' && a.status.name == 'offered');
                    }).length;
              return count > 0 ? '$f ($count)' : f;
            }).toList();

            return Column(
              children: [
                Container(
                  color: AppColors.surface,
                  padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
                  child: UJobPillTabBar(
                    tabs: labels,
                    selectedIndex: _selectedIndex,
                    onTabSelected: _selectFilter,
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (idx) {
                      if (_selectedIndex != idx) {
                        setState(() => _selectedIndex = idx);
                      }
                    },
                    itemCount: _filters.length,
                    itemBuilder: (context, index) {
                      return _ApplicationList(
                        applications: applications,
                        filter: _filters[index],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
    );
  }
}

class _ApplicationList extends ConsumerWidget {
  final List<Application> applications;
  final String filter;

  const _ApplicationList({required this.applications, required this.filter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var filtered = applications.where((a) {
      if (filter == 'All') return true;
      return a.status.name.toLowerCase() == filter.toLowerCase() ||
          (filter == 'Interview' && a.status.name == 'interviewing') ||
          (filter == 'Offer' && a.status.name == 'offered');
    }).toList();

    if (filter == 'All') {
      final uniqueMap = <int, Application>{};
      for (final app in filtered) {
        // Prioritize actual applications over 'saved' status
        if (app.status != ApplicationStatus.saved || !uniqueMap.containsKey(app.job.id)) {
          uniqueMap[app.job.id] = app;
        }
      }
      filtered = uniqueMap.values.toList();
    }

    if (filtered.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(seekerApplicationsProvider(null));
        },
        color: AppColors.seekPrimary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: 150.h),
            Center(
              child: Text(
                'No applications in this category.',
                style: AppText.body.copyWith(color: AppColors.muted),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(seekerApplicationsProvider(null));
      },
      color: AppColors.seekPrimary,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppSpacing.pagePad,
        itemCount: filtered.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final app = filtered[index];
        final apps = ref.watch(seekerApplicationsProvider(null)).value ?? [];
        final isSaved = apps.any(
          (a) => a.job.id == app.job.id && a.status == ApplicationStatus.saved,
        );
        return UJobJobCard(
          job: app.job.copyWith(
            isSaved: isSaved,
            applicationStatus: app.status != ApplicationStatus.saved ? app.status.name : '',
          ),
          onTap: () => context.push('/seeker/jobs/${app.job.id}'),
          onSaveTap: () {
            ref
                .read(seekerApplicationsProvider(null).notifier)
                .toggleSave(app.job);
            UJobToast.success(
              context,
              isSaved ? 'Job Unsaved' : 'Job Saved',
              sub: isSaved ? 'This job has been removed from your saved jobs.' : 'This job has been saved to your list.',
            );
          },
        );
      },
    ),
    );
  }
}
