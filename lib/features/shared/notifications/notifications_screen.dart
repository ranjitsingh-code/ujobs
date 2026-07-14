import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/l10n_extensions.dart';
import '../../../core/widgets/ujob_app_bar.dart';
import '../../../core/widgets/ujob_empty.dart';
import '../../../core/widgets/ujob_pill_tab_bar.dart';
import '../../../core/providers/role_provider.dart';

import '../../../core/models/notification.dart';
import 'notifications_provider.dart';
import '../../../core/providers/feature_flags_provider.dart';
import '../../../core/services/notification_navigation.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsState();
}

class _NotificationsState extends ConsumerState<NotificationsScreen> {
  late final PageController _pageController;
  final _searchCtrl = TextEditingController();
  int _selectedTabIndex = 0;
  bool _isSearching = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<String> get _currentTabs {
    final featuresAsync = ref.watch(featureFlagsProvider);
    final chatEnabled = featuresAsync.valueOrNull?.chat ?? false;
    return ['all', 'unread', 'application', if (chatEnabled) 'message', 'system'];
  }

  List<String> get _currentLabels {
    final featuresAsync = ref.watch(featureFlagsProvider);
    final chatEnabled = featuresAsync.valueOrNull?.chat ?? false;
    return ['All', 'Unread', 'Applications', if (chatEnabled) context.l10n.messages, 'System'];
  }


