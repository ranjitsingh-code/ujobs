import "../../../core/widgets/ujob_toast.dart";
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/ujob_verification_banners.dart';
import '../../../core/widgets/ujob_profile_setup_prompt.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/l10n_extensions.dart';
import '../../../core/models/job.dart';
import '../../../core/widgets/ujob_button.dart';
import '../../../core/widgets/ujob_employer_job_actions_sheet.dart';
import '../../../core/widgets/ujob_employer_job_card.dart';
import '../../../core/utils/job_action_helpers.dart';
import '../../../core/widgets/ujob_empty.dart';
import '../../../core/widgets/ujob_error.dart';
import '../../../core/widgets/ujob_loading.dart';
import '../../../core/widgets/ujob_alert_dialog.dart';
import '../../../core/widgets/ujob_pill_tab_bar.dart';
import '../../../core/widgets/ujob_text_field.dart';
import 'package:dio/dio.dart';
import '../../../core/utils/api_error_parser.dart';
import 'employer_job_provider.dart';
import '../dashboard/employer_dashboard_provider.dart';

class MyJobsScreen extends ConsumerStatefulWidget {
  final int initialIndex;
  const MyJobsScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends ConsumerState<MyJobsScreen> {
  static const _statuses = <String?>[
    null,
    'active',
    'pending',
    'draft',
    'paused',
    'closed',
    'rejected',
  ];

  late final PageController _pageController;
  late final TextEditingController _searchCtrl;
  late int _selectedIndex;
  bool _isManaging = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _searchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _selectFilter(int index) {
    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _onPageChanged(int index) {
    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(employerDashboardProvider);
    final dashboard = dashboardAsync.valueOrNull;
    final canPostJob = dashboard?.canPostJob ?? false;
    final isVerified = dashboard?.isVerified ?? false;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _JobsHeader(
              selectedIndex: _selectedIndex,
              onSelected: _selectFilter,
              isManaging: _isManaging,
              onManageTap: () => setState(() => _isManaging = !_isManaging),
              searchCtrl: _searchCtrl,
              onSearchChanged: (v) => setState(() => _query = v),
            ),
            if (dashboard != null) ...[
              if (!dashboard.isCompanyProfileComplete)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  child: UJobProfileSetupPrompt(
                    title: context.l10n.employerProfileNotCompletedTitle,
                    subtitle: context.l10n.employerProfileNotCompletedSubtitle,
                    icon: HugeIcons.strokeRoundedAlert02,
                    onSetup: () => context.push('/employer/profile'),
                  ),
                )
              else if (!dashboard.isAccountActive)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  child: UJobAccountStatusBanner(status: dashboard.userStatus),
                )
              else if (!dashboard.isVerified)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  child: UJobVerificationPendingBanner(
                    title: context.l10n.employerAccountUnderReviewTitle,
                    message: context.l10n.employerAccountUnderReviewSubtitle,
                  ),
                ),
            ],
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: _statuses
                    .map(
                      (status) => _JobList(
                        status: status,
                        isManaging: _isManaging,
                        query: _query,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _CompactPostJobButton(
        isProfileComplete: canPostJob,
        onTap: () {
          if (dashboard != null && !dashboard.isCompanyProfileComplete) {
            UJobToast.error(
              context,
              context.l10n.employerProfileNotCompletedTitle,
              sub: context.l10n.employerProfileNotCompletedSubtitle,
            );
            return;
          }
          if (dashboard != null && !dashboard.isAccountActive) {
            UJobToast.error(
              context,
              'Account Not Active',
              sub: 'Your account status is "${dashboard.userStatus}". Please contact support.',
            );
            return;
          }
          if (!isVerified) {
            UJobToast.error(
              context,
              context.l10n.employerAccountUnderReviewTitle,
              sub: context.l10n.employerAccountUnderReviewSubtitle,
            );
            return;
          }
          context.push('/employer/post-job');
        },
      ),
    );
  }
}

