import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ujob_empty.dart';
import '../../../core/widgets/ujob_error.dart';
import '../../../core/widgets/ujob_loading.dart';
import '../../../core/widgets/ujob_app_bar.dart';
import '../../../core/widgets/ujob_text_field.dart';
import '../../../core/widgets/ujob_checkbox.dart';
import '../../../core/widgets/ujob_alert_dialog.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/ujob_pill_tab_bar.dart';
import '../../../core/utils/l10n_extensions.dart';
import 'package:go_router/go_router.dart';
import '../applicants/applicant_detail_screen.dart';
import '../../shared/chat/conversation_provider.dart';

class _Notif {
  final String id;
  final String title;
  final String? body;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final String? targetId;

  const _Notif({
    required this.id,
    required this.title,
    this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.targetId,
  });
}

class _EmpNotifsNotifier extends AutoDisposeNotifier<List<_Notif>> {
  @override
  List<_Notif> build() {
    return [
      _Notif(
        id: '1',
        title: 'New Message',
        body: 'Bob Smith sent you a message regarding the Software Engineer position.',
        type: 'messages',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        targetId: 'conv-a2',
      ),
      _Notif(
        id: '2',
        title: 'New Message',
        body: 'Charlie Brown sent you a message regarding the Website Developer position.',
        type: 'messages',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        targetId: 'conv-a3',
      ),
      _Notif(
        id: '3',
        title: 'New Candidate Applied',
        body: 'Bob Smith applied for Software Engineer.',
        type: 'application',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        targetId: 'a2',
      ),
      _Notif(
        id: '4',
        title: 'Job Approved',
        body: 'Your job posting for "Software Engineer" has been approved and is now live.',
        type: 'system',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        targetId: '1',
      ),
    ];
  }

  void markAllRead() {
    state = state.map((n) => _Notif(
      id: n.id,
      title: n.title,
      body: n.body,
      type: n.type,
      isRead: true,
      createdAt: n.createdAt,
      targetId: n.targetId,
    )).toList();
  }

  void markAsRead(String id) {
    state = state.map((n) {
      if (n.id == id) {
        return _Notif(
          id: n.id,
          title: n.title,
          body: n.body,
          type: n.type,
          isRead: true,
          createdAt: n.createdAt,
        );
      }
      return n;
    }).toList();
  }
  
  void deleteNotifications(List<String> ids) {
    state = state.where((n) => !ids.contains(n.id)).toList();
  }
}

final _empNotifsProvider = NotifierProvider.autoDispose<_EmpNotifsNotifier, List<_Notif>>(_EmpNotifsNotifier.new);

class EmployerNotificationsScreen extends ConsumerStatefulWidget {
  const EmployerNotificationsScreen({super.key});

  @override
  ConsumerState<EmployerNotificationsScreen> createState() => _EmpNotifsState();
}

