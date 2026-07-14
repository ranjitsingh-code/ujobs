import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/l10n_extensions.dart';
import '../../../core/widgets/ujob_loading.dart';
import '../../../core/widgets/ujob_error.dart';
import '../../../core/widgets/ujob_image.dart';
import '../../../core/widgets/ujob_pill_tab_bar.dart';
import '../../../core/widgets/ujob_toast.dart';
import '../../shared/chat/conversation_provider.dart' hide ApplicationStatus;
import '../../../core/models/application.dart';
import 'seeker_application_provider.dart';

class MyApplicationsScreen extends ConsumerStatefulWidget {
  final int initialIndex;
  const MyApplicationsScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<MyApplicationsScreen> createState() =>
      _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends ConsumerState<MyApplicationsScreen> {
  late final PageController _pageController;
  late int _selectedIndex;

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
    _selectedIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
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
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: appsAsync.when(
          loading: () => const UJobLoading(),
          error: (err, stack) => UJobError(
            message: l10n.error,
            onRetry: () => ref.refresh(seekerApplicationsProvider(null)),
          ),
          data: (applications) {
            if (applications.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(seekerApplicationsProvider(null));
                },
                color: AppColors.seekPrimary,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: 200.h),
                    Center(
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
                    ),
                  ],
                ),
              );
            }

            final labels = _filters.map((f) {
              final count = f == 'All'
                  ? applications
                      .where((a) => a.status != ApplicationStatus.saved)
                      .map((a) => a.job.id)
                      .toSet()
                      .length
                  : applications.where((a) {
                      return a.status.name.toLowerCase() == f.toLowerCase() ||
                          (f == 'Interview' && a.status.name == 'interviewing') ||
                          (f == 'Offer' && a.status.name == 'offered');
                    }).length;
              return count > 0 ? '$f ($count)' : f;
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

class _ApplicationList extends ConsumerWidget {
  final List<Application> applications;
  final String filter;

  const _ApplicationList({required this.applications, required this.filter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var filtered = applications.where((a) {
      if (filter == 'All') return true;
      return a.status.name.toLowerCase() == filter.toLowerCase() ||
          (filter == 'Interview' && a.status.name == 'interviewing') ||
          (filter == 'Offer' && a.status.name == 'offered');
    }).toList();

    if (filter == 'All') {
      final uniqueMap = <int, Application>{};
      for (final app in filtered) {
        if (app.status == ApplicationStatus.saved) continue;
        uniqueMap[app.job.id] = app;
      }
      filtered = uniqueMap.values.toList();
    }

    filtered = filtered
        .where((app) => app.status != ApplicationStatus.saved)
        .toList();

    if (filtered.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(seekerApplicationsProvider(null));
        },
        color: AppColors.seekPrimary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: 150.h),
            Center(
              child: Text(
                'No applications in this category.',
                style: AppText.body.copyWith(color: AppColors.muted),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(seekerApplicationsProvider(null));
      },
      color: AppColors.seekPrimary,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppSpacing.pagePad,
        itemCount: filtered.length,
        separatorBuilder: (_, _) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final app = filtered[index];
          return _ApplicationCard(
            application: app,
            onTap: () => context.push(
              '/seeker/jobs/${app.job.id}',
              extra: {'source': 'applications'},
            ),
          );
        },
      ),
    );
  }
}

class _ApplicationCard extends ConsumerStatefulWidget {
  final Application application;
  final VoidCallback onTap;

  const _ApplicationCard({required this.application, required this.onTap});

  @override
  ConsumerState<_ApplicationCard> createState() => _ApplicationCardState();
}

class _ApplicationCardState extends ConsumerState<_ApplicationCard> {
  bool _openingChat = false;

  Application get application => widget.application;

  Future<void> _openChat() async {
    if (_openingChat) return;
    setState(() => _openingChat = true);
    try {
      final companyName = application.job.company?.name;
      final conv = await resolveJobConversation(ref, companyName: companyName);
      if (!mounted) return;
      if (conv == null) {
        context.push('/seeker/messages');
        return;
      }
      final displayName =
          conv.otherName.isNotEmpty ? conv.otherName : (companyName ?? '');
      context.push(
        '/conversations/${conv.id}',
        extra: {
          'otherId': conv.otherId,
          'name': displayName,
          'initials': conv.otherInitials,
          'avatar': conv.otherAvatar,
          'jobId': application.job.id.toString(),
        },
      );
    } catch (e) {
      if (!mounted) return;
      context.push('/seeker/messages');
    } finally {
      if (mounted) setState(() => _openingChat = false);
    }
  }

  String _formatAppliedDate() =>
      'Applied ${DateFormat('d MMM yyyy').format(application.createdAt)}';