  void _showMoreOptionsSheet(
    BuildContext context,
    WidgetRef ref,
    Color primaryColor,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 40.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Options', style: AppText.heading3),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedCancel01,
                    color: AppColors.text,
                    size: 24.r,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            ListTile(
              leading: HugeIcon(
                icon: HugeIcons.strokeRoundedSearch01,
                color: AppColors.text,
                size: 24.r,
              ),
              title: Text('Search Notifications', style: AppText.bodyBold),
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _isSearching = true);
              },
            ),

            ListTile(
              leading: HugeIcon(
                icon: HugeIcons.strokeRoundedMailOpen01,
                color: primaryColor,
                size: 24.r,
              ),
              title: Text(
                'Mark all as read',
                style: AppText.bodyBold.copyWith(color: primaryColor),
              ),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(notificationsProvider.notifier).markAllRead();
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _borderColor(String type, Color primaryColor) => switch (type) {
    'application' || 'application_submitted' || 'stage_change' => Colors.blue,
    'job' || 'job_approved' || 'new_matching_job' => Colors.green,
    'message' => primaryColor,
    'new_company_registered' => Colors.purple,
    _ => Colors.orange,
  };

  dynamic _iconFor(String type) => switch (type) {
    'application' || 'new_application' || 'application_submitted' || 'stage_change' => HugeIcons.strokeRoundedNote01,
    'job' || 'job_approved' || 'new_matching_job' => HugeIcons.strokeRoundedBriefcase02,
    'message' => HugeIcons.strokeRoundedMessage01,
    'new_company_registered' => HugeIcons.strokeRoundedBuilding02,
    _ => HugeIcons.strokeRoundedNotification01,
  };

  @override
  Widget build(BuildContext context) {

    final role = ref.watch(activeRoleProvider);
    final primaryColor = role == 'employer'
        ? AppColors.primary
        : AppColors.seekPrimary;

    final notifsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: UJobAppBar(
              title: 'Notifications',
              showBack: true,
              rightWidget: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedMoreVerticalCircle01,
                      color: AppColors.muted,
                      size: 24.r,
                    ),
                    onPressed: () =>
                        _showMoreOptionsSheet(context, ref, primaryColor),
                  ),
                ],
              ),
            ),
      body: Column(
        children: [
          if (_isSearching) _buildSearchBar(),
          _buildTabs(),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (idx) {
                setState(() => _selectedTabIndex = idx);
              },
              itemCount: _currentTabs.length,
              itemBuilder: (context, pageIndex) {
                final filter = _currentTabs[pageIndex];
                var filtered = notifsAsync.valueOrNull?.notifications ?? [];
                if (filter == 'unread') {
                  filtered = filtered.where((n) => !n.isRead).toList();
                } else if (filter == 'application') {
                  filtered = filtered.where((n) => n.type == 'new_application' || n.type == 'application' || n.type == 'application_submitted' || n.type == 'stage_change').toList();
                } else if (filter == 'message') {
                  filtered = filtered.where((n) => n.type == 'message').toList();
                } else if (filter == 'system') {
                  filtered = filtered.where((n) => n.type != 'new_application' && n.type != 'application' && n.type != 'application_submitted' && n.type != 'stage_change' && n.type != 'message').toList();
                }
                if (_query.isNotEmpty) {
                  filtered = filtered
                      .where(
                        (n) =>
                            n.title.toLowerCase().contains(
                              _query.toLowerCase(),
                            ) ||
                            n.body.toLowerCase().contains(
                              _query.toLowerCase(),
                            ),
                      )
                      .toList();
                }

                return Column(
                  children: [
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: UJobEmpty(
                                title: 'No notifications',
                                subtitle: 'You\'re all caught up!',
                                icon: HugeIcons.strokeRoundedNotification02,
                              ),
                            )
                          : ListView.separated(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 16.h,
                              ),
                              itemCount: filtered.length,
                              separatorBuilder: (_, _) =>
                                  SizedBox(height: 12.h),
                              itemBuilder: (ctx, i) {
                                final n = filtered[i];
                                final card = _NotifCard(
                                  notif: n,
                                  icon: _iconFor(n.type),
                                  borderColor: _borderColor(
                                    n.type,
                                    primaryColor,
                                  ),
                                  primaryColor: primaryColor,
                                  onTap: () {
                                    ref.read(notificationsProvider.notifier).markAsRead(n.id);

                                    final bool isActionable = n.type == 'message' ||
                                                              n.type == 'job' || 
                                                              n.type == 'job_approved' || 
                                                              n.type == 'application' || 
                                                              n.type == 'new_application' ||
                                                              n.type == 'application_submitted' ||
                                                              n.type == 'stage_change' ||
                                                              n.type == 'new_matching_job';

                                    showDialog(
                                      context: context,
                                      builder: (ctx) => Dialog(
                                        backgroundColor: AppColors.surface,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                                        child: Padding(
                                          padding: EdgeInsets.all(24.r),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(16.r),
                                                decoration: BoxDecoration(
                                                  color: _borderColor(n.type, primaryColor).withValues(alpha: 0.1),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: HugeIcon(
                                                  icon: _iconFor(n.type),
                                                  color: _borderColor(n.type, primaryColor),
                                                  size: 32.r,
                                                ),
                                              ),
                                              SizedBox(height: 20.h),
                                              Text(n.title, style: AppText.heading3, textAlign: TextAlign.center),
                                              SizedBox(height: 12.h),
                                              Text(
                                                n.body,
                                                style: AppText.bodyMedium.copyWith(color: AppColors.muted),
                                                textAlign: TextAlign.center,
                                              ),
                                              SizedBox(height: 28.h),
                                              if (isActionable)
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: OutlinedButton(
                                                        onPressed: () => Navigator.pop(ctx),
                                                        style: OutlinedButton.styleFrom(
                                                          foregroundColor: AppColors.muted,
                                                          side: const BorderSide(color: AppColors.border),
                                                          padding: EdgeInsets.symmetric(vertical: 14.h),
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                                        ),
                                                        child: Text('Close', style: AppText.bodyBold),
                                                      ),
                                                    ),
                                                    SizedBox(width: 12.w),
                                                    Expanded(
                                                      child: ElevatedButton(
                                                        onPressed: () async {
                                                          Navigator.pop(ctx);
                                                          await handleNotificationTap({
                                                            ...?n.data,
                                                            'type': n.type,
                                                          });
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: primaryColor,
                                                          padding: EdgeInsets.symmetric(vertical: 14.h),
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                                        ),
                                                        child: Text('View', style: AppText.bodyBold.copyWith(color: Colors.white)),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              else
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: ElevatedButton(
                                                    onPressed: () => Navigator.pop(ctx),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: primaryColor,
                                                      padding: EdgeInsets.symmetric(vertical: 14.h),
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                                    ),
                                                    child: Text('Close', style: AppText.bodyBold.copyWith(color: Colors.white)),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },

                                );

                                return card;
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              onChanged: (v) => setState(() => _query = v),
              style: AppText.body,
              decoration: InputDecoration(
                hintText: 'Search notifications...',
                hintStyle: AppText.body.copyWith(color: AppColors.muted),
                filled: true,
                fillColor: AppColors.bg,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                prefixIcon: Padding(
                  padding: EdgeInsets.only(left: 12.w, right: 8.w),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedSearch01,
                    color: AppColors.muted,
                    size: 18.r,
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
                border: OutlineInputBorder(
                  borderRadius: AppRadius.md,
                  borderSide: BorderSide(color: AppColors.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.md,
                  borderSide: BorderSide(color: AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.md,
                  borderSide: BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          TextButton(
            onPressed: () => setState(() {
              _isSearching = false;
              _query = '';
              _searchCtrl.clear();
            }),
            child: Text(
              'Cancel',
              style: AppText.bodyBold.copyWith(color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 14.h),
      child: UJobPillTabBar(
        tabs: _currentLabels,
        selectedIndex: _selectedTabIndex,
        onTabSelected: (i) {
          setState(() => _selectedTabIndex = i);
          _pageController.animateToPage(
            i,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
          );
        },
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final AppNotification notif;
  final dynamic icon;
  final Color borderColor;
  final Color primaryColor;
  final VoidCallback onTap;

  const _NotifCard({
    required this.notif,
    required this.icon,
    required this.borderColor,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        color: (notif.isRead
                  ? AppColors.surface
                  : AppColors.surface.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: (notif.isRead
                    ? AppColors.borderLight
                    : borderColor.withValues(alpha: 0.5)),
        ),
        boxShadow: notif.isRead
            ? null
            : [
                BoxShadow(
                  color: borderColor.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: borderColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: HugeIcon(icon: icon, color: borderColor, size: 24.r),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            timeago.format(notif.createdAt),
                            style: AppText.small.copyWith(
                              color: AppColors.muted,
                              fontSize: 11.sp,
                            ),
                          ),
                          if (!notif.isRead)
                            Container(
                              width: 8.r,
                              height: 8.r,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        notif.title,
                        style: AppText.bodyBold.copyWith(color: AppColors.text),
                      ),
                        SizedBox(height: 4.h),
                        Text(
                          notif.body,
                          style: AppText.small.copyWith(color: AppColors.text2),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
