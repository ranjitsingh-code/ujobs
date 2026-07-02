import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/l10n_extensions.dart';
import '../../../core/widgets/ujob_job_card.dart';
import '../../../core/widgets/ujob_boxed_empty_state.dart';
import '../../../core/widgets/ujob_text_field.dart';
import '../../../core/widgets/ujob_multi_chip_group.dart';
import '../../../core/widgets/ujob_button.dart';
import '../../../core/widgets/ujob_loading.dart';
import '../../../core/widgets/ujob_error.dart';
import '../../../core/widgets/ujob_pill_tab_bar.dart';
import '../../../core/widgets/ujob_dropdown.dart';
import '../../../core/providers/categories_provider.dart';
import '../../../core/widgets/ujob_toast.dart';
import '../applications/seeker_application_provider.dart';
import '../../../core/models/application.dart';
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

  Future<void> _refreshJobs() async {
    ref.invalidate(seekerMatchingJobsProvider);
    ref.invalidate(seekerJobsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(seekerJobsProvider);
    final matchingJobsAsync = ref.watch(seekerMatchingJobsProvider);
    final l10n = context.l10n;
    final tabs = [l10n.forYouTab, l10n.allJobs];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: DefaultTabController(
        length: 2,
        initialIndex: _tabIndex,
        child: NestedScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                primary: true,
                backgroundColor: AppColors.surface,
                surfaceTintColor: Colors.transparent,
                pinned: true,
                floating: false,
                elevation: 0,
                scrolledUnderElevation: 0,
                toolbarHeight: 0,
                automaticallyImplyLeading: false,
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
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: UJobTextField(
                            label: '',
                            hint: l10n.searchJobsSkills,
                            controller: _searchController,
                            prefix: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedSearch01,
                                color: AppColors.muted,
                                size: 20.r,
                              ),
                            ),
                            onChanged: (v) {
                              if (_tabIndex == 1) {
                                ref
                                    .read(activeJobFilterProvider.notifier)
                                    .state = ref
                                    .read(activeJobFilterProvider)
                                    .copyWith(search: v);
                              } else {
                                setState(() {}); // trigger local filter
                              }
                            },
                          ),
                        ),
                        if (_tabIndex == 1) ...[
                          SizedBox(width: 12.w),
                          Container(
                            width: 56.w,
                            decoration: BoxDecoration(
                              color: AppColors.seekPrimary,
                              borderRadius: AppRadius.md,
                            ),
                            child: InkWell(
                              borderRadius: AppRadius.md,
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  isScrollControlled: true,
                                  useSafeArea: true,
                                  builder: (context) => const _FilterSheet(),
                                );
                              },
                              child: Center(
                                child: HugeIcon(
                                  icon: HugeIcons.strokeRoundedFilterHorizontal,
                                  color: AppColors.surface,
                                  size: 24.r,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
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
                      tabs: tabs,
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
            onPageChanged: (v) {
              setState(() => _tabIndex = v);
              if (v == 1) {
                // Apply the search text to the active filter provider when switching to All Jobs
                ref.read(activeJobFilterProvider.notifier).state = ref
                    .read(activeJobFilterProvider)
                    .copyWith(search: _searchController.text);
              }
            },
            children: [
              _buildForYouTab(matchingJobsAsync, l10n),
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
        onRetry: () => ref.refresh(seekerMatchingJobsProvider),
      ),
      data: (jobs) {
        final query = _searchController.text.toLowerCase();
        final filteredJobs = jobs.where((job) {
          if (query.isEmpty) return true;
          return job.title.toLowerCase().contains(query) ||
              (job.company?.name.toLowerCase().contains(query) ?? false);
        }).toList();

        if (filteredJobs.isEmpty) {
          return RefreshIndicator(
            onRefresh: _refreshJobs,
            color: AppColors.seekPrimary,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              children: [
                SizedBox(height: 80.h),
                UJobBoxedEmptyState(
                  title: l10n.noMatchingJobsFound,
                  subtitle: l10n.adjustFiltersOrSearchTerms,
                  icon: HugeIcons.strokeRoundedSearchMinus,
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: _refreshJobs,
          color: AppColors.seekPrimary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
                child: Row(
                  children: [
                    Text(l10n.recommendedJobsTitle, style: AppText.heading3),
                    const Spacer(),
                    Text(
                      l10n.matchesCount(filteredJobs.length),
                      style: AppText.bodyMedium.copyWith(
                        color: AppColors.seekPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                  itemCount: filteredJobs.length,
                  separatorBuilder: (_, _) => const SizedBox.shrink(),
                  itemBuilder: (context, index) {
                    final job = filteredJobs[index];
                    final apps =
                        ref.watch(seekerApplicationsProvider(null)).value ?? [];
                    final isSaved = apps.any(
                      (a) =>
                          a.job.id == job.id &&
                          a.status == ApplicationStatus.saved,
                    );
                    return UJobJobCard(
                      job: job.copyWith(isSaved: isSaved),
                      onTap: () => context.push(
                        '/seeker/jobs/${job.id}',
                        extra: {'source': 'jobs'},
                      ),
                      onSaveTap: () {
                        ref
                            .read(seekerApplicationsProvider(null).notifier)
                            .toggleSave(job);
                        UJobToast.success(
                          context,
                          isSaved ? l10n.jobUnsavedTitle : l10n.jobSavedTitle,
                          sub: isSaved
                              ? l10n.savedJobRemovedSubtitle
                              : l10n.savedJobAddedSubtitle,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
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
                return RefreshIndicator(
                  onRefresh: _refreshJobs,
                  color: AppColors.seekPrimary,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 24.h,
                    ),
                    children: [
                      SizedBox(height: 80.h),
                      UJobBoxedEmptyState(
                        title: l10n.noMatchingJobsFound,
                        subtitle: l10n.adjustFiltersOrSearchTerms,
                        icon: HugeIcons.strokeRoundedSearchMinus,
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: _refreshJobs,
                color: AppColors.seekPrimary,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            l10n.positionsCount(jobs.length),
                            style: AppText.bodyBold,
                          ),
                          GestureDetector(
                            onTap: () async {
                              final val = await showModalBottomSheet<String>(
                                context: context,
                                backgroundColor: AppColors.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(24.r),
                                  ),
                                ),
                                builder: (ctx) => _SortSheet(
                                  currentValue: _sortBy,
                                  options:
                                      ref
                                          .read(jobFilterOptionsProvider)
                                          .valueOrNull
                                          ?.sortOptions
                                          .map((e) => e.value)
                                          .toList() ??
                                      _sortOptions,
                                  optionLabels: ref
                                      .read(jobFilterOptionsProvider)
                                      .valueOrNull
                                      ?.sortOptions,
                                ),
                              );
                              if (val != null && mounted) {
                                setState(() => _sortBy = val);
                                ref
                                    .read(activeJobFilterProvider.notifier)
                                    .state = ref
                                    .read(activeJobFilterProvider)
                                    .copyWith(sortBy: val);
                              }
                            },
                            child: Row(
                              children: [
                                Text(
                                  () {
                                    final sortOpts = ref
                                        .read(jobFilterOptionsProvider)
                                        .valueOrNull
                                        ?.sortOptions;
                                    if (sortOpts != null) {
                                      for (final opt in sortOpts) {
                                        if (opt.value == _sortBy) {
                                          return opt.label;
                                        }
                                      }
                                    }
                                    return _sortBy;
                                  }(),
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
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                        itemCount: jobs.length,
                        separatorBuilder: (_, _) => const SizedBox.shrink(),
                        itemBuilder: (context, index) {
                          final job = jobs[index];
                          final apps =
                              ref
                                  .watch(seekerApplicationsProvider(null))
                                  .value ??
                              [];
                          final isSaved = apps.any(
                            (a) =>
                                a.job.id == job.id &&
                                a.status == ApplicationStatus.saved,
                          );
                          return UJobJobCard(
                            job: job.copyWith(isSaved: isSaved),
                            onTap: () => context.push(
                              '/seeker/jobs/${job.id}',
                              extra: {'source': 'jobs'},
                            ),
                            onSaveTap: () {
                              ref
                                  .read(
                                    seekerApplicationsProvider(null).notifier,
                                  )
                                  .toggleSave(job);
                              UJobToast.success(
                                context,
                                isSaved
                                    ? l10n.jobUnsavedTitle
                                    : l10n.jobSavedTitle,
                                sub: isSaved
                                    ? l10n.savedJobRemovedSubtitle
                                    : l10n.savedJobAddedSubtitle,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
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
  String _datePosted = 'any_time';
  List<String> _employmentTypes = [];
  List<String> _workplaces = [];
  String _experienceLevel = 'any_level';
  String _minSalary = 'any_salary';
  String _category = 'all_categories';

  String _formatLabel(String value, {List<dynamic>? apiOptions}) {
    // If the API provided a label for this value, use it!
    if (apiOptions != null) {
      for (final opt in apiOptions) {
        if (opt.value == value) return opt.label;
      }
    }

    if (value.endsWith('_plus')) {
      final numStr = value.replaceAll('_plus', '');
      final amount = int.tryParse(numStr);
      if (amount != null) {
        if (amount >= 1000) return '\$${(amount / 1000).toStringAsFixed(0)}k+';
        return '\$$amount+';
      }
    }
    if (value == 'any_time') return 'Any time';
    if (value == 'any_level') return 'Any level';
    if (value == 'any_salary') return 'Any salary';
    if (value == 'all_categories') return 'All Categories';

    final str = value.replaceAll('_', ' ').replaceAll('-', ' ');
    if (str.isEmpty) return '';
    return str[0].toUpperCase() + str.substring(1).toLowerCase();
  }

  @override
  void initState() {
    super.initState();
    final filter = ref.read(activeJobFilterProvider);
    _keywordsCtrl.text = filter.search ?? '';
    _locationCtrl.text = filter.location ?? '';
    _companyCtrl.text = filter.company ?? '';
    _category = filter.category ?? 'all_categories';
    _datePosted = filter.datePosted ?? 'any_time';
    _experienceLevel = filter.experienceLevel ?? 'any_level';
    _minSalary = filter.minSalary ?? 'any_salary';
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
                    // Reset local state
                    setState(() {
                      _keywordsCtrl.clear();
                      _locationCtrl.clear();
                      _companyCtrl.clear();
                      _datePosted = 'any_time';
                      _employmentTypes = [];
                      _workplaces = [];
                      _experienceLevel = 'any_level';
                      _minSalary = 'any_salary';
                      _category = 'all_categories';
                    });

                    // Trigger the API reset
                    Navigator.pop(context);
                    ref.read(activeJobFilterProvider.notifier).state =
                        JobFilter();
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
            child: ref
                .watch(jobFilterOptionsProvider)
                .when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, st) =>
                      Center(child: Text('Failed to load filters: $e')),
                  data: (options) {
                    // Determine dropdown items, ensuring selected values remain valid
                    final datePostedItems = options.datePosted.isNotEmpty
                        ? [
                            'any_time',
                            ...options.datePosted.map((e) => e.value),
                          ]
                        : [
                            'any_time',
                            'last_24_hours',
                            'past_week',
                            'past_month',
                          ];
                    if (!datePostedItems.contains(_datePosted)) {
                      _datePosted = 'any_time';
                    }

                    final employmentTypeItems =
                        options.employmentTypes.isNotEmpty
                        ? options.employmentTypes.map((e) => e.value).toList()
                        : [
                            'full_time',
                            'part_time',
                            'contract',
                            'freelance',
                            'internship',
                            'temporary',
                          ];

                    final workplaceItems = options.workplaceTypes.isNotEmpty
                        ? options.workplaceTypes.map((e) => e.value).toList()
                        : ['on_site', 'remote', 'hybrid'];

                    final experienceLevelItems =
                        options.experienceLevels.isNotEmpty
                        ? [
                            'any_level',
                            ...options.experienceLevels.map((e) => e.value),
                          ]
                        : [
                            'any_level',
                            'entry_level',
                            'mid_level',
                            'senior',
                            'executive',
                          ];
                    if (!experienceLevelItems.contains(_experienceLevel)) {
                      _experienceLevel = 'any_level';
                    }

                    final minSalaryItems = options.salaryRanges.isNotEmpty
                        ? [
                            'any_salary',
                            ...options.salaryRanges.map((e) => e.value),
                          ]
                        : [
                            'any_salary',
                            '20000_plus',
                            '30000_plus',
                            '40000_plus',
                            '50000_plus',
                            '70000_plus',
                            '100000_plus',
                          ];
                    if (!minSalaryItems.contains(_minSalary)) {
                      _minSalary = 'any_salary';
                    }

                    final loadedCategories = ref
                        .watch(categoriesProvider)
                        .valueOrNull;
                    final categoryItems =
                        loadedCategories != null && loadedCategories.isNotEmpty
                        ? [
                            'all_categories',
                            ...loadedCategories.map((c) => c.name),
                          ]
                        : (options.categories.isNotEmpty
                              ? [
                                  'all_categories',
                                  ...options.categories.map((e) => e.value),
                                ]
                              : [
                                  'all_categories',
                                  'Technology',
                                  'Software Development',
                                  'Accounting & Auditing',
                                  'Healthcare',
                                  'Logistics & Supply Chain',
                                ]);
                    if (!categoryItems.contains(_category)) {
                      _category = 'all_categories';
                    }

                    return SingleChildScrollView(
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
                            items: datePostedItems,
                            labelBuilder: (v) =>
                                _formatLabel(v, apiOptions: options.datePosted),
                            onChanged: (v) => setState(() => _datePosted = v!),
                          ),
                          SizedBox(height: 24.h),

                          Text('Employment Type', style: AppText.bodyBold),
                          SizedBox(height: 12.h),
                          UJobMultiChipGroup<String>(
                            options: employmentTypeItems,
                            selectedValues: _employmentTypes,
                            labelBuilder: (v) => _formatLabel(
                              v,
                              apiOptions: options.employmentTypes,
                            ),
                            onChanged: (v) =>
                                setState(() => _employmentTypes = v),
                          ),
                          SizedBox(height: 24.h),

                          Text('Workplace', style: AppText.bodyBold),
                          SizedBox(height: 12.h),
                          UJobMultiChipGroup<String>(
                            options: workplaceItems,
                            selectedValues: _workplaces,
                            labelBuilder: (v) => _formatLabel(
                              v,
                              apiOptions: options.workplaceTypes,
                            ),
                            onChanged: (v) => setState(() => _workplaces = v),
                          ),
                          SizedBox(height: 24.h),

                          UJobDropdown(
                            label: 'Experience Level',
                            value: _experienceLevel,
                            items: experienceLevelItems,
                            labelBuilder: (v) => _formatLabel(
                              v,
                              apiOptions: options.experienceLevels,
                            ),
                            onChanged: (v) =>
                                setState(() => _experienceLevel = v!),
                          ),
                          SizedBox(height: 24.h),

                          UJobDropdown(
                            label: 'Minimum Salary',
                            value: _minSalary,
                            items: minSalaryItems,
                            labelBuilder: (v) => _formatLabel(
                              v,
                              apiOptions: options.salaryRanges,
                            ),
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
                            items: categoryItems,
                            labelBuilder: _formatLabel,
                            onChanged: (v) => setState(() => _category = v!),
                          ),
                          SizedBox(height: 40.h),
                        ],
                      ),
                    );
                  },
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
                ref.read(activeJobFilterProvider.notifier).state = JobFilter(
                  search: _keywordsCtrl.text.isEmpty
                      ? null
                      : _keywordsCtrl.text,
                  location: _locationCtrl.text.isEmpty
                      ? null
                      : _locationCtrl.text,
                  company: _companyCtrl.text.isEmpty ? null : _companyCtrl.text,
                  category: _category == 'all_categories' ? null : _category,
                  datePosted: _datePosted == 'any_time' ? null : _datePosted,
                  employmentTypes: _employmentTypes,
                  workplaces: _workplaces,
                  experienceLevel: _experienceLevel == 'any_level'
                      ? null
                      : _experienceLevel,
                  minSalary: _minSalary == 'any_salary' ? null : _minSalary,
                );
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
  final List<dynamic>? optionLabels;

  const _SortSheet({
    required this.currentValue,
    required this.options,
    this.optionLabels,
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
            String displayLabel = option;
            if (optionLabels != null) {
              for (final opt in optionLabels!) {
                if (opt.value == option) displayLabel = opt.label;
              }
            }
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                displayLabel,
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
                Navigator.pop(context, option);
              },
            );
          }),
        ],
      ),
    );
  }
}
