import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ujob_app_bar.dart';
import '../../../core/widgets/ujob_checkbox.dart';
import '../../../core/widgets/ujob_empty.dart';
import '../../../core/widgets/ujob_alert_dialog.dart';
import '../../../core/widgets/ujob_pill_tab_bar.dart';
import '../../../core/providers/role_provider.dart';

class Notif {
  final String id;
  final String title;
  final String? body;
  final String type; // 'application', 'job', 'message', 'system'
  final bool isRead;
  final DateTime createdAt;

  const Notif({
    required this.id,
    required this.title,
    this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  Notif copyWith({bool? isRead}) {
    return Notif(
      id: id,
      title: title,
      body: body,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}

final _empMock = [
  Notif(
    id: 'e1',
    title: 'New Candidate Applied',
    body: 'Michael Scott applied for Regional Manager.',
    type: 'application',
    isRead: false,
    createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
  ),
  Notif(
    id: 'e2',
    title: 'Application Withdrawn',
    body: 'Dwight Schrute withdrew his application.',
    type: 'application',
    isRead: false,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  Notif(
    id: 'e3',
    title: 'New Message',
    body: 'Jim Halpert sent you a message.',
    type: 'message',
    isRead: true,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  Notif(
    id: 'e4',
    title: 'System Update',
    body: 'We have updated our terms of service.',
    type: 'system',
    isRead: true,
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
];

final _seekerMock = [
  Notif(
    id: 's1',
    title: 'Application Viewed',
    body: 'Your application was viewed by Google.',
    type: 'application',
    isRead: false,
    createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
  ),
  Notif(
    id: 's2',
    title: 'New Message',
    body: 'You have a new message from nexovia solutions.',
    type: 'message',
    isRead: false,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  Notif(
    id: 's3',
    title: 'Job Match',
    body: 'A new job matches your profile: Senior Flutter Dev.',
    type: 'job',
    isRead: true,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  Notif(
    id: 's4',
    title: 'System Update',
    body: 'We have updated our terms of service.',
    type: 'system',
    isRead: true,
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
];

class NotifsNotifier extends Notifier<List<Notif>> {
  @override
  List<Notif> build() {
    final role = ref.watch(activeRoleProvider);
    return role == 'employer' ? List.from(_empMock) : List.from(_seekerMock);
  }

  void markAllRead() {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
  }

  void markAsRead(String id) {
    state = state
        .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
        .toList();
  }

  void toggleReadStatus(String id) {
    state = state
        .map((n) => n.id == id ? n.copyWith(isRead: !n.isRead) : n)
        .toList();
  }

  void deleteNotifications(List<String> ids) {
    state = state.where((n) => !ids.contains(n.id)).toList();
  }
}

final notifsProvider = NotifierProvider<NotifsNotifier, List<Notif>>(
  () => NotifsNotifier(),
);

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsState();
}

class _NotificationsState extends ConsumerState<NotificationsScreen> {
  late final PageController _pageController;
  final _searchCtrl = TextEditingController();
  int _selectedTabIndex = 0;
  bool _isSelectionMode = false;
  bool _isSearching = false;
  final Set<String> _selectedIds = {};
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

  static const _tabs = ['all', 'unread', 'application', 'message', 'system'];
  static const _labels = [
    'All',
    'Unread',
    'Applications',
    'Messages',
    'System',
  ];

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedIds.clear();
    });
  }

  void _confirmDeleteSingle(WidgetRef ref, Notif n) {
    showDialog(
      context: context,
      builder: (ctx) => UJobAlertDialog(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedDelete02,
          color: AppColors.error,
          size: 32.r,
        ),
        iconBgColor: AppColors.error,
        confirmColor: AppColors.error,
        title: 'Delete Notification',
        description:
            'Are you sure you want to delete this notification? This action cannot be undone.',
        cancelText: 'Cancel',
        confirmText: 'Delete',
        onConfirm: () {
          ref.read(notifsProvider.notifier).deleteNotifications([n.id]);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _confirmDeleteSelected(WidgetRef ref, Color primaryColor) {
    showDialog(
      context: context,
      builder: (ctx) => UJobAlertDialog(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedDelete02,
          color: AppColors.error,
          size: 24.r,
        ),
        title: 'Delete Notifications',
        description:
            'Are you sure you want to delete ${_selectedIds.length} notification(s)? This action cannot be undone.',
        cancelText: 'Cancel',
        confirmText: 'Delete',
        onConfirm: () {
          ref
              .read(notifsProvider.notifier)
              .deleteNotifications(_selectedIds.toList());
          setState(() {
            _selectedIds.clear();
            _isSelectionMode = false;
          });
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showSingleNotifOptions(BuildContext context, WidgetRef ref, Notif n) {
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
                Text('Notification Options', style: AppText.heading3),
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
                icon: n.isRead
                    ? HugeIcons.strokeRoundedMail02
                    : HugeIcons.strokeRoundedMailOpen01,
                color: AppColors.text,
                size: 24.r,
              ),
              title: Text(
                n.isRead ? 'Mark as Unread' : 'Mark as Read',
                style: AppText.bodyBold,
              ),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(notifsProvider.notifier).toggleReadStatus(n.id);
              },
            ),
            ListTile(
              leading: HugeIcon(
                icon: HugeIcons.strokeRoundedDelete02,
                color: AppColors.error,
                size: 24.r,
              ),
              title: Text(
                'Delete Notification',
                style: AppText.bodyBold.copyWith(color: AppColors.error),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDeleteSingle(ref, n);
              },
            ),
          ],
        ),
      ),
    );
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
                icon: HugeIcons.strokeRoundedTaskDone01,
                color: AppColors.text,
                size: 24.r,
              ),
              title: Text('Select Notifications', style: AppText.bodyBold),
              onTap: () {
                Navigator.pop(ctx);
                _toggleSelectionMode();
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
                ref.read(notifsProvider.notifier).markAllRead();
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _borderColor(String type, Color primaryColor) => switch (type) {
    'application' => Colors.blue,
    'job' => Colors.green,
    'message' => primaryColor,
    _ => Colors.orange,
  };

  dynamic _iconFor(String type) => switch (type) {
    'application' => HugeIcons.strokeRoundedNote01,
    'job' => HugeIcons.strokeRoundedBriefcase02,
    'message' => HugeIcons.strokeRoundedMessage01,
    _ => HugeIcons.strokeRoundedNotification01,
  };

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(activeRoleProvider);
    final primaryColor = role == 'employer'
        ? AppColors.primary
        : AppColors.seekPrimary;

    final notifs = ref.watch(notifsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _isSelectionMode
          ? AppBar(
              backgroundColor: AppColors.surface,
              elevation: 0,
              leadingWidth: 80.w,
              leading: TextButton(
                onPressed: _toggleSelectionMode,
                child: Text(
                  'Cancel',
                  style: AppText.bodyBold.copyWith(color: AppColors.muted),
                ),
              ),
              title: Text(
                '${_selectedIds.length} Selected',
                style: AppText.heading3,
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  onPressed: _selectedIds.isEmpty
                      ? null
                      : () => _confirmDeleteSelected(ref, primaryColor),
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedDelete02,
                    color: _selectedIds.isEmpty
                        ? AppColors.border
                        : AppColors.error,
                    size: 24.r,
                  ),
                ),
              ],
            )
          : UJobAppBar(
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
          if (!_isSelectionMode) _buildTabs(),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (idx) {
                setState(() => _selectedTabIndex = idx);
              },
              itemCount: _tabs.length,
              itemBuilder: (context, pageIndex) {
                final filter = _tabs[pageIndex];
                var filtered = notifs;
                if (filter == 'unread') {
                  filtered = filtered.where((n) => !n.isRead).toList();
                } else if (filter != 'all') {
                  filtered = filtered.where((n) => n.type == filter).toList();
                }
                if (_query.isNotEmpty) {
                  filtered = filtered
                      .where(
                        (n) =>
                            n.title.toLowerCase().contains(
                              _query.toLowerCase(),
                            ) ||
                            (n.body ?? '').toLowerCase().contains(
                              _query.toLowerCase(),
                            ),
                      )
                      .toList();
                }

                return Column(
                  children: [
                    if (_isSelectionMode)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 8.h,
                        ),
                        child: Row(
                          children: [
                            UJobCheckbox(
                              value:
                                  _selectedIds.length == filtered.length &&
                                  filtered.isNotEmpty,
                              onChanged: (v) {
                                setState(() {
                                  if (v)
                                    _selectedIds.addAll(
                                      filtered.map((n) => n.id),
                                    );
                                  else
                                    _selectedIds.clear();
                                });
                              },
                              label: 'Select All',
                            ),
                          ],
                        ),
                      ),
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
                              separatorBuilder: (_, __) =>
                                  SizedBox(height: 12.h),
                              itemBuilder: (ctx, i) {
                                final n = filtered[i];
                                final isSelected = _selectedIds.contains(n.id);

                                final card = _NotifCard(
                                  notif: n,
                                  icon: _iconFor(n.type),
                                  borderColor: _borderColor(
                                    n.type,
                                    primaryColor,
                                  ),
                                  primaryColor: primaryColor,
                                  isSelectionMode: _isSelectionMode,
                                  isSelected: isSelected,
                                  onTap: () {
                                    if (_isSelectionMode) {
                                      setState(() {
                                        isSelected
                                            ? _selectedIds.remove(n.id)
                                            : _selectedIds.add(n.id);
                                      });
                                    } else {
                                      ref
                                          .read(notifsProvider.notifier)
                                          .markAsRead(n.id);

                                      final isEmployer =
                                          ref.read(activeRoleProvider) ==
                                          'employer';
                                      if (n.type == 'message') {
                                        if (isEmployer) {
                                          context.push(
                                            '/conversations/1',
                                            extra: {'name': 'Jim'},
                                          );
                                        } else {
                                          context.push(
                                            '/conversations/1',
                                            extra: {
                                              'name': 'Nexovia Solutions',
                                            },
                                          );
                                        }
                                      } else if (n.type == 'job') {
                                        if (isEmployer) {
                                          context.push('/employer/jobs/1');
                                        } else {
                                          context.push('/seeker/jobs/1');
                                        }
                                      } else if (n.type == 'application') {
                                        if (isEmployer) {
                                          context.push('/employer/applicants');
                                        } else {
                                          context.push('/seeker/applications');
                                        }
                                      }
                                    }
                                  },
                                  onLongPress: () {
                                    if (!_isSelectionMode)
                                      _showSingleNotifOptions(context, ref, n);
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
        tabs: _labels,
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
  final Notif notif;
  final dynamic icon;
  final Color borderColor;
  final Color primaryColor;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _NotifCard({
    required this.notif,
    required this.icon,
    required this.borderColor,
    required this.primaryColor,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? primaryColor.withValues(alpha: 0.05)
            : (notif.isRead
                  ? AppColors.surface
                  : AppColors.surface.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isSelected
              ? primaryColor
              : (notif.isRead
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
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isSelectionMode) ...[
                  Padding(
                    padding: EdgeInsets.only(right: 12.w, top: 4.h),
                    child: UJobCheckbox(
                      value: isSelected,
                      onChanged: (_) => onTap(),
                    ),
                  ),
                ],
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
                      if (notif.body != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          notif.body!,
                          style: AppText.small.copyWith(color: AppColors.text2),
                        ),
                      ],
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