class _JobsHeader extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool isManaging;
  final VoidCallback onManageTap;
  final TextEditingController searchCtrl;
  final ValueChanged<String> onSearchChanged;

  const _JobsHeader({
    required this.selectedIndex,
    required this.onSelected,
    required this.isManaging,
    required this.onManageTap,
    required this.searchCtrl,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final labels = <String>[
      context.l10n.allTab,
      context.l10n.activeTab,
      context.l10n.pendingTab,
      context.l10n.draftTab,
      context.l10n.pausedTab,
      context.l10n.closedTab,
      context.l10n.rejectedTab,
    ];

    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 16.h),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.myJobs,
                  style: AppText.heading1.copyWith(
                    color: AppColors.text2,
                    letterSpacing: 0,
                  ),
                ),
              ),
              UJobTextButton(
                label: isManaging ? context.l10n.done : context.l10n.manageJob,
                color: isManaging ? AppColors.success : AppColors.primary,
                style: AppText.bodyBold.copyWith(
                  color: isManaging ? AppColors.success : AppColors.primary,
                ),
                onTap: onManageTap,
              ),
            ],
          ),
          SizedBox(height: 14.h),
          UJobTextField(
            hint: context.l10n.searchJobs,
            controller: searchCtrl,
            onChanged: onSearchChanged,
            prefix: Padding(
              padding: EdgeInsets.only(left: 12.w, right: 8.w),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedSearch01,
                color: AppColors.muted,
                size: 20.r,
              ),
            ),
          ),
          SizedBox(height: 14.h),
          UJobPillTabBar(
            tabs: labels,
            selectedIndex: selectedIndex,
            onTabSelected: onSelected,
          ),
        ],
      ),
    );
  }
}

class _CompactPostJobButton extends StatelessWidget {
  final bool isProfileComplete;
  final VoidCallback onTap;

  const _CompactPostJobButton({
    required this.isProfileComplete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: isProfileComplete ? 1.0 : 0.5,
    child: SizedBox(
      width: 162.w,
      child: UJobButton(
        label: context.l10n.postJob,
        height: 48,
        gradient: AppColors.authGradient,
        onTap: onTap,
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedPlusSign,
          color: AppColors.surface,
          size: 19.r,
        ),
      ),
    ),
  );
}

class _JobList extends ConsumerWidget {
  final String? status;
  final bool isManaging;
  final String query;

