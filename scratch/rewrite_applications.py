import re

with open('lib/features/seeker/applications/my_applications_screen.dart', 'r') as f:
    content = f.read()

# Replace _MyApplicationsScreenState
new_state = """class _MyApplicationsScreenState extends ConsumerState<MyApplicationsScreen> {
  late final PageController _pageController;
  int _selectedIndex = 0;

  static const _filters = [
    'All',
    'Applied',
    'Shortlisted',
    'Interview',
    'Offer',
    'Hired',
    'Rejected',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
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
      appBar: const UJobAppBar(title: 'My Applications', showBack: false),
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
            );
          }

          final labels = _filters.map((f) {
            final count = applications.where((a) {
              if (f == 'All') return true;
              return a.status.name.toLowerCase() == f.toLowerCase() ||
                  (f == 'Interview' && a.status.name == 'interviewing') ||
                  (f == 'Offer' && a.status.name == 'offered');
            }).length;
            return '$f ($count)';
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

class _ApplicationList extends StatelessWidget {
  final List<dynamic> applications;
  final String filter;

  const _ApplicationList({required this.applications, required this.filter});

  @override
  Widget build(BuildContext context) {
    final filtered = applications.where((a) {
      if (filter == 'All') return true;
      return a.status.name.toLowerCase() == filter.toLowerCase() ||
          (filter == 'Interview' && a.status.name == 'interviewing') ||
          (filter == 'Offer' && a.status.name == 'offered');
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'No applications in this category.',
          style: AppText.body.copyWith(color: AppColors.muted),
        ),
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
"""

start_idx = content.find("class _MyApplicationsScreenState extends ConsumerState<MyApplicationsScreen>")
content = content[:start_idx] + new_state

# Also add import for UJobPillTabBar if missing
if 'ujob_pill_tab_bar.dart' not in content:
    content = content.replace("import '../../../core/widgets/ujob_job_card.dart';", "import '../../../core/widgets/ujob_job_card.dart';\nimport '../../../core/widgets/ujob_pill_tab_bar.dart';")

with open('lib/features/seeker/applications/my_applications_screen.dart', 'w') as f:
    f.write(content)

