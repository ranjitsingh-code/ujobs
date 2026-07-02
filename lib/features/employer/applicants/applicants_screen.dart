import 'package:go_router/go_router.dart';

import '../../../core/widgets/ujob_loading.dart';

import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ujob_applicant_card.dart';
import '../../../core/widgets/ujob_pill_tab_bar.dart';
import '../../../core/widgets/ujob_text_field.dart';
import '../../../core/widgets/ujob_dropdown_field.dart';
import 'employer_applicant_provider.dart';

class ApplicantsScreen extends ConsumerStatefulWidget {
  final int initialIndex;
  const ApplicantsScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<ApplicantsScreen> createState() => _ApplicantsScreenState();
}

class _ApplicantsScreenState extends ConsumerState<ApplicantsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late int _selectedIndex;
  String _searchQuery = '';
  String? _selectedJobFilter;

  final List<String> _tabs = [
    'All',
    'Applied',
    'Shortlisted',
    'Interview',
    'Offered',
    'Hired',
    'Rejected',
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
    _tabController.addListener(() {
      if (_tabController.index != _selectedIndex) {
        setState(() {
          _selectedIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncApplicants = ref.watch(employerApplicantsProvider);
    
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: asyncApplicants.when(
        loading: () => UJobLoading(count: 4),
        error: (err, stack) => Center(child: Text('Failed to load applicants', style: AppText.bodyMedium.copyWith(color: AppColors.error))),
        data: (allApplicants) {
          final availableJobs = allApplicants
              .where((a) => a.targetJobTitle != null && a.targetJobTitle!.isNotEmpty)
              .map((a) => a.targetJobTitle!)
              .toSet()
              .toList();

          return NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search and Filter Section
                  Container(
                    color: AppColors.surface,
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
                    child: Column(
                      children: [
                        UJobTextField(
                          label: '',
                          hint: context.l10n.searchApplicantsByName,
                          prefix: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedSearch01,
                              color: AppColors.muted,
                              size: 20.r,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value.toLowerCase();
                            });
                          },
                        ),
                        if (availableJobs.isNotEmpty) ...[
                          SizedBox(height: 12.h),
                          UJobDropdownField<String?>(
                            label: context.l10n.filterByJob,
                            hint: context.l10n.allJobs,
                            value: _selectedJobFilter,
                            options: [
                              ('All Jobs', null),
                              ...availableJobs.map((job) => (job, job)),
                            ],
                            onChanged: (val) {
                              setState(() {
                                _selectedJobFilter = val;
                              });
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SliverAppBar(
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: AppColors.surface,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: 0,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(60.h),
                child: Container(
                  color: AppColors.surface,
                  width: double.infinity,
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: ExcludeSemantics(
                    child: UJobPillTabBar(
                      tabs: _tabs,
                      selectedIndex: _selectedIndex,
                      onTabSelected: (index) {
                        _tabController.animateTo(index);
                      },
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: _tabs.map((tab) {
            // Filter applicants by tab, search query, and job title
            final filtered = allApplicants.where((a) {
              final matchesTab =
                  tab == 'All' || a.status.toLowerCase() == tab.toLowerCase();
              final matchesSearch =
                  _searchQuery.isEmpty ||
                  a.name.toLowerCase().contains(_searchQuery);
              final matchesJob =
                  _selectedJobFilter == null ||
                  a.targetJobTitle == _selectedJobFilter;
              return matchesTab && matchesSearch && matchesJob;
            }).toList();

            if (filtered.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedUserGroup,
                        color: AppColors.muted2,
                        size: 32.r,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text('No applicants found', style: AppText.titleSm),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: AppSpacing.pagePad,
              itemCount: filtered.length,
              separatorBuilder: (_, _) => SizedBox(height: 10.h),
              itemBuilder: (context, index) {
                final applicant = filtered[index];
                return UJobApplicantCard(
                  applicant: applicant,
                  onTap: () {
                    context.push('/employer/applicants/${applicant.id}');
                  },
                );
              },
            );
          }).toList(),
        ),
      );
        }
      ),
      ),
    );
  }
}