class _EmpNotifsState extends ConsumerState<EmployerNotificationsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  int _selectedTabIndex = 0;

  bool _isSelectionMode = false;
  bool _isSearching = false;
  final Set<String> _selectedIds = {};

  static const _tabs   = ['all', 'unread', 'application', 'status', 'messages'];

  late final PageController _pageCtrl;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(initialPage: _selectedTabIndex);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) _selectedIds.clear();
      _isSearching = false;
    });
  }

  void _confirmDeleteSelected(WidgetRef ref) {
    if (_selectedIds.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => UJobAlertDialog(
        icon: HugeIcon(icon: HugeIcons.strokeRoundedDelete02, color: AppColors.error, size: 32.r),
        iconBgColor: AppColors.error,
        confirmColor: AppColors.error,
        title: 'Delete Notifications',
        description: 'Are you sure you want to delete ${_selectedIds.length} notification(s)? This action cannot be undone.',
        cancelText: 'Cancel',
        confirmText: 'Delete',
        onConfirm: () {
          ref.read(_empNotifsProvider.notifier).deleteNotifications(_selectedIds.toList());
          setState(() {
            _selectedIds.clear();
            _isSelectionMode = false;
          });
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showMoreOptionsSheet(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
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
                  icon: HugeIcon(icon: HugeIcons.strokeRoundedCancel01, color: AppColors.text, size: 24.r),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            ListTile(
              leading: HugeIcon(icon: HugeIcons.strokeRoundedSearch01, color: AppColors.text, size: 24.r),
              title: Text(l10n.searchNotifications, style: AppText.bodyBold),
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _isSearching = true);
              },
            ),
            ListTile(
              leading: HugeIcon(icon: HugeIcons.strokeRoundedTaskDone01, color: AppColors.text, size: 24.r),
              title: Text('Select Notifications', style: AppText.bodyBold),
              onTap: () {
                Navigator.pop(ctx);
                _toggleSelectionMode();
              },
            ),
            ListTile(
              leading: HugeIcon(icon: HugeIcons.strokeRoundedMailOpen01, color: AppColors.primary, size: 24.r),
              title: Text(l10n.markAllRead, style: AppText.bodyBold.copyWith(color: AppColors.primary)),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(_empNotifsProvider.notifier).markAllRead();
              },
            ),
          ],
        ),
      ),
    );
  }

    @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final notifs = ref.watch(_empNotifsProvider);
    final labels = [l10n.allTab, l10n.unreadTab, l10n.applicationsTab, l10n.statusTab, l10n.messages];

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _isSelectionMode
          ? AppBar(
              backgroundColor: AppColors.surface,
              elevation: 0,
              leadingWidth: 80.w,
              leading: TextButton(
                onPressed: _toggleSelectionMode,
                child: Text('Cancel', style: AppText.bodyBold.copyWith(color: AppColors.muted)),
              ),
              title: Text('${_selectedIds.length} Selected', style: AppText.heading3),
              centerTitle: true,
              actions: [
                IconButton(
                  onPressed: _selectedIds.isEmpty ? null : () => _confirmDeleteSelected(ref),
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedDelete02,
                    color: _selectedIds.isEmpty ? AppColors.border : AppColors.error,
                    size: 24.r,
                  ),
                ),
              ],
            )
          : UJobAppBar(
              title: l10n.notifications,
              rightWidget: IconButton(
                icon: HugeIcon(icon: HugeIcons.strokeRoundedMoreVerticalCircle01, color: AppColors.text, size: 24.r),
                onPressed: () => _showMoreOptionsSheet(context, ref),
              ),
            ),
      body: Column(
        children: [
          if (_isSearching && !_isSelectionMode)
            Container(
              color: AppColors.surface,
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
              child: Row(
                children: [
                  Expanded(
                    child: UJobTextField(
                      label: '',
                      hint: l10n.searchNotifications,
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _query = v.toLowerCase()),
                      prefix: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: HugeIcon(icon: HugeIcons.strokeRoundedSearch01, color: AppColors.muted2, size: 20.r),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isSearching = false;
                        _query = '';
                        _searchCtrl.clear();
                      });
                    },
                    child: Text('Cancel', style: AppText.bodyBold.copyWith(color: AppColors.muted)),
                  ),
                ],
              ),
            ),
          UJobPillTabBar(
            tabs: labels,
            selectedIndex: _selectedTabIndex,
            onTabSelected: (v) {
              setState(() => _selectedTabIndex = v);
              _pageCtrl.animateToPage(v, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
            },
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageCtrl,
              onPageChanged: (v) => setState(() => _selectedTabIndex = v),
              itemCount: _tabs.length,
              itemBuilder: (context, pageIndex) {
                var list = notifs.where((n) {
                  String filterStr = _tabs[pageIndex];
                  if (filterStr == 'unread' && n.isRead) return false;
                  if (filterStr != 'all' && filterStr != 'unread' && n.type != filterStr) return false;
                  if (_query.isNotEmpty) {
                    final t = n.title.toLowerCase();
                    final b = (n.body ?? '').toLowerCase();
                    if (!t.contains(_query) && !b.contains(_query)) return false;
                  }
                  return true;
                }).toList();
                
                if (list.isEmpty) {
                  return UJobEmpty(
                    title: l10n.nothingHereYet,
                    subtitle: l10n.notifiedWhenApply,
                    icon: HugeIcons.strokeRoundedNotification01,
                  );
                }

                return Column(
                  children: [
                    if (_isSelectionMode)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                        child: Row(
                          children: [
                            UJobCheckbox(
                              value: _selectedIds.length == list.length && list.isNotEmpty,
                              onChanged: (v) {
                                setState(() {
                                  if (v) {
                                    _selectedIds.addAll(list.map((c) => c.id));
                                  } else {
                                    _selectedIds.clear();
                                  }
                                });
                              },
                              label: context.l10n.selectAll,
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: ListView.separated(
                        padding: AppSpacing.pagePad,
                        itemCount: list.length,
                        separatorBuilder: (_, _) => SizedBox(height: 12.h),
                        itemBuilder: (_, i) {
                          final n = list[i];
                          final isSelected = _selectedIds.contains(n.id);

                          return _NotifTile(
                            n: n,
                            isSelectionMode: _isSelectionMode,
                            isSelected: isSelected,
                            onTap: () {
                              if (_isSelectionMode) {
                                setState(() {
                                  isSelected ? _selectedIds.remove(n.id) : _selectedIds.add(n.id);
                                });
                                return;
                              }
                              
                              ref.read(_empNotifsProvider.notifier).markAsRead(n.id);
                              
                              if (n.targetId != null) {
                                if (n.type == 'application' || n.type == 'status') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ApplicantDetailScreen(
                                        applicantId: n.targetId ?? '1',
                                      ),
                                    ),
                                  );
                                } else if (n.type == 'messages') {
                                  final convs = ref.read(conversationsProvider).valueOrNull ?? [];
                                  final conv = convs.where((c) => c.id == n.targetId).firstOrNull;
                                  
                                  context.push('/conversations/${n.targetId}', extra: {
                                    'name': conv?.otherName ?? n.body?.split(' sent you').first ?? 'Applicant',
                                    'initials': conv?.otherInitials,
                                    'avatar': conv?.otherAvatar,
                                    'otherId': conv?.otherId,
                                    'jobTitle': conv?.jobTitle,
                                  });
                                } else if (n.type == 'system') {
                                  context.push('/employer/jobs/${n.targetId}');
                                }
                              }
                            },
                            onLongPress: () {
                              if (!_isSelectionMode) {
                                _showSingleNotifOptions(context, ref, n);
                              }
                            },
                          );
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

  void _showSingleNotifOptions(BuildContext context, WidgetRef ref, _Notif n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
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
                  icon: HugeIcon(icon: HugeIcons.strokeRoundedCancel01, color: AppColors.text, size: 24.r),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            ListTile(
              leading: HugeIcon(icon: HugeIcons.strokeRoundedDelete02, color: AppColors.error, size: 24.r),
              title: Text('Delete Notification', style: AppText.bodyBold.copyWith(color: AppColors.error)),
              onTap: () {
                Navigator.pop(ctx); // Close the bottom sheet
                showDialog(
                  context: context,
                  builder: (dialogCtx) => UJobAlertDialog(
                    icon: HugeIcon(icon: HugeIcons.strokeRoundedDelete02, color: AppColors.error, size: 32.r),
                    iconBgColor: AppColors.error,
                    confirmColor: AppColors.error,
                    title: 'Delete Notification',
                    description: 'Are you sure you want to delete this notification? This action cannot be undone.',
                    cancelText: 'Cancel',
                    confirmText: 'Delete',
                    onConfirm: () {
                      Navigator.pop(dialogCtx);
                      ref.read(_empNotifsProvider.notifier).deleteNotifications([n.id]);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}


class _NotifTile extends StatelessWidget {
  final _Notif n;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _NotifTile({
    required this.n,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  Color get _iconColor => switch (n.type) {
    'application' => AppColors.primary,
    'status'      => AppColors.warning,
    'messages'    => AppColors.success,
    _             => AppColors.purple,
  };

  dynamic get _iconData => switch (n.type) {
    'application' => HugeIcons.strokeRoundedBriefcase02,
    'status'      => HugeIcons.strokeRoundedTaskDone01,
    'messages'    => HugeIcons.strokeRoundedBubbleChat,
    _             => HugeIcons.strokeRoundedNotification01,
  };

    String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays < 1 && now.day == date.day) {
      return timeago.format(date, allowFromNow: true);
    } else if (now.year == date.year) {
      return DateFormat('dd MMM').format(date);
    } else {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? AppColors.empPrimary.withValues(alpha: 0.05) : AppColors.surface,
        borderRadius: AppRadius.xl,
        boxShadow: AppShadow.card(),
        border: Border.all(color: isSelected ? AppColors.empPrimary : AppColors.borderLight),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.xl,
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isSelectionMode) ...[
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: UJobCheckbox(value: isSelected, onChanged: (_) => onTap()),
                  ),
                  SizedBox(width: 12.w),
                ],
                Container(
                  width: 48.r,
                  height: 48.r,
                  decoration: BoxDecoration(
                    color: _iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: HugeIcon(icon: _iconData, color: _iconColor, size: 24.r),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              n.title,
                              style: AppText.bodyBold.copyWith(
                                color: n.isRead ? AppColors.text : AppColors.text2,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            _formatDate(n.createdAt),
                            style: AppText.caption.copyWith(color: AppColors.muted2),
                          ),
                        ],
                      ),
                      if (n.body != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          n.body!,
                          style: AppText.small.copyWith(
                            color: n.isRead ? AppColors.muted : AppColors.text,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (!n.isRead && !isSelectionMode) ...[
                  SizedBox(width: 12.w),
                  Padding(
                    padding: EdgeInsets.only(top: 6.h),
                    child: Container(
                      width: 10.r,
                      height: 10.r,
                      decoration: const BoxDecoration(
                        color: AppColors.empPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
