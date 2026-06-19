import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/models/job.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ujob_avatar.dart';
import '../../shared/chat/conversation_provider.dart';
import 'employer_dashboard_provider.dart';

class EmployerDashboardScreen extends ConsumerWidget {
  const EmployerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final dashboard = ref.watch(employerDashboardProvider);
    final conversations =
        ref.watch(conversationsProvider).valueOrNull ?? demoConversations;
    final messagesToReply = dashboard.totalJobs == 0
        ? const <Conversation>[]
        : conversations
              .where((conversation) => conversation.requiresEmployerReply)
              .toList();
    final user = auth.valueOrNull;
    final firstName = user?.firstName.trim();
    final name = firstName?.isNotEmpty == true ? firstName! : 'there';
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 18
        ? 'Good afternoon'
        : 'Good evening';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _DashboardHeader(
              greeting: greeting,
              name: name,
              dashboard: dashboard,
              onNotificationsTap: () => context.push('/employer/notifications'),
              onJobsTap: () => context.go('/employer/jobs'),
              onApplicantsTap: () => context.push('/employer/applicants'),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 112.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _QuickActions(
                  onPostJob: () => context.push('/employer/post-job'),
                ),
                if (messagesToReply.isNotEmpty) ...[
                  SizedBox(height: 24.h),
                  _MessagesToReply(
                    conversations: messagesToReply,
                    onViewAll: () => context.go('/employer/messages'),
                  ),
                ],
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
                    onPostJob: () => context.push('/employer/post-job'),
                  )
                else
                  ...dashboard.recentJobs.indexed.map((entry) {
                    final index = entry.$1;
                    final job = entry.$2;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _JobCard(
                        job: job,
                        applicantCount:
                            _applicantCounts[index % _applicantCounts.length],
                        onTap: () => context.push('/employer/jobs/${job.id}'),
                        onApplicantsTap: () =>
                            context.push('/employer/applicants'),
                      ),
                    );
                  }),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

const _applicantCounts = [47, 89, 123];

class _DashboardHeader extends StatelessWidget {
  final String greeting;
  final String name;
  final EmployerDashboardData dashboard;
  final VoidCallback onNotificationsTap;
  final VoidCallback onJobsTap;
  final VoidCallback onApplicantsTap;

  const _DashboardHeader({
    required this.greeting,
    required this.name,
    required this.dashboard,
    required this.onNotificationsTap,
    required this.onJobsTap,
    required this.onApplicantsTap,
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
                  _NotificationButton(onTap: onNotificationsTap),
                ],
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      value: '${dashboard.totalJobs}',
                      label: 'Total Jobs',
                      icon: Icons.work_outline_rounded,
                      onTap: onJobsTap,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _StatTile(
                      value: '${dashboard.activeJobs}',
                      label: 'Active Jobs',
                      icon: Icons.work_history_outlined,
                      onTap: onJobsTap,
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
                      label: 'Total Applicants',
                      icon: Icons.groups_outlined,
                      onTap: onApplicantsTap,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _StatTile(
                      value: '${dashboard.shortlisted}',
                      label: 'Shortlisted',
                      icon: Icons.bookmark_added_outlined,
                      onTap: onApplicantsTap,
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

class _NotificationButton extends StatelessWidget {
  final VoidCallback onTap;

  const _NotificationButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onTap,
          tooltip: 'Notifications',
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface.withValues(alpha: 0.12),
            fixedSize: Size(44.r, 44.r),
          ),
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedNotification01,
            color: AppColors.surface,
            size: 23,
          ),
        ),
        Positioned(
          right: -1.w,
          top: -3.h,
          child: Container(
            width: 20.r,
            height: 20.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: Text(
              '2',
              style: AppText.caption.copyWith(
                color: AppColors.surface,
                fontSize: 9.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
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
  final VoidCallback onPostJob;

  const _QuickActions({required this.onPostJob});

  @override
  Widget build(BuildContext context) {
    return Container(
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

class _JobCard extends StatelessWidget {
  final Job job;
  final int applicantCount;
  final VoidCallback onTap;
  final VoidCallback onApplicantsTap;

  const _JobCard({
    required this.job,
    required this.applicantCount,
    required this.onTap,
    required this.onApplicantsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.xl,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.xl,
        child: Container(
          constraints: BoxConstraints(minHeight: 108.h),
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: AppRadius.xl,
            boxShadow: AppShadow.card(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40.r,
                    height: 40.r,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: AppRadius.sm,
                    ),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedBriefcase01,
                      color: AppColors.primary,
                      size: 21.r,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.titleMd.copyWith(
                            color: AppColors.text2,
                            letterSpacing: 0,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          _postedLabel(job.createdAt),
                          style: AppText.caption.copyWith(
                            color: AppColors.muted2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 32.r,
                    height: 32.r,
                    child: PopupMenuButton<_JobMenuAction>(
                      padding: EdgeInsets.zero,
                      tooltip: 'Job actions',
                      icon: Icon(
                        Icons.more_horiz_rounded,
                        color: AppColors.muted,
                        size: 22.r,
                      ),
                      onSelected: (action) {
                        switch (action) {
                          case _JobMenuAction.details:
                            onTap();
                          case _JobMenuAction.applicants:
                            onApplicantsTap();
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: _JobMenuAction.details,
                          child: Text('View job details'),
                        ),
                        PopupMenuItem(
                          value: _JobMenuAction.applicants,
                          child: Text('View applicants'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 11.h),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(job.status).withValues(alpha: 0.1),
                      borderRadius: AppRadius.pill,
                    ),
                    child: Text(
                      _statusLabel(job.status),
                      style: AppText.caption.copyWith(
                        color: _statusColor(job.status),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.location_on_outlined,
                    size: 15.r,
                    color: AppColors.muted2,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      _workplaceLabel(job.workplaceType),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.caption.copyWith(color: AppColors.muted),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedUserGroup,
                    color: AppColors.primary,
                    size: 16.r,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '$applicantCount applicants',
                    style: AppText.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.muted2,
                    size: 18.r,
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

enum _JobMenuAction { details, applicants }

String _postedLabel(DateTime? createdAt) {
  if (createdAt == null) return 'Recently posted';
  final days = DateTime.now().difference(createdAt).inDays;
  if (days <= 0) return 'Posted today';
  if (days == 1) return 'Posted 1d ago';
  return 'Posted ${days}d ago';
}

String _workplaceLabel(String workplaceType) {
  return switch (workplaceType) {
    'remote' => 'Remote',
    'hybrid' => 'Hybrid',
    'onsite' => 'On-site',
    _ => workplaceType,
  };
}

String _statusLabel(JobStatus status) {
  return switch (status) {
    JobStatus.active => 'Active',
    JobStatus.pending => 'Pending',
    JobStatus.draft => 'Draft',
    JobStatus.closed => 'Closed',
  };
}

Color _statusColor(JobStatus status) {
  return switch (status) {
    JobStatus.active => AppColors.success,
    JobStatus.pending => AppColors.warning,
    JobStatus.draft => AppColors.muted,
    JobStatus.closed => AppColors.error,
  };
}

class _EmptyJobs extends StatelessWidget {
  final VoidCallback onPostJob;

  const _EmptyJobs({required this.onPostJob});

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
          FilledButton.icon(
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
        ],
      ),
    );
  }
}
