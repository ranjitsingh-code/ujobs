import "../../../core/widgets/ujob_toast.dart";
import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/models/job.dart';
import '../../../core/widgets/ujob_verification_banners.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ujob_avatar.dart';
import '../../../core/widgets/ujob_notification_button.dart';
import '../../shared/chat/conversation_provider.dart';
import 'employer_dashboard_provider.dart';
import '../../../core/widgets/ujob_loading.dart';
import '../../../core/widgets/ujob_alert_dialog.dart';
import '../../../core/widgets/ujob_employer_job_card.dart';
import '../../../core/widgets/ujob_employer_job_actions_sheet.dart';
import '../../../core/utils/job_action_helpers.dart';
import '../jobs/employer_job_provider.dart';

class EmployerDashboardScreen extends ConsumerWidget {
  const EmployerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
        final auth = ref.watch(authProvider);
    final dashboardAsync = ref.watch(employerDashboardProvider);
    
    return dashboardAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.bg,
        body: UJobSpinner(),
      ),
      error: (e, s) => Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Failed to load dashboard', style: AppText.bodyMedium.copyWith(color: AppColors.error)),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () => ref.refresh(employerDashboardProvider),
                child: const Text('Retry'),
              )
            ],
          ),
        ),
      ),
      data: (dashboard) {
        final conversations = ref.watch(conversationsProvider).valueOrNull ?? demoConversations;
        final messagesToReply = dashboard.totalJobs == 0
            ? const <Conversation>[]
            : conversations.where((conversation) => conversation.requiresEmployerReply).toList();
            
        final user = auth.valueOrNull;
        final firstName = user?.firstName.trim();
        final name = firstName?.isNotEmpty == true ? firstName! : 'there';
        final hour = DateTime.now().hour;
        final greeting = hour < 12 ? 'Good morning' : hour < 18 ? 'Good afternoon' : 'Good evening';

        return Scaffold(
      backgroundColor: AppColors.bg,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(employerDashboardProvider);
          await ref.read(employerDashboardProvider.future);
        },
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _DashboardHeader(
              greeting: greeting,
              name: name,
              dashboard: dashboard,
              onNotificationsTap: () => context.push('/employer/notifications'),
              onTotalJobsTap: () => context.go('/employer/jobs', extra: 0),
              onActiveJobsTap: () => context.go('/employer/jobs', extra: 1),
              onTotalApplicantsTap: () => context.push('/employer/applicants', extra: 0),
              onShortlistedTap: () => context.push('/employer/applicants', extra: 2),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 112.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _QuickActions(
                  isVerified: dashboard.isVerified,
                  onPostJob: () {
                    if (!dashboard.isVerified) {
                      showDialog(
                        context: context,
                        builder: (ctx) => UJobAlertDialog(
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedAlert02,
                            color: AppColors.error,
                            size: 32.r,
                          ),
                          iconBgColor: AppColors.error,
                          title: 'Verification Required',
                          description: 'Your company profile must be 100% complete and verified by an admin before you can post jobs. If you have already completed your profile, please wait for admin approval.',
                          confirmText: 'Okay',
                          confirmColor: AppColors.primary,
                          onConfirm: () {
                            Navigator.pop(ctx);
                          },
                        ),
                      );
                      return;
                    }
                    context.push('/employer/post-job');
                  },
                ),
                if (dashboard.verificationStatus == 'unverified') ...[
                  SizedBox(height: 24.h),
                  const UJobVerificationPendingBanner(),
                ],
                if (dashboard.profileCompleted < 100) ...[
                  SizedBox(height: 24.h),
                  UJobCompanyProfileSetup(
                    onSetup: () {
                      context.push('/employer/profile');
                    },
                  ),
                ],
                // if (messagesToReply.isNotEmpty) ...[
                //   SizedBox(height: 24.h),
                //   _MessagesToReply(
                //     conversations: messagesToReply,
                //     onViewAll: () => context.go('/employer/messages'),
                //   ),
                // ],
                SizedBox(height: 24.h),
                _SectionHeader(
                  title: 'My Job Listings',
                  actionLabel: dashboard.recentJobs.isEmpty ? null : 'See all',
                  onActionTap: dashboard.recentJobs.isEmpty
                      ? null
                      : () => context.go('/employer/jobs'),
                ),
                SizedBox(height: 14.h),
                if (dashboard.recentJobs.isEmpty)
                  _EmptyJobs(
                    isVerified: dashboard.isVerified,
                    onPostJob: () {
                      if (!dashboard.isVerified) {
                        showDialog(
                          context: context,
                          builder: (ctx) => UJobAlertDialog(
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedAlert02,
                              color: AppColors.error,
                              size: 32.r,
                            ),
                            iconBgColor: AppColors.error,
                            title: 'Verification Required',
                            description: 'Your company profile must be 100% complete and verified by an admin before you can post jobs. If you have already completed your profile, please wait for admin approval.',
                            confirmText: 'Okay',
                            confirmColor: AppColors.primary,
                            onConfirm: () {
                              Navigator.pop(ctx);
                            },
                          ),
                        );
                        return;
                      }
                      context.push('/employer/post-job');
                    },
                  )
                else
                  ...dashboard.recentJobs.map((job) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: UJobEmployerJobCard(
                        job: job,
                        isManaging: false,
                        onTap: () => context.push('/employer/jobs/${job.id}', extra: job),
                        onApplicantsTap: () => context.push(
                          '/employer/jobs/${job.id}/applicants',
                          extra: job,
                        ),
                        onMoreTap: () => showUJobEmployerJobActionsSheet(
                          context: context,
                          job: job,
                          onEdit: () => JobActionHelpers.confirmEdit(
                            context,
                            () => context.push(
                              '/employer/jobs/${job.id}/edit',
                              extra: job,
                            ),
                          ),
                          onViewApplicants: () => context.push(
                            '/employer/jobs/${job.id}/applicants',
                            extra: job,
                          ),
                          onPause: () => JobActionHelpers.confirmPause(
                            context,
                            () async {
                              try {
                                await ref.read(employerJobServiceProvider).updateJobStatus(job.id, JobStatus.paused.name);
                                ref.invalidate(employerDashboardProvider);
                                ref.invalidate(employerJobsProvider);
                                if (context.mounted) {
                                  UJobToast.success(context, 'Success', sub: 'Job paused');
                                }
                              } catch (e) {
                                if (context.mounted) UJobToast.error(context, 'Error', sub: 'Failed to pause job');
                              }
                            },
                          ),
                          onResume: () => JobActionHelpers.confirmResume(
                            context,
                            () async {
                              try {
                                await ref.read(employerJobServiceProvider).updateJobStatus(job.id, JobStatus.active.name);
                                ref.invalidate(employerDashboardProvider);
                                ref.invalidate(employerJobsProvider);
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
                                ref.invalidate(employerDashboardProvider);
                                ref.invalidate(employerJobsProvider);
                                if (context.mounted) {
                                  UJobToast.success(context, 'Success', sub: 'Job published');
                                }
                              } catch (e) {
                                if (context.mounted) UJobToast.error(context, 'Error', sub: 'Failed to publish job');
                              }
                            },
                          ),
                          onReopen: () => JobActionHelpers.confirmReopen(
                            context,
                            () async {
                              try {
                                await ref.read(employerJobServiceProvider).updateJobStatus(job.id, JobStatus.active.name);
                                ref.invalidate(employerDashboardProvider);
                                ref.invalidate(employerJobsProvider);
                                if (context.mounted) {
                                  UJobToast.success(context, 'Success', sub: 'Job reopened');
                                }
                              } catch (e) {
                                if (context.mounted) UJobToast.error(context, 'Error', sub: 'Failed to reopen job');
                              }
                            },
                          ),
                          onClose: () {
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
                                    ref.invalidate(employerDashboardProvider);
                                    ref.invalidate(employerJobsProvider);
                                    if (context.mounted) {
                                      UJobToast.success(context, 'Success', sub: 'Job closed');
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      UJobToast.error(context, 'Error', sub: 'Failed to close job');
                                    }
                                  }
                                  if (context.mounted) {
                                    Navigator.pop(ctx);
                                  }
                                },
                              ),
                            );
                          },
                          onDelete: () {
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
                                    ref.invalidate(employerDashboardProvider);
                                    ref.invalidate(employerJobsProvider);
                                    if (context.mounted) {
                                      UJobToast.success(context, 'Success', sub: 'Job deleted');
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      UJobToast.error(context, 'Error', sub: 'Failed to delete job');
                                    }
                                  }
                                  if (context.mounted) {
                                    Navigator.pop(ctx);
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }),
              ]),
            ),
          ),
        ],
      ),
      ),
    );
      },
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final String greeting;
  final String name;
  final EmployerDashboardData dashboard;
  final VoidCallback onNotificationsTap;
  final VoidCallback onTotalJobsTap;
  final VoidCallback onActiveJobsTap;
  final VoidCallback onTotalApplicantsTap;
  final VoidCallback onShortlistedTap;

  const _DashboardHeader({
    required this.greeting,
    required this.name,
    required this.dashboard,
    required this.onNotificationsTap,
    required this.onTotalJobsTap,
    required this.onActiveJobsTap,
    required this.onTotalApplicantsTap,
    required this.onShortlistedTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.authGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: AppText.body.copyWith(
                            color: AppColors.surface.withValues(alpha: 0.72),
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.heading1.copyWith(
                            color: AppColors.surface,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  UJobNotificationButton(onTap: onNotificationsTap, borderColor: AppColors.primary),
                ],
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      value: '${dashboard.totalJobs}',
                      label: context.l10n.totalJobs,
                      icon: Icons.work_outline_rounded,
                      onTap: onTotalJobsTap,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _StatTile(
                      value: '${dashboard.activeJobs}',
                      label: context.l10n.activeJobs,
                      icon: Icons.work_history_outlined,
                      onTap: onActiveJobsTap,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      value: '${dashboard.totalApplicants}',
                      label: context.l10n.totalApplicants,
                      icon: Icons.groups_outlined,
                      onTap: onTotalApplicantsTap,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _StatTile(
                      value: '${dashboard.shortlisted}',
                      label: context.l10n.statusShortlisted,
                      icon: Icons.bookmark_added_outlined,
                      onTap: onShortlistedTap,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _StatTile({
    required this.value,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface.withValues(alpha: 0.12),
      borderRadius: AppRadius.lg,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.lg,
        child: Container(
          height: 78.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.surface.withValues(alpha: 0.2)),
            borderRadius: AppRadius.lg,
          ),
          child: Row(
            children: [
              Container(
                width: 34.r,
                height: 34.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.12),
                  borderRadius: AppRadius.sm,
                ),
                child: Icon(icon, color: AppColors.surface, size: 19.r),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        value,
                        style: AppText.heading2.copyWith(
                          color: AppColors.surface,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.caption.copyWith(
                        color: AppColors.surface.withValues(alpha: 0.76),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final bool isVerified;
  final VoidCallback onPostJob;

  const _QuickActions({
    required this.isVerified,
    required this.onPostJob,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 1.0,
      child: Container(
        height: 58.h,
        decoration: BoxDecoration(
          borderRadius: AppRadius.md,
          boxShadow: AppShadow.button(AppColors.primary),
        ),
        child: Material(
          color: AppColors.primary,
          clipBehavior: Clip.antiAlias,
          borderRadius: AppRadius.md,
          child: InkWell(
            onTap: onPostJob,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Row(
                children: [
                  Container(
                    width: 34.r,
                    height: 34.r,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.16),
                      borderRadius: AppRadius.sm,
                    ),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedPlusSign,
                      color: AppColors.surface,
                      size: 19.r,
                    ),
                  ),
                  SizedBox(width: 11.w),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Post a Job',
                          style: AppText.titleSm.copyWith(
                            color: AppColors.surface,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Create a new job listing',
                          style: AppText.caption.copyWith(
                            color: AppColors.surface.withValues(alpha: 0.72),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.surface.withValues(alpha: 0.86),
                    size: 21.r,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MessagesToReply extends StatelessWidget {
  final List<Conversation> conversations;
  final VoidCallback onViewAll;

  const _MessagesToReply({
    required this.conversations,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Needs Reply',
          actionLabel: 'View all',
          onActionTap: onViewAll,
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 78.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: conversations.length,
            separatorBuilder: (_, _) => SizedBox(width: 16.w),
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              return _MessageAvatar(conversation: conversation);
            },
          ),
        ),
      ],
    );
  }
}

class _MessageAvatar extends StatelessWidget {
  final Conversation conversation;

  const _MessageAvatar({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final initials =
        conversation.otherInitials ??
        (conversation.otherName.isNotEmpty ? conversation.otherName[0] : '?');

    return Semantics(
      button: true,
      label: conversation.unreadCount > 0
          ? '${conversation.otherName}, ${conversation.unreadCount} unread messages'
          : '${conversation.otherName}, awaiting reply',
      child: InkWell(
        onTap: () {
          if (conversation.id.startsWith('demo-')) {
            context.go('/employer/messages');
            return;
          }
          context.push(
            '/conversations/${conversation.id}',
            extra: {
              'name': conversation.otherName,
              'initials': conversation.otherInitials,
              'avatar': conversation.otherAvatar,
            },
          );
        },
        borderRadius: AppRadius.sm,
        child: SizedBox(
          width: 62.r,
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  UJobAvatar(
                    imageUrl: conversation.otherAvatar,
                    initials: initials,
                    size: 50.r,
                  ),
                  Positioned(
                    right: -2.r,
                    top: -3.r,
                    child: conversation.unreadCount > 0
                        ? Container(
                            constraints: BoxConstraints(minWidth: 19.r),
                            height: 19.r,
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: AppRadius.pill,
                              border: Border.all(color: AppColors.bg, width: 2),
                            ),
                            child: Text(
                              conversation.unreadCount > 9
                                  ? '9+'
                                  : '${conversation.unreadCount}',
                              style: AppText.caption.copyWith(
                                color: AppColors.surface,
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w800,
                                height: 1,
                              ),
                            ),
                          )
                        : Container(
                            width: 13.r,
                            height: 13.r,
                            decoration: BoxDecoration(
                              color: AppColors.warning,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.bg, width: 2),
                            ),
                          ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                conversation.otherName.split(' ').first,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.caption.copyWith(
                  color: AppColors.text2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppText.heading3.copyWith(
              color: AppColors.text2,
              letterSpacing: 0,
            ),
          ),
        ),
        if (actionLabel != null && onActionTap != null)
          TextButton(
            onPressed: onActionTap,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel!,
              style: AppText.bodyMd.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptyJobs extends StatelessWidget {
  final bool isVerified;
  final VoidCallback onPostJob;

  const _EmptyJobs({required this.isVerified, required this.onPostJob});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: AppRadius.xl,
      ),
      child: Column(
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedBriefcase01,
            color: AppColors.muted2,
            size: 28.r,
          ),
          SizedBox(height: 10.h),
          Text(
            'You have no listed jobs yet',
            textAlign: TextAlign.center,
            style: AppText.titleMd.copyWith(color: AppColors.text2),
          ),
          SizedBox(height: 6.h),
          Text(
            'Create your first listing to start receiving applicants.',
            textAlign: TextAlign.center,
            style: AppText.small.copyWith(color: AppColors.muted),
          ),
          SizedBox(height: 18.h),
          Opacity(
            opacity: 1.0,
            child: FilledButton.icon(
              onPressed: onPostJob,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
              ),
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedPlusSign,
                color: AppColors.surface,
                size: 18.r,
              ),
              label: Text('Post a Job', style: AppText.button),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyProfileSetup extends ConsumerWidget {
  final VoidCallback onSetup;

  const _CompanyProfileSetup({required this.onSetup});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.xl,
        border: Border.all(color: AppColors.warning),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedBuilding03,
              color: AppColors.warning,
              size: 28.r,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Complete your company profile',
                  style: AppText.titleSm.copyWith(color: AppColors.text),
                ),
                SizedBox(height: 4.h),
                Text(
                  'A complete profile helps attract better candidates and builds trust.',
                  style: AppText.small.copyWith(color: AppColors.muted),
                ),
                SizedBox(height: 16.h),
                FilledButton(
                  onPressed: onSetup,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    foregroundColor: AppColors.surface,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 8.h,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
                  ),
                  child: Text(
                    'Setup Now',
                    style: AppText.button.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VerificationPendingBanner extends StatelessWidget {
  const _VerificationPendingBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.xl,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedAlert02,
              color: AppColors.error,
              size: 28.r,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile verification pending',
                  style: AppText.titleSm.copyWith(color: AppColors.text),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Your profile is not verified yet. You have to wait for the verification from the admin.',
                  style: AppText.small.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
