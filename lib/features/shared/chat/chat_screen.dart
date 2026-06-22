import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/l10n_extensions.dart';
import '../../../core/widgets/ujob_avatar.dart';
import '../../../core/widgets/ujob_error.dart';
import '../../../core/widgets/ujob_loading.dart';
import '../../../core/widgets/ujob_app_bar.dart';
import '../../../core/widgets/ujob_pdf_viewer.dart';
import '../../../core/widgets/ujob_pdf_viewer_screen.dart';
import '../../../core/widgets/ujob_snack_bar.dart';
import '../../../core/providers/role_provider.dart';
import '../../employer/applicants/applicant_detail_screen.dart';
import 'conversation_provider.dart';
import '../../../core/widgets/ujob_alert_dialog.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String otherId;
  final String otherName;
  final String? otherInitials;
  final String? otherAvatar;
  final String? otherLocation;
  final String? jobTitle;
  final String? applicationStatus;
  final bool isClosed;

  const ChatScreen({
    required this.conversationId,
    required this.otherId,
    required this.otherName,
    this.otherInitials,
    this.otherAvatar,
    this.otherLocation,
    this.jobTitle,
    this.applicationStatus,
    this.isClosed = false,
    super.key,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _sending = false;

  String? _stagedFileType;
  String? _stagedFilePath;
  String? _stagedFileName;

  late bool _isClosed;

  @override
  void initState() {
    super.initState();
    _isClosed = widget.isClosed;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(conversationsProvider.notifier)
            .markAsRead(widget.conversationId);
        ref
            .read(seekerConversationsProvider.notifier)
            .markAsRead(widget.conversationId);
      }
    });
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if ((text.isEmpty && _stagedFilePath == null) || _sending) return;
    setState(() => _sending = true);
    try {
      if (_stagedFilePath != null) {
        ref
            .read(chatMessagesProvider(widget.conversationId).notifier)
            .sendAttachment(
              type: _stagedFileType!,
              url: _stagedFilePath!,
              name: _stagedFileName!,
              body: text,
            );
      } else {
        ref
            .read(chatMessagesProvider(widget.conversationId).notifier)
            .send(text);
      }
      _msgCtrl.clear();
      setState(() {
        _stagedFilePath = null;
        _stagedFileType = null;
        _stagedFileName = null;
      });
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

  void _showUserDetailsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 40.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedCancel01,
                    color: AppColors.text,
                    size: 24.r,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              UJobAvatar(
                imageUrl: widget.otherAvatar,
                initials: widget.otherInitials ?? widget.otherName[0],
                size: 80.r,
              ),
              SizedBox(height: 16.h),
              Text(widget.otherName, style: AppText.heading3),
              SizedBox(height: 4.h),
              Text(
                'Active now',
                style: AppText.body.copyWith(color: AppColors.success),
              ),

              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  children: [
                    if (widget.jobTitle != null) ...[
                      Row(
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedBriefcase02,
                            size: 16.r,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              'Applied for: ${widget.jobTitle}',
                              style: AppText.bodyBold.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                    ],
                    Row(
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedMail01,
                          size: 16.r,
                          color: AppColors.muted,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            '${widget.otherName.toLowerCase().replaceAll(' ', '.')}@example.com',
                            style: AppText.body,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedCall02,
                          size: 16.r,
                          color: AppColors.muted,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text('+1 (555) 019-2834', style: AppText.body),
                        ),
                      ],
                    ),
                    if (widget.otherLocation != null) ...[
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedLocation01,
                            size: 16.r,
                            color: AppColors.muted,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              widget.otherLocation!,
                              style: AppText.body,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (widget.applicationStatus != null) ...[
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedInformationCircle,
                            size: 16.r,
                            color: AppColors.muted,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              'Status: ${widget.applicationStatus}',
                              style: AppText.body.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: 24.h),
              if (!_isClosed)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: HugeIcon(
                    icon: HugeIcons.strokeRoundedLockPassword,
                    color: AppColors.text,
                    size: 24.r,
                  ),
                  title: Text('Close Chat', style: AppText.bodyBold),
                  onTap: () {
                    Navigator.pop(context); // Close bottom sheet
                    showDialog(
                      context: context,
                      builder: (context) => UJobAlertDialog(
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedLockPassword,
                          color: AppColors.error,
                          size: 28.r,
                        ),
                        title: 'Close Chat',
                        description:
                            'Are you sure you want to close this chat? You will not be able to send or receive messages until you reopen it.',
                        confirmText: 'Close Chat',
                        onConfirm: () {
                          setState(() {
                            _isClosed = true;
                          });
                          Navigator.pop(context); // Close dialog
                        },
                      ),
                    );
                  },
                ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: HugeIcon(
                  icon: HugeIcons.strokeRoundedCancel01,
                  color: AppColors.error,
                  size: 24.r,
                ),
                title: Text(
                  'Block User',
                  style: AppText.bodyBold.copyWith(color: AppColors.error),
                ),
                onTap: () {
                  Navigator.pop(context); // Close bottom sheet
                  showDialog(
                    context: context,
                    builder: (context) => UJobAlertDialog(
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedUserBlock01,
                        color: AppColors.error,
                        size: 28.r,
                      ),
                      title: 'Block User',
                      description:
                          'Are you sure you want to block this user? They will no longer be able to message you or apply to your jobs.',
                      confirmText: 'Block User',
                      onConfirm: () {
                        // Implement block user logic here
                        Navigator.pop(context); // Close dialog
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final async = ref.watch(chatMessagesProvider(widget.conversationId));
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: UJobAppBar(
        title: '',
        customTitle: InkWell(
          onTap: () {
            final isEmployer = ref.read(activeRoleProvider.notifier).isEmployer;
            if (isEmployer) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ApplicantDetailScreen(applicantId: widget.otherId),
                ),
              );
            } else {
              _showUserDetailsSheet();
            }
          },
          borderRadius: BorderRadius.circular(8.r),
          child: Row(
            children: [
              SizedBox(width: 8.w),
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
                        border: Border.all(
                          color: AppColors.surface,
                          width: 1.5.r,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.otherName,
                      style: AppText.titleSm,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      l10n.activeNow,
                      style: AppText.caption.copyWith(color: AppColors.muted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        rightWidget: IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedMoreVertical,
            color: AppColors.text,
            size: 24.r,
          ),
          onPressed: _showUserDetailsSheet,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: async.when(
              loading: () => const UJobLoading(count: 5),
              error: (e, _) => UJobError(
                message: l10n.failedLoadMessages,
                onRetry: () =>
                    ref.refresh(chatMessagesProvider(widget.conversationId)),
              ),
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(child: Text(l10n.sayHello));
                }
                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (_, i) {
                    final msg = messages[i];
                    final prevMsg = i > 0 ? messages[i - 1] : null;
                    final showDate =
                        prevMsg == null ||
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
          if (_isClosed)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 24.h),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.borderLight)),
              ),
              child: SafeArea(
                top: false,
                child: Text(
                  'This chat has been closed.',
                  textAlign: TextAlign.center,
                  style: AppText.body.copyWith(color: AppColors.muted),
                ),
              ),
            )
          else
            _InputBar(
              controller: _msgCtrl,
              sending: _sending,
              onSend: _send,
              stagedFileType: _stagedFileType,
              stagedFilePath: _stagedFilePath,
              stagedFileName: _stagedFileName,
              onStageFile: (type, path, name) {
                setState(() {
                  _stagedFileType = type;
                  _stagedFilePath = path;
                  _stagedFileName = name;
                });
              },
              onRemoveStagedFile: () {
                setState(() {
                  _stagedFileType = null;
                  _stagedFilePath = null;
                  _stagedFileName = null;
                });
              },
            ),
        ],
      ),
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
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Text(
              label,
              style: AppText.caption.copyWith(color: AppColors.muted),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
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

    Widget contentWidget;

    if (message.attachmentType == 'image' && message.attachmentUrl != null) {
      final isNetwork = message.attachmentUrl!.startsWith('http');
      contentWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => Dialog.fullscreen(
                  backgroundColor: Colors.black.withValues(alpha: 0.9),
                  child: Stack(
                    children: [
                      Center(
                        child: InteractiveViewer(
                          minScale: 1.0,
                          maxScale: 5.0,
                          child: isNetwork
                              ? CachedNetworkImage(
                                  imageUrl: message.attachmentUrl!,
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                )
                              : Image.file(
                                  File(message.attachmentUrl!),
                                  fit: BoxFit.contain,
                                ),
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 16.h,
                        right: 16.w,
                        child: IconButton(
                          icon: Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedCancel01,
                              color: Colors.white,
                              size: 24.r,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: isNetwork
                  ? CachedNetworkImage(
                      imageUrl: message.attachmentUrl!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: double.infinity,
                        height: 200.h,
                        color: AppColors.borderLight,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: double.infinity,
                        height: 200.h,
                        color: AppColors.borderLight,
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedAlert01,
                          color: AppColors.error,
                          size: 24.r,
                        ),
                      ),
                    )
                  : Image.file(
                      File(message.attachmentUrl!),
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: double.infinity,
                        height: 200.h,
                        color: AppColors.borderLight,
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedAlert01,
                          color: AppColors.error,
                          size: 24.r,
                        ),
                      ),
                    ),
            ),
          ),
          if (message.body.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              message.body,
              style: AppText.body.copyWith(
                color: isMine ? AppColors.white : AppColors.text,
                height: 1.4,
              ),
            ),
          ],
        ],
      );
    } else if (message.attachmentType == 'pdf' &&
        message.attachmentUrl != null) {
      final isNetwork = message.attachmentUrl!.startsWith('http');
      contentWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: isMine
                  ? AppColors.white.withValues(alpha: 0.2)
                  : AppColors.bg,
              borderRadius: BorderRadius.circular(12.r),
              border: isMine ? null : Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedPdf01,
                        color: AppColors.error,
                        size: 24.r,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.attachmentName ?? 'Document.pdf',
                            style: AppText.bodyBold.copyWith(
                              color: isMine ? AppColors.white : AppColors.text,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'PDF Document',
                            style: AppText.small.copyWith(
                              color: isMine
                                  ? AppColors.white.withValues(alpha: 0.8)
                                  : AppColors.muted2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        useSafeArea: true,
                        backgroundColor: AppColors.bg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24.r),
                          ),
                        ),
                        builder: (context) => ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24.r),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                                decoration: const BoxDecoration(
                                  color: AppColors.surface,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: AppColors.borderLight,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        message.attachmentName ??
                                            'Document Preview',
                                        style: AppText.heading3,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      icon: HugeIcon(
                                        icon: HugeIcons.strokeRoundedCancel01,
                                        size: 24.r,
                                        color: AppColors.text,
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: UJobPdfViewer(
                                  pdfUrl: message.attachmentUrl!,
                                  isLocalFile: !isNetwork,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(100.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: isMine
                            ? AppColors.white.withValues(alpha: 0.15)
                            : AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedEye,
                            size: 14.r,
                            color: isMine ? AppColors.white : AppColors.primary,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Preview',
                            style: AppText.small.copyWith(
                              color: isMine
                                  ? AppColors.white
                                  : AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (message.body.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              message.body,
              style: AppText.body.copyWith(
                color: isMine ? AppColors.white : AppColors.text,
                height: 1.4,
              ),
            ),
          ],
        ],
      );
    } else {
      contentWidget = Text(
        message.body,
        style: AppText.body.copyWith(
          color: isMine ? AppColors.white : AppColors.text,
          height: 1.4,
        ),
      );
    }

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.76,
        ),
        child: Column(
          crossAxisAlignment: isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                gradient: isMine
                    ? const LinearGradient(
                        colors: [
                          AppColors.primaryDark,
                          AppColors.primaryAccent,
                        ],
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
              child: contentWidget,
            ),
            SizedBox(height: 3.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: AppText.caption.copyWith(color: AppColors.muted2),
                ),
                if (isMine) ...[
                  SizedBox(width: 4.w),
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedTickDouble02,
                    size: 14.r,
                    color: message.isRead
                        ? AppColors.primary
                        : AppColors.muted2,
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
  final String? stagedFileType;
  final String? stagedFilePath;
  final String? stagedFileName;
  final void Function(String type, String path, String name) onStageFile;
  final VoidCallback onRemoveStagedFile;

  const _InputBar({
    required this.controller,
    required this.sending,
    required this.onSend,
    this.stagedFileType,
    this.stagedFilePath,
    this.stagedFileName,
    required this.onStageFile,
    required this.onRemoveStagedFile,
  });

  Future<void> _pickImage(BuildContext context) async {
    Navigator.pop(context);
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile != null) {
      onStageFile('image', xFile.path, xFile.name);
    }
  }

  Future<void> _pickDocument(BuildContext context) async {
    Navigator.pop(context);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.path != null) {
        onStageFile('pdf', file.path!, file.name);
      }
    }
  }

  void _showAttachmentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 40.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Send Attachment', style: AppText.heading3),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _AttachmentOption(
                    icon: HugeIcons.strokeRoundedImage01,
                    label: context.l10n.image,
                    color: AppColors.primary,
                    onTap: () => _pickImage(context),
                  ),
                  _AttachmentOption(
                    icon: HugeIcons.strokeRoundedPdf01,
                    label: context.l10n.document,
                    color: AppColors.error,
                    onTap: () => _pickDocument(context),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (stagedFilePath != null) ...[
              Container(
                margin: EdgeInsets.only(bottom: 12.h, left: 12.w, right: 12.w),
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    if (stagedFileType == 'image')
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6.r),
                        child: Image.file(
                          File(stagedFilePath!),
                          width: 40.r,
                          height: 40.r,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        width: 40.r,
                        height: 40.r,
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedPdf01,
                          color: AppColors.error,
                          size: 20.r,
                        ),
                      ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        stagedFileName ?? 'Attachment',
                        style: AppText.bodyBold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedCancel01,
                        color: AppColors.muted,
                        size: 20.r,
                      ),
                      onPressed: onRemoveStagedFile,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ],
            Row(
              children: [
                IconButton(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedAttachment01,
                    color: AppColors.muted,
                    size: 24.r,
                  ),
                  onPressed: () => _showAttachmentSheet(context),
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
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
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
                        colors: [
                          AppColors.primaryDark,
                          AppColors.primaryAccent,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: sending
                        ? Padding(
                            padding: EdgeInsets.all(12.r),
                            child: CircularProgressIndicator(
                              strokeWidth: 2.r,
                              color: AppColors.white,
                            ),
                          )
                        : Padding(
                            padding: EdgeInsets.only(left: 2.w),
                            child: Center(
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedSent,
                                color: AppColors.white,
                                size: 20.r,
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentOption extends StatelessWidget {
  final dynamic icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachmentOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: HugeIcon(icon: icon, color: color, size: 32.r),
          ),
          SizedBox(height: 8.h),
          Text(label, style: AppText.bodyBold),
        ],
      ),
    );
  }
}
