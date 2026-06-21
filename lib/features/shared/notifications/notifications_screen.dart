import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ujob_app_bar.dart';

class _Notif {
  final int id;
  final String title;
  final String? body;
  final String type; // 'application', 'job', 'message', 'system'
  bool isRead;
  final DateTime createdAt;

  _Notif({
    required this.id,
    required this.title,
    this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });
}

final _notifsProvider = FutureProvider.autoDispose<List<_Notif>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return [
    _Notif(
      id: 1, 
      title: 'Application Viewed', 
      body: 'Your application was viewed by nexovia solutions', 
      type: 'application', 
      isRead: false, 
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    _Notif(
      id: 2, 
      title: 'New Message', 
      body: 'You have a new message regarding your application', 
      type: 'message', 
      isRead: true, 
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    _Notif(
      id: 3, 
      title: 'System Update', 
      body: 'We have updated our terms of service', 
      type: 'system', 
      isRead: true, 
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];
});

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsState();
}

class _NotificationsState extends ConsumerState<NotificationsScreen> {
  String _filter = 'all';

  static const _tabs   = ['all', 'application', 'message', 'system'];
  static const _labels = ['All', 'Applications', 'Messages', 'System'];

  Color _borderColor(String type) => switch (type) {
        'application' => Colors.blue,
        'job'         => Colors.green,
        'message'     => AppColors.primary,
        _             => Colors.orange,
      };

  dynamic _iconFor(String type) => switch (type) {
        'application' => HugeIcons.strokeRoundedNote01,
        'job'         => HugeIcons.strokeRoundedBriefcase02,
        'message'     => HugeIcons.strokeRoundedMessage01,
        _             => HugeIcons.strokeRoundedNotification01,
      };

  @override
  Widget build(BuildContext context) {
    final asyncNotifs = ref.watch(_notifsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: UJobAppBar(
        title: 'Notifications',
        showBack: true,
        rightWidget: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedCheckmarkBadge01, color: AppColors.muted, size: 24.r),
            tooltip: 'Mark all as read',
            onPressed: () {},
          ),
        ]),
      ),
      body: Column(
        children: [
          _buildTabs(),
          Expanded(
            child: asyncNotifs.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (err, _) => Center(child: Text('Error: $err', style: AppText.body.copyWith(color: AppColors.error))),
              data: (notifs) {
                final filtered = _filter == 'all' ? notifs : notifs.where((n) => n.type == _filter).toList();
                
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HugeIcon(icon: HugeIcons.strokeRoundedNotification02, color: AppColors.borderLight, size: 64.r),
                        SizedBox(height: 16.h),
                        Text('No notifications', style: AppText.heading3),
                        SizedBox(height: 8.h),
                        Text('You\'re all caught up!', style: AppText.body.copyWith(color: AppColors.muted)),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => ref.refresh(_notifsProvider.future),
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (ctx, i) => _NotifCard(
                      notif: filtered[i],
                      icon: _iconFor(filtered[i].type),
                      borderColor: _borderColor(filtered[i].type),
                      onTap: () {},
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final val = _tabs[i];
          final lbl = _labels[i];
          final active = _filter == val;
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: InkWell(
              onTap: () => setState(() => _filter = val),
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: active ? AppColors.primary : AppColors.borderLight,
                  ),
                ),
                child: Text(
                  lbl,
                  style: AppText.bodyBold.copyWith(
                    color: active ? Colors.white : AppColors.text,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final _Notif notif;
  final dynamic icon;
  final Color borderColor;
  final VoidCallback onTap;

  const _NotifCard({
    required this.notif,
    required this.icon,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: notif.isRead ? AppColors.surface : AppColors.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: notif.isRead ? AppColors.borderLight : borderColor.withValues(alpha: 0.5)),
          boxShadow: notif.isRead ? null : [
            BoxShadow(
              color: borderColor.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
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
                        style: AppText.small.copyWith(color: AppColors.muted, fontSize: 11.sp),
                      ),
                      if (!notif.isRead)
                        Container(
                          width: 8.r,
                          height: 8.r,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(notif.title, style: AppText.bodyBold.copyWith(color: AppColors.text)),
                  if (notif.body != null) ...[
                    SizedBox(height: 4.h),
                    Text(notif.body!, style: AppText.small.copyWith(color: AppColors.muted)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
