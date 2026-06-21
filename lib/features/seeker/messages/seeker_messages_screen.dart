import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ujob_avatar.dart';
import '../../../core/widgets/ujob_empty.dart';
import '../../../core/widgets/ujob_error.dart';
import '../../../core/widgets/ujob_loading.dart';
import '../../../core/widgets/ujob_app_bar.dart';
import '../../../core/widgets/ujob_text_field.dart';
import '../../../core/widgets/ujob_checkbox.dart';
import '../../../core/widgets/ujob_alert_dialog.dart';
import '../../shared/chat/conversation_provider.dart';

class SeekerMessagesScreen extends ConsumerStatefulWidget {
  const SeekerMessagesScreen({super.key});

  @override
  ConsumerState<SeekerMessagesScreen> createState() => _SeekerMessagesState();
}

class _SeekerMessagesState extends ConsumerState<SeekerMessagesScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  bool _isSelectionMode = false;
  bool _isSearching = false;
  final Set<String> _selectedIds = {};

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) _selectedIds.clear();
      _isSearching = false; // Hide search when selecting
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
        title: 'Delete Conversations',
        description: 'Are you sure you want to delete ${_selectedIds.length} conversation(s)? This action cannot be undone.',
        cancelText: 'Cancel',
        confirmText: 'Delete',
        onConfirm: () {
          ref.read(conversationsProvider.notifier).deleteConversations(_selectedIds.toList());
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
              title: Text('Search Messages', style: AppText.bodyBold),
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _isSearching = true);
              },
            ),
            ListTile(
              leading: HugeIcon(icon: HugeIcons.strokeRoundedTaskDone01, color: AppColors.text, size: 24.r),
              title: Text('Select Messages', style: AppText.bodyBold),
              onTap: () {
                Navigator.pop(ctx);
                _toggleSelectionMode();
              },
            ),
            ListTile(
              leading: HugeIcon(icon: HugeIcons.strokeRoundedMailOpen01, color: AppColors.primary, size: 24.r),
              title: Text('Mark All as Read', style: AppText.bodyBold.copyWith(color: AppColors.primary)),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(conversationsProvider.notifier).markAllAsRead();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(conversationsProvider);

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
              title: 'Messages',
              showBack: false,
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
                      hint: context.l10n.searchConversations,
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
          Expanded(
            child: async.when(
              loading: () => const UJobLoading(count: 5),
              error: (e, _) => UJobError(
                message: 'Failed to load messages',
                onRetry: () => ref.refresh(conversationsProvider),
              ),
              data: (convs) {
                var list = convs;
                if (_query.isNotEmpty) {
                  list = list.where((c) => c.otherName.toLowerCase().contains(_query)).toList();
                }

                if (list.isEmpty) {
                  return UJobEmpty(
                    title: 'No messages',
                    subtitle: 'Try changing your search or start a conversation.',
                    icon: HugeIcons.strokeRoundedBubbleChat,
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
                          final conv = list[i];
                          final isSelected = _selectedIds.contains(conv.id);

                          return _ConvTile(
                            conv: conv,
                            isSelectionMode: _isSelectionMode,
                            isSelected: isSelected,
                            onTap: () {
                              if (_isSelectionMode) {
                                setState(() {
                                  isSelected ? _selectedIds.remove(conv.id) : _selectedIds.add(conv.id);
                                });
                              } else {
                                ref.read(conversationsProvider.notifier).markAsRead(conv.id);
                                context.push(
                                  '/conversations/${conv.id}',
                                  extra: {
                                    'otherId': conv.otherId,
                                    'name': conv.otherName,
                                    'initials': conv.otherInitials,
                                    'avatar': conv.otherAvatar,
                                    'jobTitle': conv.jobTitle,
                                  },
                                );
                              }
                            },
                            onLongPress: () {
                              if (!_isSelectionMode) {
                                _showSingleMessageOptions(context, ref, conv);
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

  void _showSingleMessageOptions(BuildContext context, WidgetRef ref, Conversation conv) {
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
                Text('Message Options', style: AppText.heading3),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: HugeIcon(icon: HugeIcons.strokeRoundedCancel01, color: AppColors.text, size: 24.r),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            ListTile(
              leading: HugeIcon(icon: HugeIcons.strokeRoundedDelete02, color: AppColors.error, size: 24.r),
              title: Text('Delete Conversation', style: AppText.bodyBold.copyWith(color: AppColors.error)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDeleteSingle(ref, conv);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteSingle(WidgetRef ref, Conversation conv) {
    showDialog(
      context: context,
      builder: (ctx) => UJobAlertDialog(
        icon: HugeIcon(icon: HugeIcons.strokeRoundedDelete02, color: AppColors.error, size: 32.r),
        iconBgColor: AppColors.error,
        confirmColor: AppColors.error,
        title: 'Delete Conversation',
        description: 'Are you sure you want to delete your conversation with ${conv.otherName}? This cannot be undone.',
        cancelText: 'Cancel',
        confirmText: 'Delete',
        onConfirm: () {
          ref.read(conversationsProvider.notifier).deleteConversation(conv.id);
          Navigator.pop(ctx);
        },
      ),
    );
  }
}

class _ConvTile extends StatelessWidget {
  final Conversation conv;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ConvTile({
    required this.conv,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : AppColors.surface,
        borderRadius: AppRadius.xl,
        boxShadow: AppShadow.card(),
        border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight),
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
              children: [
                if (isSelectionMode) ...[
                  UJobCheckbox(value: isSelected, onChanged: (_) => onTap()),
                  SizedBox(width: 12.w),
                ],
                Stack(
                  children: [
                    UJobAvatar(
                      imageUrl: conv.otherAvatar,
                      initials: conv.otherInitials ?? conv.otherName[0],
                      size: 56.r,
                    ),
                    if (conv.otherOnline)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 14.r,
                          height: 14.r,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.surface, width: 2.r),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(conv.otherName, style: AppText.bodyBold.copyWith(color: AppColors.text2)),
                      if (conv.jobTitle != null) ...[
                        SizedBox(height: 2.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 1.h),
                              child: HugeIcon(icon: HugeIcons.strokeRoundedBriefcase02, size: 12.r, color: AppColors.primary),
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                conv.jobTitle!,
                                style: AppText.caption.copyWith(color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      ],
                      SizedBox(height: 4.h),
                      Text(
                        conv.lastMessage ?? 'No messages yet',
                        style: AppText.small.copyWith(
                          color: conv.unreadCount > 0 ? AppColors.text : AppColors.muted,
                          fontWeight: conv.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (conv.applicationStatus != null) ...[
                      _buildStatusChip(conv.applicationStatus!),
                      SizedBox(height: 6.h),
                    ],
                    if (conv.lastAt != null)
                      Text(
                        timeago.format(conv.lastAt!, allowFromNow: true),
                        style: AppText.caption.copyWith(color: AppColors.muted2),
                      ),
                    if (conv.unreadCount > 0 && !isSelectionMode) ...[
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: const BoxDecoration(
                          color: AppColors.empPrimary,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Center(
                          child: Text(
                            conv.unreadCount > 9 ? '9+' : conv.unreadCount.toString(),
                            style: AppText.caption.copyWith(
                              color: AppColors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ApplicationStatus status) {
    Color color;
    dynamic icon;
    String text;
    switch (status) {

      case ApplicationStatus.applied:
        color = AppColors.muted2;
        icon = HugeIcons.strokeRoundedTask01;
        text = 'Applied';
        break;
      case ApplicationStatus.offered:
        color = AppColors.primary;
        icon = HugeIcons.strokeRoundedTaskDone01;
        text = 'Offered';
        break;
      case ApplicationStatus.pending:
        color = AppColors.muted2;
        icon = HugeIcons.strokeRoundedTime04;
        text = 'Pending';
        break;
      case ApplicationStatus.shortlisted:
        color = AppColors.warning;
        icon = HugeIcons.strokeRoundedStar;
        text = 'Shortlisted';
        break;
      case ApplicationStatus.interviewing:
        color = const Color(0xFF9C27B0); // Purple
        icon = HugeIcons.strokeRoundedVideo02;
        text = 'Interviewing';
        break;
      case ApplicationStatus.hired:
        color = AppColors.success;
        icon = HugeIcons.strokeRoundedCheckmarkBadge01;
        text = 'Hired';
        break;
      case ApplicationStatus.rejected:
        color = AppColors.error;
        icon = HugeIcons.strokeRoundedCancel01;
        text = 'Rejected';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(icon: icon, size: 10.r, color: color),
          SizedBox(width: 4.w),
          Text(text, style: AppText.caption.copyWith(color: color, fontSize: 10.sp, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
