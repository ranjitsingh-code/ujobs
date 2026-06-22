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

class BrowseJobsScreen extends ConsumerStatefulWidget {
  const BrowseJobsScreen({super.key});

  @override
  ConsumerState<BrowseJobsScreen> createState() => _BrowseJobsScreenState();
}

class _BrowseJobsScreenState extends ConsumerState<BrowseJobsScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final PageController _pageCtrl;
  int _tabIndex = 0;
  String _sortBy = 'Most recent';
  final List<String> _sortOptions = [
    'Most recent',
    'Newest/latest',
    'Salary: High to low',
    'Salary: Low to high'
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
    final jobsAsync = ref.watch(seekerJobsProvider(JobFilter()));
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: UJobAppBar(
        title: l10n.browseJobs,
        showBack: false,
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: UJobPillTabBar(
              tabs: const ['For you', 'All jobs'],
              selectedIndex: _tabIndex,
              onTabSelected: (v) {
                setState(() => _tabIndex = v);
                _pageCtrl.animateToPage(v, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
              },
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              onPageChanged: (v) => setState(() => _tabIndex = v),
              children: [
                _buildForYouTab(jobsAsync, l10n),
                _buildAllJobsTab(jobsAsync, l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForYouTab(AsyncValue jobsAsync, dynamic l10n) {
    return jobsAsync.when(
      loading: () => const UJobLoading(count: 3),
      error: (err, stack) => UJobError(
        message: l10n.error,
        onRetry: () => ref.refresh(seekerJobsProvider(JobFilter())),
      ),
      data: (jobs) {
        if (jobs.isEmpty) {
          return Center(child: Text(l10n.noMatchingJobsFound, style: AppText.body.copyWith(color: AppColors.muted)));
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
    );
  }

  Widget _buildAllJobsTab(AsyncValue jobsAsync, dynamic l10n) {
    return Column(
      children: [
        // Search Header
        Container(
          color: AppColors.surface,
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
          child: Row(
            children: [
              Expanded(
                child: UJobTextField(
                  label: '',
                  hint: 'Search jobs, skills...',
                  controller: _searchController,
                  prefix: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: HugeIcon(icon: HugeIcons.strokeRoundedSearch01, color: AppColors.muted, size: 20.r),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                height: 52.h,
                width: 52.h,
                margin: EdgeInsets.only(top: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.seekPrimary,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: IconButton(
                  icon: HugeIcon(icon: HugeIcons.strokeRoundedFilterHorizontal, color: AppColors.surface, size: 24.r),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (context) => const _FilterSheet(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // Jobs List
        Expanded(
          child: jobsAsync.when(
            loading: () => const UJobLoading(count: 3),
            error: (err, stack) => UJobError(
              message: l10n.error,
              onRetry: () => ref.refresh(seekerJobsProvider(JobFilter())),
            ),
            data: (jobs) {
              if (jobs.isEmpty) {
                return Center(child: Text(l10n.noMatchingJobsFound, style: AppText.body.copyWith(color: AppColors.muted)));
              }
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${jobs.length} jobs found', style: AppText.bodyBold.copyWith(color: AppColors.muted2)),
                        Row(
                          children: [
                            Text('Sort by: ', style: AppText.bodySmall.copyWith(color: AppColors.muted)),
                            SizedBox(width: 4.w),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _sortBy,
                                icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowDown01, color: AppColors.muted, size: 16.r),
                                style: AppText.bodySemiBold.copyWith(color: AppColors.seekPrimaryDark),
                                dropdownColor: AppColors.surface,
                                items: _sortOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                onChanged: (v) => setState(() => _sortBy = v!),
                              ),
                            ),
                          ],
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

class _FilterSheet extends StatefulWidget {
  const _FilterSheet();

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  final _keywordsCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  
  String _datePosted = 'Any time';
  List<String> _employmentTypes = ['Full-time'];
  List<String> _workplaces = ['On-site'];
  String _experienceLevel = 'Any level';
  String _minSalary = 'Any salary';
  String _category = 'All Categories';

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filters', style: AppText.heading2),
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
                  child: Text('Reset', style: AppText.bodyBold.copyWith(color: AppColors.muted)),
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
                    items: const ['Any time', 'Last 24 hours', 'Last 3 days', 'Last 7 days', 'Last 14 days', 'Last 30 days'],
                    onChanged: (v) => setState(() => _datePosted = v!),
                  ),
                  SizedBox(height: 24.h),

                  Text('Employment Type', style: AppText.bodyBold),
                  SizedBox(height: 12.h),
                  UJobMultiChipGroup<String>(
                    options: const ['Full-time', 'Part-time', 'Contract', 'Internship', 'Temporary'],
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
                    items: const ['Any level', 'Fresher', '1-3 years', '3-5 years', '5+ years'],
                    onChanged: (v) => setState(() => _experienceLevel = v!),
                  ),
                  SizedBox(height: 24.h),

                  UJobDropdown(
                    label: 'Minimum Salary',
                    value: _minSalary,
                    items: const ['Any salary', '£20,000+', '£30,000+', '£40,000+', '£50,000+', '£70,000+', '£100,000+'],
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
                    items: const ['All Categories', 'Technology', 'Software Development', 'Accounting & Auditing', 'Healthcare', 'Logistics & Supply Chain'],
                    onChanged: (v) => setState(() => _category = v!),
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
          // Apply Button
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, MediaQuery.of(context).padding.bottom + 16.h),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.borderLight)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5)),
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
