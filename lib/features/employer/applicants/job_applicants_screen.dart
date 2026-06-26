import 'package:go_router/go_router.dart';

import "../../../core/widgets/ujob_loading.dart";
import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/models/job.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ujob_app_bar.dart';
import '../../../core/widgets/ujob_pill_tab_bar.dart';
import '../../../core/widgets/ujob_applicant_card.dart';
import '../../../core/widgets/ujob_text_field.dart';
import 'employer_applicant_provider.dart';
import 'applicant_detail_screen.dart';

class JobApplicantsScreen extends ConsumerStatefulWidget {
  final Job job;

  const JobApplicantsScreen({required this.job, super.key});

  @override
  ConsumerState<JobApplicantsScreen> createState() =>
      _JobApplicantsScreenState();
}

class _JobApplicantsScreenState extends ConsumerState<JobApplicantsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  String _searchQuery = '';

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
    _tabController = TabController(length: _tabs.length, vsync: this);
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
    final applicantsAsync = ref.watch(jobApplicantsProvider(widget.job.id));

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const UJobAppBar(title: 'View Applicants'),
      body: applicantsAsync.when(
        loading: () => const Center(child: UJobSpinner()),
        error: (error, _) => Center(child: Text('Error loading applicants')),
        data: (fetchedApplicants) {
          final allApplicants = fetchedApplicants.map((a) => a.copyWith(targetJobTitle: widget.job.title)).toList();
          return NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
                    color: AppColors.surface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.job.title, style: AppText.heading2),
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Text(
                              '${allApplicants.length} applicants',
                              style: AppText.body.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Search Field
                  Container(
                    color: AppColors.surface,
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
                    child: UJobTextField(
                      label: '',
                      hint: context.l10n.searchApplicants,
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
            // Filter applicants by tab and search query
            final filtered = allApplicants.where((a) {
              final matchesTab =
                  tab == 'All' || a.status.toLowerCase() == tab.toLowerCase();
              final matchesSearch =
                  _searchQuery.isEmpty ||
                  a.name.toLowerCase().contains(_searchQuery);
              return matchesTab && matchesSearch;
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
                    Text('No applicants yet', style: AppText.titleSm),
                    SizedBox(height: 8.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: Text(
                        'Applications will appear here once candidates apply',
                        textAlign: TextAlign.center,
                        style: AppText.small.copyWith(color: AppColors.muted),
                      ),
                    ),
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
      },
      ),
    );
  }
}
