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
import '../../../core/widgets/ujob_text_field.dart';
import '../../../core/widgets/ujob_multi_chip_group.dart';
import '../../../core/widgets/ujob_button.dart';
import '../../../core/widgets/ujob_loading.dart';
import '../../../core/widgets/ujob_error.dart';
import '../../../core/widgets/ujob_pill_tab_bar.dart';
import '../../../core/widgets/ujob_dropdown.dart';
import 'seeker_job_provider.dart';

class FindJobsScreen extends ConsumerStatefulWidget {
  const FindJobsScreen({super.key});

  @override
  ConsumerState<FindJobsScreen> createState() => _FindJobsScreenState();
}

class _FindJobsScreenState extends ConsumerState<FindJobsScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final PageController _pageCtrl;
  int _tabIndex = 0;
  String _sortBy = 'Most relevant';
  final List<String> _sortOptions = [
    'Most relevant',
    'Newest/latest',
    'Salary: High to low',
    'Salary: Low to high',
  ];

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(seekerJobsProvider);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: DefaultTabController(
        length: 2,
        initialIndex: _tabIndex,
        child: NestedScrollView(
          physics: const BouncingScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                backgroundColor: AppColors.surface,
                surfaceTintColor: Colors.transparent,
                pinned: true,
                floating: false,
                elevation: 0,
                scrolledUnderElevation: 0,
                centerTitle: true,
                title: Text(
                  l10n.findJobs,
                  style: AppText.bodyBold.copyWith(
                    color: AppColors.text,
                    fontSize: 18.sp,
                  ),
                ),
              ),
              SliverAppBar(
                primary: false,
                backgroundColor: AppColors.surface,
                surfaceTintColor: Colors.transparent,
                pinned: false,
                floating: true,
                snap: true,
                elevation: 0,
                scrolledUnderElevation: 0,
                toolbarHeight: 80.h,
                titleSpacing: 0,
                title: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: UJobTextField(
                          label: '',
                          hint: 'Search jobs, skills...',
                          controller: _searchController,
                          prefix: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedSearch01,
                              color: AppColors.muted,
                              size: 20.r,
                            ),
                          ),
                          onChanged: (v) =>
                              ref
                                  .read(activeJobFilterProvider.notifier)
                                  .state = ref
                                  .read(activeJobFilterProvider)
                                  .copyWith(search: v),
                        ),
                      ),
                      if (_tabIndex == 1) ...[
                        SizedBox(width: 12.w),
                        Container(
                          height: 56.h,
                          width: 56.w,
                          decoration: BoxDecoration(
                            color: AppColors.seekPrimary,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: IconButton(
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedFilterHorizontal,
                              color: AppColors.surface,
                              size: 24.r,
                            ),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                                useSafeArea: true,
                                builder: (context) => const _FilterSheet(),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SliverAppBar(
                primary: false,
                backgroundColor: AppColors.surface,
                surfaceTintColor: Colors.transparent,
                pinned: true,
                floating: false,
                elevation: innerBoxIsScrolled ? 1 : 0,
                scrolledUnderElevation: innerBoxIsScrolled ? 1 : 0,
                forceElevated: innerBoxIsScrolled,
                shadowColor: AppColors.borderLight,
                toolbarHeight: 0, // No title
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(68.h),
                  child: Container(
                    color: AppColors.surface,
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
                    child: UJobPillTabBar(
                      tabs: const ['For You', 'All Jobs'],
                      selectedIndex: _tabIndex,
                      isExpanded: true,
                      onTabSelected: (index) {
                        _pageCtrl.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ];
          },
          body: PageView(
            controller: _pageCtrl,
            onPageChanged: (v) => setState(() => _tabIndex = v),
            children: [
              _buildForYouTab(jobsAsync, l10n),
              _buildAllJobsTab(jobsAsync, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForYouTab(AsyncValue jobsAsync, dynamic l10n) {
    return jobsAsync.when(
      loading: () => const UJobLoading(count: 3),
      error: (err, stack) => UJobError(
        message: l10n.error,
        onRetry: () => ref.refresh(seekerJobsProvider),
      ),
      data: (jobs) {
        if (jobs.isEmpty) {
          return Center(
            child: Text(
              l10n.noMatchingJobsFound,
              style: AppText.body.copyWith(color: AppColors.muted),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
              child: Row(
                children: [
                  Text('Recommended', style: AppText.heading3),
                  const Spacer(),
                  Text(
                    '${jobs.length} matches',
                    style: AppText.bodyMedium.copyWith(
                      color: AppColors.seekPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                itemCount: jobs.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final job = jobs[index];
                  return UJobJobCard(
                    job: job,
                    onTap: () => context.push('/seeker/jobs/${job.id}'),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAllJobsTab(AsyncValue jobsAsync, dynamic l10n) {
    return Column(
      children: [
        // Jobs List
        Expanded(
          child: jobsAsync.when(
            loading: () => const UJobLoading(count: 3),
            error: (err, stack) => UJobError(
              message: l10n.error,
              onRetry: () => ref.refresh(seekerJobsProvider),
            ),
            data: (jobs) {
              if (jobs.isEmpty) {
                return Center(
                  child: Text(
                    l10n.noMatchingJobsFound,
                    style: AppText.body.copyWith(color: AppColors.muted),
                  ),
                );
              }
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${jobs.length} positions',
                          style: AppText.bodyBold,
                        ),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: AppColors.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24.r),
                                ),
                              ),
                              builder: (ctx) => _SortSheet(
                                currentValue: _sortBy,
                                options: _sortOptions,
                                onSelected: (val) {
                                  setState(() => _sortBy = val);
                                },
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Text(
                                _sortBy,
                                style: AppText.bodyMedium.copyWith(
                                  color: AppColors.seekPrimaryDark,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedArrowDown01,
                                color: AppColors.seekPrimaryDark,
                                size: 18.r,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                      itemCount: jobs.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final job = jobs[index];
                        return UJobJobCard(
                          job: job,
                          onTap: () => context.push('/seeker/jobs/${job.id}'),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FilterSheet extends ConsumerStatefulWidget {
  const _FilterSheet();

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  final _keywordsCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  String _datePosted = 'Any time';
  List<String> _employmentTypes = [];
  List<String> _workplaces = [];
  String _experienceLevel = 'Any level';
  String _minSalary = 'Any salary';
  String _category = 'All Categories';

  @override
  void initState() {
    super.initState();
    final filter = ref.read(activeJobFilterProvider);
    _keywordsCtrl.text = filter.search ?? '';
    _category = filter.category ?? 'All Categories';
    _datePosted = filter.datePosted ?? 'Any time';
    _experienceLevel = filter.experienceLevel ?? 'Any level';
    _minSalary = filter.minSalary ?? 'Any salary';
    _employmentTypes = List.from(filter.employmentTypes);
    _workplaces = List.from(filter.workplaces);
  }

  @override
  void dispose() {
    _keywordsCtrl.dispose();
    _locationCtrl.dispose();
    _companyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.borderLight)),
            ),
            child: Row(
              children: [
                Text('Filters', style: AppText.heading2),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Reset
                    setState(() {
                      _keywordsCtrl.clear();
                      _locationCtrl.clear();
                      _companyCtrl.clear();
                      _datePosted = 'Any time';
                      _employmentTypes = [];
                      _workplaces = [];
                      _experienceLevel = 'Any level';
                      _minSalary = 'Any salary';
                      _category = 'All Categories';
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.borderLight.withValues(
                      alpha: 0.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Reset',
                    style: AppText.bodyBold.copyWith(
                      color: AppColors.text,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedCancel01,
                    color: AppColors.text,
                    size: 24.r,
                  ),
                ),
              ],
            ),
          ),
          // Scrollable Body
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UJobTextField(
                    label: 'Keywords',
                    hint: 'Job title, skills, company...',
                    controller: _keywordsCtrl,
                  ),
                  SizedBox(height: 16.h),
                  UJobTextField(
                    label: 'Location',
                    hint: 'City or region...',
                    controller: _locationCtrl,
                  ),
                  SizedBox(height: 24.h),

                  UJobDropdown(
                    label: 'Date Posted',
                    value: _datePosted,
                    items: const [
                      'Any time',
                      'Last 24 hours',
                      'Last 3 days',
                      'Last 7 days',
                      'Last 14 days',
                      'Last 30 days',
                    ],
                    onChanged: (v) => setState(() => _datePosted = v!),
                  ),
                  SizedBox(height: 24.h),

                  Text('Employment Type', style: AppText.bodyBold),
                  SizedBox(height: 12.h),
                  UJobMultiChipGroup<String>(
                    options: const [
                      'Full-time',
                      'Part-time',
                      'Contract',
                      'Internship',
                      'Temporary',
                    ],
                    selectedValues: _employmentTypes,
                    labelBuilder: (v) => v,
                    onChanged: (v) => setState(() => _employmentTypes = v),
                  ),
                  SizedBox(height: 24.h),

                  Text('Workplace', style: AppText.bodyBold),
                  SizedBox(height: 12.h),
                  UJobMultiChipGroup<String>(
                    options: const ['On-site', 'Remote', 'Hybrid'],
                    selectedValues: _workplaces,
                    labelBuilder: (v) => v,
                    onChanged: (v) => setState(() => _workplaces = v),
                  ),
                  SizedBox(height: 24.h),

                  UJobDropdown(
                    label: 'Experience Level',
                    value: _experienceLevel,
                    items: const [
                      'Any level',
                      'Fresher',
                      '1-3 years',
                      '3-5 years',
                      '5+ years',
                    ],
                    onChanged: (v) => setState(() => _experienceLevel = v!),
                  ),
                  SizedBox(height: 24.h),

                  UJobDropdown(
                    label: 'Minimum Salary',
                    value: _minSalary,
                    items: const [
                      'Any salary',
                      '£20,000+',
                      '£30,000+',
                      '£40,000+',
                      '£50,000+',
                      '£70,000+',
                      '£100,000+',
                    ],
                    onChanged: (v) => setState(() => _minSalary = v!),
                  ),
                  SizedBox(height: 24.h),

                  UJobTextField(
                    label: 'Company',
                    hint: 'Company name...',
                    controller: _companyCtrl,
                  ),
                  SizedBox(height: 16.h),

                  UJobDropdown(
                    label: 'Category',
                    value: _category,
                    items: const [
                      'All Categories',
                      'Technology',
                      'Software Development',
                      'Accounting & Auditing',
                      'Healthcare',
                      'Logistics & Supply Chain',
                    ],
                    onChanged: (v) => setState(() => _category = v!),
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
          // Apply Button
          Container(
            padding: EdgeInsets.fromLTRB(
              20.w,
              16.h,
              20.w,
              MediaQuery.of(context).padding.bottom + 16.h,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.borderLight)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: UJobButton(
              label: 'Apply Filters',
              color: AppColors.seekPrimary,
              onTap: () {
                Navigator.pop(context);
                // Apply filter logic
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SortSheet extends ConsumerWidget {
  final String currentValue;
  final List<String> options;
  final ValueChanged<String> onSelected;

  const _SortSheet({
    required this.currentValue,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20.w,
        24.h,
        20.w,
        MediaQuery.of(context).padding.bottom + 24.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sort By', style: AppText.heading3),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedCancel01,
                  color: AppColors.text,
                  size: 24.r,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...options.map((option) {
            final isSelected = option == currentValue;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                option,
                style: AppText.body.copyWith(
                  color: isSelected ? AppColors.seekPrimary : AppColors.text,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              trailing: isSelected
                  ? HugeIcon(
                      icon: HugeIcons.strokeRoundedTick02,
                      color: AppColors.seekPrimary,
                      size: 20.r,
                    )
                  : null,
              onTap: () {
                onSelected(option);
                Navigator.pop(context);
              },
            );
          }),
        ],
      ),
    );
  }
}

class _UJobTabsDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _UJobTabsDelegate({required this.child});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  double get maxExtent => 56.0 + 16.0; // UJobPillTabBar height approx + padding

  @override
  double get minExtent => 56.0 + 16.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
