import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/l10n_extensions.dart';
import '../../../core/widgets/ujob_avatar.dart';
import '../../../core/widgets/ujob_error.dart';
import '../../../core/widgets/ujob_loading.dart';
import 'conversation_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String otherName;
  final String? otherInitials;
  final String? otherAvatar;

  const ChatScreen({
    required this.conversationId,
    required this.otherName,
    this.otherInitials,
    this.otherAvatar,
    super.key,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _sending = false;

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await ref.read(dioClientProvider).dio.post(
        Ep.messages(widget.conversationId),
        data: {'body': text},
      );
      _msgCtrl.clear();
      ref.invalidate(chatMessagesProvider(widget.conversationId));
      await Future.delayed(const Duration(milliseconds: 300));
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final async = ref.watch(chatMessagesProvider(widget.conversationId));
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(children: [
          Stack(
            children: [
              UJobAvatar(
                imageUrl: widget.otherAvatar,
                initials: widget.otherInitials ?? widget.otherName[0],
                size: 36.r,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 10.r,
                  height: 10.r,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 1.5.r),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 10.w),
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(widget.otherName, style: AppText.titleSm.copyWith(color: AppColors.white)),
            Text(l10n.activeNow, style: AppText.caption.copyWith(color: AppColors.white.withValues(alpha: 0.7))),
          ]),
        ]),
        actions: [
          IconButton(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedMoreVertical, color: AppColors.white, size: 24.r),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: async.when(
            loading: () => const UJobLoading(count: 5),
            error: (e, _) => UJobError(
              message: l10n.failedLoadMessages,
              onRetry: () => ref.refresh(chatMessagesProvider(widget.conversationId)),
            ),
            data: (messages) {
              if (messages.isEmpty) {
                return Center(
                  child: Text(l10n.sayHello),
                );
              }
              return ListView.builder(
                controller: _scrollCtrl,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                itemCount: messages.length,
                itemBuilder: (_, i) {
                  final msg = messages[i];
                  final prevMsg = i > 0 ? messages[i - 1] : null;
                  final showDate = prevMsg == null ||
                      !_sameDay(prevMsg.sentAt, msg.sentAt);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (showDate) _DateDivider(date: msg.sentAt),
                      _MessageBubble(message: msg),
                    ],
                  );
                },
              );
            },
          ),
        ),
        _InputBar(
          controller: _msgCtrl,
          sending: _sending,
          onSend: _send,
        ),
      ]),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DateDivider extends StatelessWidget {
  final DateTime date;
  const _DateDivider({required this.date});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String label;
    if (_sameDay(date, now)) {
      label = 'Today';
    } else if (_sameDay(date, now.subtract(const Duration(days: 1)))) {
      label = 'Yesterday';
    } else {
      label = DateFormat('MMM d, yyyy').format(date);
    }
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(children: [
        const Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(label, style: AppText.caption.copyWith(color: AppColors.muted)),
        ),
        const Expanded(child: Divider()),
      ]),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;
    final time = DateFormat('HH:mm').format(message.sentAt);
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        child: Column(
          crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                gradient: isMine
                    ? const LinearGradient(
                        colors: [AppColors.primaryDark, AppColors.primaryAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isMine ? null : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: Radius.circular(isMine ? 16.r : 4.r),
                  bottomRight: Radius.circular(isMine ? 4.r : 16.r),
                ),
                boxShadow: AppShadow.card(),
              ),
              child: Text(
                message.body,
                style: AppText.body.copyWith(
                  color: isMine ? AppColors.white : AppColors.text,
                  height: 1.4,
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(time, style: AppText.caption.copyWith(color: AppColors.muted2)),
                if (isMine) ...[
                  SizedBox(width: 4.w),
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedTickDouble02,
                    size: 14.r,
                    color: message.isRead ? AppColors.primary : AppColors.muted2,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  const _InputBar({required this.controller, required this.sending, required this.onSend});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.borderLight)),
        ),
        child: SafeArea(
          top: false,
          child: Row(children: [
            IconButton(
              icon: HugeIcon(icon: HugeIcons.strokeRoundedAttachment01, color: AppColors.muted, size: 24.r),
              onPressed: () {},
            ),
            Expanded(
              child: TextField(
                controller: controller,
                textCapitalization: TextCapitalization.sentences,
                style: AppText.body,
                maxLines: 4,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: l10n.typeMessage,
                  hintStyle: AppText.body.copyWith(color: AppColors.muted2),
                  filled: true,
                  fillColor: AppColors.bg,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.xl2,
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: sending ? null : onSend,
              child: Container(
                width: 42.r,
                height: 42.r,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primaryAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: sending
                    ? Padding(
                        padding: EdgeInsets.all(12.r),
                        child: CircularProgressIndicator(strokeWidth: 2.r, color: AppColors.white),
                      )
                    : HugeIcon(icon: HugeIcons.strokeRoundedSent, color: AppColors.white, size: 18.r),
              ),
            ),
          ]),
        ),
      );
  }
}