  String _formatEmploymentType(String value) {
    if (value.trim().isEmpty) return '';
    return value
        .split('_')
        .map((part) => part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  String _formatSalary() {
    final min = application.job.salaryMin;
    final max = application.job.salaryMax;
    final currency = application.job.salaryCurrency ?? '';
    final parts = <String>[];

    String fmt(String? value) {
      final numVal = num.tryParse(value ?? '');
      if (numVal == null) return value ?? '';
      return NumberFormat('#,##0').format(numVal);
    }

    if ((min ?? '').isNotEmpty && (max ?? '').isNotEmpty) {
      parts.add('${fmt(min)} - ${fmt(max)}');
    } else if ((min ?? '').isNotEmpty) {
      parts.add(fmt(min));
    } else if ((max ?? '').isNotEmpty) {
      parts.add(fmt(max));
    }

    if (parts.isEmpty) return '';
    return [currency, parts.first].where((e) => e.trim().isNotEmpty).join(' ');
  }

  String _statusLabel() {
    switch (application.status) {
      case ApplicationStatus.applied:
        return 'Applied';
      case ApplicationStatus.shortlisted:
        return 'Shortlisted';
      case ApplicationStatus.interviewing:
        return 'Interview';
      case ApplicationStatus.offered:
        return 'Offer';
      case ApplicationStatus.hired:
        return 'Hired';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.saved:
        return 'Saved';
    }
  }

  Color _statusColor() {
    switch (application.status) {
      case ApplicationStatus.applied:
        return AppColors.info;
      case ApplicationStatus.shortlisted:
        return AppColors.stageShortlisted;
      case ApplicationStatus.interviewing:
        return AppColors.stageInterviewed;
      case ApplicationStatus.offered:
        return AppColors.stageOffered;
      case ApplicationStatus.hired:
        return AppColors.success;
      case ApplicationStatus.rejected:
        return AppColors.error;
      case ApplicationStatus.saved:
        return AppColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final companyName = application.job.company?.name ?? 'Company';
    final location = (application.job.location ?? '').trim();
    final employmentType = application.job.employmentType.trim().isNotEmpty
        ? _formatEmploymentType(application.job.employmentType)
        : '';
    final salary = _formatSalary();
    final statusColor = _statusColor();

    return Material(
      color: AppColors.surface,
      child: InkWell(
        borderRadius: AppRadius.xl2,
        onTap: widget.onTap,
        child: Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            borderRadius: AppRadius.xl,
            border: Border.all(color: AppColors.border),
            boxShadow: AppShadow.card(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CompanyAvatar(name: companyName, logoUrl: application.job.company?.logo),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.job.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.titleMd.copyWith(color: AppColors.text),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          companyName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.body.copyWith(
                            color: AppColors.text2,
                            height: 1.2,
                          ),
                        ),
                        if (location.isNotEmpty) ...[
                          SizedBox(height: 4.h),
                          _MetaItem(
                            icon: HugeIcons.strokeRoundedLocation01,
                            label: location,
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: AppRadius.pill,
                        ),
                        child: Text(
                          _statusLabel(),
                          style: AppText.label.copyWith(color: statusColor),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      GestureDetector(
                        onTap: () {
                          if (application.job.chatEnabled) {
                            _openChat();
                          } else {
                            UJobToast.info(
                              context,
                              context.l10n.messageAction,
                              sub: context.l10n.chatNotYetAvailableMessage,
                            );
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: (application.job.chatEnabled
                                    ? AppColors.seekPrimary
                                    : AppColors.muted)
                                .withValues(alpha: 0.12),
                            borderRadius: AppRadius.pill,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_openingChat)
                                SizedBox(
                                  width: 14.r,
                                  height: 14.r,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.seekPrimary,
                                  ),
                                )
                              else
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedMessage02,
                                  color: application.job.chatEnabled
                                      ? AppColors.seekPrimary
                                      : AppColors.muted,
                                  size: 14.r,
                                ),
                              SizedBox(width: 4.w),
                              Text(
                                context.l10n.messageAction,
                                style: AppText.label.copyWith(
                                  color: application.job.chatEnabled
                                      ? AppColors.seekPrimary
                                      : AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 12.w,
                      runSpacing: 8.h,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (employmentType.isNotEmpty)
                          _MetaItem(
                            icon: HugeIcons.strokeRoundedBriefcase01,
                            label: employmentType,
                          ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatAppliedDate(),
                        style: AppText.small.copyWith(color: AppColors.muted),
                      ),
                      if (salary.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          salary,
                          textAlign: TextAlign.right,
                          style: AppText.bodyBold.copyWith(
                            color: AppColors.text,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ],
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

class _CompanyAvatar extends StatelessWidget {
  final String name;
  final String? logoUrl;

  const _CompanyAvatar({required this.name, this.logoUrl});

  @override
  Widget build(BuildContext context) {
    final hasLogo = (logoUrl ?? '').trim().isNotEmpty;
    return Container(
      width: 48.r,
      height: 48.r,
      decoration: BoxDecoration(
        color: hasLogo ? AppColors.surface : AppColors.seekSurface,
        borderRadius: AppRadius.md,
        border: Border.all(
          color: hasLogo ? AppColors.border : Colors.transparent,
        ),
      ),
      alignment: Alignment.center,
      child: hasLogo
          ? Padding(
              padding: EdgeInsets.all(6.r),
              child: ClipRRect(
                borderRadius: AppRadius.sm,
                child: UJobImage(
                  path: logoUrl!,
                  width: 36.r,
                  height: 36.r,
                  fit: BoxFit.contain,
                  errorWidget: _CompanyAvatarFallback(),
                ),
              ),
            )
          : const _CompanyAvatarFallback(),
    );
  }
}

class _CompanyAvatarFallback extends StatelessWidget {
  const _CompanyAvatarFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.r,
      height: 48.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.seekSurface,
        borderRadius: AppRadius.md,
      ),
      child: HugeIcon(
        icon: HugeIcons.strokeRoundedBuilding03,
        color: AppColors.seekPrimary,
        size: 24.r,
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String label;

  const _MetaItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        HugeIcon(
          icon: icon,
          color: AppColors.muted,
          size: 14.r,
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: AppText.small.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }
}