  const _JobList({
    required this.status,
    required this.isManaging,
    required this.query,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(employerJobsProvider(status));

    return jobsAsync.when(
      loading: () => const UJobLoading(count: 3),
      error: (err, stack) => UJobError(
        message: context.l10n.failedLoadJobs,
        onRetry: () => ref.refresh(employerJobsProvider(status)),
      ),
      data: (allJobs) {
        final jobs = query.isEmpty
            ? allJobs
            : allJobs.where((j) {
                final q = query.toLowerCase();
                return j.title.toLowerCase().contains(q) ||
                    (j.location?.toLowerCase().contains(q) ?? false);
              }).toList();

        if (jobs.isEmpty) {
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.invalidate(employerJobsProvider(status));
              await ref.read(employerJobsProvider(status).future);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                alignment: Alignment.center,
                child: UJobEmpty(
                  title: context.l10n.noJobsFound,
                  subtitle: context.l10n.noJobsPostedSub,
                  icon: HugeIcons.strokeRoundedJobSearch,
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(employerJobsProvider(status));
            await ref.read(employerJobsProvider(status).future);
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 112.h),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final job = jobs[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: UJobEmployerJobCard(
                job: job,
                isManaging: isManaging,
                onTap: () => context.push('/employer/jobs/${job.id}', extra: job),
                onApplicantsTap: () => context.push(
                  '/employer/jobs/${job.id}/applicants',
                  extra: job,
                ),
                onMoreTap: () => _showJobActions(context, ref, job),
                onEdit: () => JobActionHelpers.confirmEdit(
                  context,
                  () =>
                      context.push('/employer/jobs/${job.id}/edit', extra: job),
                ),
                onPause: () => JobActionHelpers.confirmPause(
                  context,
                  () async {
                    try {
                      await ref.read(employerJobServiceProvider).updateJobStatus(job.id, JobStatus.paused.name);
                      ref.invalidate(employerJobsProvider);
                      ref.invalidate(employerDashboardProvider);
                      if (context.mounted) {
                        UJobToast.success(context, 'Success', sub: 'Job paused');
                      }
                    } catch (e) {
                      if (context.mounted) UJobToast.error(context, 'Error', sub: e is DioException ? parseApiError(e) : 'Failed to pause job');
                    }
                  },
                ),
                onResume: () => JobActionHelpers.confirmResume(
                  context,
                  () async {
                    try {
                      await ref.read(employerJobServiceProvider).updateJobStatus(job.id, JobStatus.active.name);
                      ref.invalidate(employerJobsProvider);
                      ref.invalidate(employerDashboardProvider);
                      if (context.mounted) {
                        UJobToast.success(context, 'Success', sub: 'Job republished');
                      }
                    } catch (e) {
                      if (context.mounted) UJobToast.error(context, 'Error', sub: 'Failed to republish job');
                    }
                  },
                ),
                onPublish: () => JobActionHelpers.confirmPublish(
                  context,
                  () async {
                    try {
                      await ref.read(employerJobServiceProvider).updateJobStatus(job.id, JobStatus.active.name);
                      ref.invalidate(employerJobsProvider);
                      ref.invalidate(employerDashboardProvider);
                      if (context.mounted) {
                        UJobToast.success(context, 'Success', sub: 'Job published');
                      }
                    } catch (e) {
                      if (context.mounted) UJobToast.error(context, 'Error', sub: e is DioException ? parseApiError(e) : 'Failed to publish job');
                    }
                  },
                ),
                onReopen: () => JobActionHelpers.confirmReopen(
                  context,
                  () async {
                    try {
                      await ref.read(employerJobServiceProvider).updateJobStatus(job.id, JobStatus.active.name);
                      ref.invalidate(employerJobsProvider);
                      ref.invalidate(employerDashboardProvider);
                      if (context.mounted) {
                        UJobToast.success(context, 'Success', sub: 'Job reopened');
                      }
                    } catch (e) {
                      if (context.mounted) UJobToast.error(context, 'Error', sub: e is DioException ? parseApiError(e) : 'Failed to reopen job');
                    }
                  },
                ),
                onClose: () => _confirmClose(context, ref, job),
      onDelete: () => _confirmDelete(context, ref, job),
              ),
            );
          },
        ),
        // Close RefreshIndicator
        );
      },
    );
  }

  void _showJobActions(BuildContext context, WidgetRef ref, Job job) {
    showUJobEmployerJobActionsSheet(
      context: context,
      job: job,
      onEdit: () => JobActionHelpers.confirmEdit(
        context,
        () => context.push('/employer/jobs/${job.id}/edit', extra: job),
      ),
      onViewApplicants: () =>
          context.push('/employer/jobs/${job.id}/applicants', extra: job),
      onPause: () => JobActionHelpers.confirmPause(
        context,
        () async {
          try {
            await ref.read(employerJobServiceProvider).updateJobStatus(job.id, JobStatus.paused.name);
            ref.invalidate(employerJobsProvider);
            ref.invalidate(employerDashboardProvider);
            if (context.mounted) {
              UJobToast.success(context, 'Success', sub: 'Job paused');
            }
          } catch (e) {
                      if (context.mounted) UJobToast.error(context, 'Error', sub: e is DioException ? parseApiError(e) : 'Failed to pause job');
                    }
        },
      ),
      onResume: () => JobActionHelpers.confirmResume(
        context,
        () async {
          try {
            await ref.read(employerJobServiceProvider).updateJobStatus(job.id, JobStatus.active.name);
            ref.invalidate(employerJobsProvider);
            ref.invalidate(employerDashboardProvider);
            if (context.mounted) {
              UJobToast.success(context, 'Success', sub: 'Job republished');
            }
          } catch (e) {
            if (context.mounted) UJobToast.error(context, 'Error', sub: 'Failed to republish job');
          }
        },
      ),
      onPublish: () => JobActionHelpers.confirmPublish(
        context,
        () async {
          try {
            await ref.read(employerJobServiceProvider).updateJobStatus(job.id, JobStatus.active.name);
            ref.invalidate(employerJobsProvider);
            ref.invalidate(employerDashboardProvider);
            if (context.mounted) {
              UJobToast.success(context, 'Success', sub: 'Job published');
            }
          } catch (e) {
                      if (context.mounted) UJobToast.error(context, 'Error', sub: e is DioException ? parseApiError(e) : 'Failed to publish job');
                    }
        },
      ),
      onReopen: () => JobActionHelpers.confirmReopen(
        context,
        () async {
          try {
            await ref.read(employerJobServiceProvider).updateJobStatus(job.id, JobStatus.active.name);
            ref.invalidate(employerJobsProvider);
            ref.invalidate(employerDashboardProvider);
            if (context.mounted) {
              UJobToast.success(context, 'Success', sub: 'Job reopened');
            }
          } catch (e) {
                      if (context.mounted) UJobToast.error(context, 'Error', sub: e is DioException ? parseApiError(e) : 'Failed to reopen job');
                    }
        },
      ),
                onClose: () => _confirmClose(context, ref, job),
      onDelete: () => _confirmDelete(context, ref, job),
    );
  }

  Future<void> _confirmClose(
    BuildContext context,
    WidgetRef ref,
    Job job,
  ) async {
    showDialog(
      context: context,
      builder: (ctx) => UJobAlertDialog(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedAlert02,
          color: AppColors.text,
          size: 32.r,
        ),
        iconBgColor: AppColors.text,
        title: 'Close Job',
        description: 'Are you sure you want to close this job? You will no longer receive new applications.',
        cancelText: 'Cancel',
        confirmText: 'Close Job',
        onConfirm: () async {
          try {
            await ref.read(employerJobServiceProvider).updateJobStatus(job.id, JobStatus.closed.name);
            ref.invalidate(employerJobsProvider);
            ref.invalidate(employerDashboardProvider);
            if (context.mounted) {
              UJobToast.success(context, 'Success', sub: 'Job closed');
            }
          } catch (e) {
            if (context.mounted) UJobToast.error(context, 'Error', sub: e is DioException ? parseApiError(e) : 'Failed to close job');
          }
          if (context.mounted) Navigator.pop(ctx);
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Job job,
  ) async {
    showDialog(
      context: context,
      builder: (ctx) => UJobAlertDialog(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedDelete01,
          color: AppColors.error,
          size: 32.r,
        ),
        iconBgColor: AppColors.error,
        title: 'Delete Job',
        description: 'Are you sure you want to permanently delete this job?',
        cancelText: 'Cancel',
        confirmText: 'Delete',
        onConfirm: () async {
          try {
            await ref.read(employerJobServiceProvider).deleteJob(job.id);
            ref.invalidate(employerJobsProvider);
            ref.invalidate(employerDashboardProvider);
            if (context.mounted) {
              UJobToast.success(context, 'Success', sub: 'Job deleted');
            }
          } catch (e) {
            if (context.mounted) UJobToast.error(context, 'Error', sub: e is DioException ? parseApiError(e) : 'Failed to delete job');
          }
          if (context.mounted) Navigator.pop(ctx);
        },
      ),
    );
  }
}
