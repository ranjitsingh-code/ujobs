import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
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
    final isProfileComplete = ref.watch(isCompanyProfileCompleteProvider);
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
        isProfileComplete: isProfileComplete,
        onTap: () {
          if (!isProfileComplete) {
            showDialog(
              context: context,
              builder: (ctx) => UJobAlertDialog(
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedAlert02,
                  color: AppColors.warning,
                  size: 32.r,
                ),
                iconBgColor: AppColors.warning,
                title: 'Action Required',
                description:
                    'You must complete your company profile before you can post a new job.',
                confirmText: 'Setup Profile',
                confirmColor: AppColors.primary,
                cancelText: 'Cancel',
                onConfirm: () {
                  Navigator.pop(ctx);
                  context.push('/employer/profile');
                },
              ),
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
          return UJobEmpty(
            title: context.l10n.noJobsFound,
            subtitle: context.l10n.noJobsPostedSub,
            icon: HugeIcons.strokeRoundedJobSearch,
          );
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 112.h),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final job = jobs[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: UJobEmployerJobCard(
                job: job,
                isManaging: isManaging,
                onTap: () => context.push('/employer/jobs/${job.id}'),
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
                  () => ref
                      .read(demoEmployerJobsProvider.notifier)
                      .updateStatus(job.id, JobStatus.paused),
                ),
                onResume: () => JobActionHelpers.confirmResume(
                  context,
                  () => ref
                      .read(demoEmployerJobsProvider.notifier)
                      .updateStatus(job.id, JobStatus.active),
                ),
                onPublish: () => JobActionHelpers.confirmPublish(
                  context,
                  () => ref
                      .read(demoEmployerJobsProvider.notifier)
                      .updateStatus(job.id, JobStatus.active),
                ),
                onReopen: () => JobActionHelpers.confirmReopen(
                  context,
                  () => ref
                      .read(demoEmployerJobsProvider.notifier)
                      .updateStatus(job.id, JobStatus.active),
                ),
                onDelete: () => _confirmDelete(context, ref, job),
              ),
            );
          },
        );
      },
    );
  }

  void _showJobActions(BuildContext context, WidgetRef ref, Job job) {
    final notifier = ref.read(demoEmployerJobsProvider.notifier);

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
        () => notifier.updateStatus(job.id, JobStatus.paused),
      ),
      onResume: () => JobActionHelpers.confirmResume(
        context,
        () => notifier.updateStatus(job.id, JobStatus.active),
      ),
      onPublish: () => JobActionHelpers.confirmPublish(
        context,
        () => notifier.updateStatus(job.id, JobStatus.active),
      ),
      onReopen: () => JobActionHelpers.confirmReopen(
        context,
        () => notifier.updateStatus(job.id, JobStatus.active),
      ),
      onDelete: () => _confirmDelete(context, ref, job),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Job job,
  ) async {
    final isClosedOrRejected =
        job.status == JobStatus.closed || job.status == JobStatus.rejected;

    showDialog(
      context: context,
      builder: (ctx) => UJobAlertDialog(
        icon: HugeIcon(
          icon: isClosedOrRejected
              ? HugeIcons.strokeRoundedDelete01
              : HugeIcons.strokeRoundedAlert02,
          color: AppColors.error,
          size: 32.r,
        ),
        iconBgColor: AppColors.error,
        title: isClosedOrRejected ? 'Delete Job' : 'Close Job',
        description: isClosedOrRejected
            ? 'Are you sure you want to permanently delete this job?'
            : 'Are you sure you want to close this job? You will no longer receive new applications.',
        cancelText: 'Cancel',
        confirmText: isClosedOrRejected ? 'Delete' : 'Close Job',
        onConfirm: () {
          if (!isClosedOrRejected) {
            ref
                .read(demoEmployerJobsProvider.notifier)
                .updateStatus(job.id, JobStatus.closed);
          }
          Navigator.pop(ctx);
        },
      ),
    );
  }
}
