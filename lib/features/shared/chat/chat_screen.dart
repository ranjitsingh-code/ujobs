import 'package:go_router/go_router.dart';

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/l10n_extensions.dart';
import '../../../core/widgets/ujob_avatar.dart';
import '../../../core/widgets/ujob_error.dart';
import '../../../core/widgets/ujob_loading.dart';
import '../../../core/widgets/ujob_app_bar.dart';
import '../../../core/widgets/ujob_pdf_viewer.dart';
import '../../../core/providers/role_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/notification_navigation.dart';
import 'conversation_provider.dart';
import '../../../core/widgets/ujob_alert_dialog.dart';
import '../../../core/widgets/ujob_toast.dart';
import '../../employer/applicants/employer_applicant_service.dart';
import '../../../core/models/applicant.dart';
import '../../../core/models/company.dart';
import '../../seeker/jobs/seeker_job_provider.dart';

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
  // Employer-only. Same application id used by ApplicantDetailScreen's
  // GET /employer/applicants/:id — lets ChatScreen fetch its own fresh
  // name/email/phone/avatar instead of trusting route `extra` (which a
  // cold-started push notification deep link won't have populated).
  final String? applicantId;
  // Seeker-only. Lets ChatScreen fetch the job's company (name/logo) the
  // same self-hydrating way as applicantId does for employers. The seeker
  // job-details API has no employer email/phone at all today (confirmed
  // against a live response) — only name/logo are available.
  final String? jobId;

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
    this.applicantId,
    this.jobId,
    super.key,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with WidgetsBindingObserver {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _msgFocusNode = FocusNode();
  bool _sending = false;

  String? _stagedFileType;
  String? _stagedFilePath;
  String? _stagedFileName;

  late bool _fallbackClosed;
  Applicant? _applicant;
  Company? _company;
  bool _didInitialScroll = false;
  int _prevMsgCount = 0;
  bool _showNewMessagePill = false;

  void _jumpToBottom() {
    void doJump() {
      if (mounted && _scrollCtrl.hasClients) {
        _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
      }
    }
    // A single post-frame jump can land short: opening via a notification
    // deep-link (fresh route push, page-transition still animating) or the
    // page-route transition settling after this frame both change
    // maxScrollExtent after the first jump already ran. Re-jump on the next
    // frame and again after a short delay so it always lands on the real
    // bottom instead of leaving the last message just off-screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      doJump();
      WidgetsBinding.instance.addPostFrameCallback((_) => doJump());
      Future.delayed(const Duration(milliseconds: 250), doJump);
    });
  }

  void _animateToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Messenger-style: only auto-follow new messages if the viewer was
  // already near the bottom. Someone scrolled up reading history shouldn't
  // get yanked down by an incoming message — they get the pill instead.
  bool _isNearBottom() {
    if (!_scrollCtrl.hasClients) return true;
    final position = _scrollCtrl.position;
    return (position.maxScrollExtent - position.pixels) < 120.h;
  }

  // Reacts to every message-list change (poll refresh, own send, incoming
  // message) regardless of whether async.when's `data` branch happens to
  // rebuild — ref.listen fires on state transitions themselves.
  void _onMessagesChanged(
    AsyncValue<List<ChatMessage>>? previous,
    AsyncValue<List<ChatMessage>> next,
  ) {
    final messages = next.valueOrNull;
    if (messages == null) return;
    if (!_didInitialScroll) {
      _didInitialScroll = true;
      _prevMsgCount = messages.length;
      if (messages.isNotEmpty) _jumpToBottom();
      return;
    }
    if (messages.length <= _prevMsgCount) {
      _prevMsgCount = messages.length;
      return;
    }
    _prevMsgCount = messages.length;
    final lastMsg = messages.last;
    if (lastMsg.isMine || _isNearBottom()) {
      if (_showNewMessagePill) setState(() => _showNewMessagePill = false);
      _animateToBottom();
    } else {
      setState(() => _showNewMessagePill = true);
    }
  }

  void _onScroll() {
    if (_showNewMessagePill && _isNearBottom()) {
      setState(() => _showNewMessagePill = false);
    }
  }

  double _lastBottomInset = 0;

  // Keyboard covers the input bar's usual spot, pushing the last message up
  // behind it unless we scroll to follow. Triggering off focus-change plus a
  // guessed delay was flaky — it worked the first time (coincidentally
  // riding the unrelated initial-load auto-scroll) but not on a later
  // refocus, since keyboard animation duration isn't fixed/predictable.
  // didChangeMetrics fires with the real, already-updated view insets
  // whenever the keyboard's height actually changes, for every open, not a
  // one-off — the correct direct signal instead of a proxy guess.
  @override
  void didChangeMetrics() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bottomInset = MediaQuery.of(context).viewInsets.bottom;
      if (bottomInset > _lastBottomInset) _animateToBottom();
      _lastBottomInset = bottomInset;
    });
  }

  // conversationsProvider and seekerConversationsProvider both hit the
  // identical GET /conversations endpoint — only one is ever "this
  // session's own list" depending on which role is active. Using both
  // unconditionally double-fetches/double-polls the same data for nothing.
  bool get _isEmployer => ref.read(activeRoleProvider.notifier).isEmployer;

  List<Conversation> get _myConversations => _isEmployer
      ? ref.read(conversationsProvider).valueOrNull ?? const []
      : ref.read(seekerConversationsProvider).valueOrNull ?? const [];

  @override
  void initState() {
    super.initState();
    _fallbackClosed = widget.isClosed;
    WidgetsBinding.instance.addObserver(this);
    _scrollCtrl.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (_isEmployer) {
          ref.read(conversationsProvider.notifier).markAsRead(widget.conversationId);
        } else {
          ref.read(seekerConversationsProvider.notifier).markAsRead(widget.conversationId);
        }
      }
    });
    _applicantFuture = _fetchApplicant();
    _companyFuture = _fetchJobCompany();
    registerChatRefreshCallback(widget.conversationId, _refreshChat);
  }

  // Kept so _showUserDetailsSheet can await an in-flight fetch instead of
  // racing it — tapping the 3-dot right after landing on this screen (e.g.
  // list -> "Open Chat" shortcut, skipping the applicant-detail screen that
  // would otherwise have given the fetch time to finish) used to open the
  // sheet with _applicant/_company still null, showing no email/phone.
  Future<void>? _applicantFuture;
  Future<void>? _companyFuture;

  Future<void> _fetchApplicant() async {
    final applicantId = widget.applicantId;
    final isEmployer = ref.read(activeRoleProvider.notifier).isEmployer;
    if (applicantId == null || applicantId.isEmpty) return;
    if (!isEmployer) return;
    try {
      final applicant = await ref
          .read(employerApplicantServiceProvider)
          .getApplicantDetails(applicantId);
      if (mounted) setState(() => _applicant = applicant);
    } catch (e) {
      debugPrint('[CHAT] applicant fetch failed: $e');
    }
  }

  Future<void> _fetchJobCompany() async {
    final jobId = widget.jobId;
    if (jobId == null || jobId.isEmpty) return;
    if (ref.read(activeRoleProvider.notifier).isEmployer) return;
    final parsedId = int.tryParse(jobId);
    if (parsedId == null) return;
    try {
      final job = await ref.read(seekerJobServiceProvider).getJobDetails(parsedId);
      if (mounted && job.company != null) setState(() => _company = job.company);
    } catch (_) {
      // Silent — screen falls back to whatever route `extra` provided.
    }
  }

  // GET /conversations' `other_user.name` is the source of truth for who
  // this chat is with — checked first because the FCM `message` push's
  // `sender_name` field has been observed sending the *recipient's own*
  // name instead of the actual sender's (backend bug), which would
  // otherwise show a seeker their own name at the top of the chat they
  // opened from that notification.
  String get _displayName {
    for (final c in _myConversations) {
      if (c.id == widget.conversationId && c.otherName.isNotEmpty) {
        return c.otherName;
      }
    }
    if (_applicant?.name.isNotEmpty ?? false) return _applicant!.name;
    if (_company?.name.isNotEmpty ?? false) return _company!.name;
    return widget.otherName;
  }

  String? get _displayAvatar => _applicant?.avatarUrl ?? _company?.logo ?? widget.otherAvatar;

  String get _displayInitials => (_applicant?.initials.isNotEmpty ?? false)
      ? _applicant!.initials
      : (widget.otherInitials ?? (widget.otherName.isNotEmpty ? widget.otherName[0] : '?'));

  // Company has no email/phone at all today (confirmed against a live
  // GET /seeker/jobs/:id response) — these stay employer-only until the
  // backend exposes employer contact info to seekers.
  String? get _displayEmail =>
      (_applicant?.email.isNotEmpty ?? false) ? _applicant!.email : null;
  // Shown whenever the applicant has a phone on file — matches
  // ApplicantDetailScreen, which also shows it unconditionally.
  String? get _displayPhone =>
      (_applicant?.phone.isNotEmpty ?? false) ? _applicant!.phone : null;

  // Company has no email/phone (confirmed above), but GET /seeker/jobs/:id
  // does return a company website — show that instead so seekers still get
  // a way to reach/verify the company from the chat sheet.
  String? get _displayWebsite =>
      (_company?.website?.isNotEmpty ?? false) ? _company!.website : null;

  String? get _displayLocation {
    if (_applicant?.location.isNotEmpty ?? false) return _applicant!.location;
    if (_company?.location?.isNotEmpty ?? false) return _company!.location;
    return widget.otherLocation;
  }

  Future<void> _openWebsite(String url) async {
    final normalized = url.startsWith('http') ? url : 'https://$url';
    try {
      final launched = await launchUrl(
        Uri.parse(normalized),
        mode: LaunchMode.externalApplication,
      );
      if (!launched) throw Exception('Could not launch');
    } catch (_) {
      if (mounted) UJobToast.error(context, context.l10n.errorTitle);
    }
  }

  // Chat no longer polls (too many API calls) — messages are reloaded on
  // pull-to-refresh, the app bar refresh button, resuming the app, or a
  // "message" push notification for this exact conversation arriving while
  // it's already open (see registerChatRefreshCallback in
  // notification_navigation.dart). Conversation-level chat_enabled isn't
  // pushed in real time either, so this also refreshes this viewer's own
  // conversation list alongside messages.
  Future<void> _refreshChat() async {
    await ref.read(chatMessagesProvider(widget.conversationId).notifier).refresh();
    if (_isEmployer) {
      ref.read(conversationsProvider.notifier).refresh();
    } else {
      ref.read(seekerConversationsProvider.notifier).refresh();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshChat();
    }
  }

  bool _liveIsClosed() {
    for (final c in _myConversations) {
      if (c.id == widget.conversationId) return !c.chatEnabled;
    }
    return _fallbackClosed;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unregisterChatRefreshCallback(widget.conversationId);
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    _msgFocusNode.dispose();
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
        await ref
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

  Future<void> _setChatStatus(bool enabled) async {
    try {
      await setChatStatus(ref, widget.conversationId, enabled);
      if (_isEmployer) {
        ref
            .read(conversationsProvider.notifier)
            .updateChatEnabled(widget.conversationId, enabled);
      } else {
        ref
            .read(seekerConversationsProvider.notifier)
            .updateChatEnabled(widget.conversationId, enabled);
      }
      if (!mounted) return;
      setState(() => _fallbackClosed = !enabled);
    } catch (e) {
      if (!mounted) return;
      UJobToast.error(context, context.l10n.errorTitle, sub: context.l10n.tryAgainMessage);
    }
  }

  void _copyToClipboard(String value) {
    Clipboard.setData(ClipboardData(text: value));
    UJobToast.success(context, context.l10n.copiedToClipboardMessage);
  }

  void _showUserDetailsSheet() {
    // Snapshot at tap time: is a fetch still in flight? If so the sheet
    // shows a spinner and waits for it, INSIDE this one sheet route,
    // instead of blocking on a separate showDialog route beforehand — a
    // separate route risked being left orphaned (stuck on screen, eating a
    // back-press) if the chat screen got popped while it awaited the fetch.
    final stillLoading =
        (_applicant == null && _applicantFuture != null) ||
        (_company == null && _companyFuture != null);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        if (!stillLoading) return _buildUserDetailsSheetBody(context);
        return FutureBuilder<void>(
          future: Future.wait([
            _applicantFuture ?? Future.value(),
            _companyFuture ?? Future.value(),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return SizedBox(
                height: 240.h,
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            return _buildUserDetailsSheetBody(context);
          },
        );
      },
    );
  }

  Widget _buildUserDetailsSheetBody(BuildContext context) {
    final isClosed = _liveIsClosed();
    final email = _displayEmail;
    final phone = _displayPhone;
    final website = _displayWebsite;
    final location = _displayLocation;
    final hasInfo = widget.jobTitle != null ||
        email != null ||
        phone != null ||
        website != null ||
        location != null ||
        widget.applicationStatus != null;
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
                imageUrl: _displayAvatar,
                initials: _displayInitials,
                size: 80.r,
              ),
              SizedBox(height: 16.h),
              Text(_displayName, style: AppText.heading3),
              SizedBox(height: 4.h),
              Text(
                'Active now',
                style: AppText.body.copyWith(color: AppColors.success),
              ),

              if (hasInfo) ...[
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
                    if (email != null) ...[
                      InkWell(
                        onTap: () => _copyToClipboard(email),
                        borderRadius: BorderRadius.circular(8.r),
                        child: Row(
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedMail01,
                              size: 16.r,
                              color: AppColors.muted,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(email, style: AppText.body),
                            ),
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedCopy01,
                              size: 16.r,
                              color: AppColors.muted,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],
                    if (phone != null)
                      InkWell(
                        onTap: () => _copyToClipboard(phone),
                        borderRadius: BorderRadius.circular(8.r),
                        child: Row(
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedCall02,
                              size: 16.r,
                              color: AppColors.muted,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(phone, style: AppText.body),
                            ),
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedCopy01,
                              size: 16.r,
                              color: AppColors.muted,
                            ),
                          ],
                        ),
                      ),
                    if (website != null) ...[
                      SizedBox(height: 12.h),
                      InkWell(
                        onTap: () => _openWebsite(website),
                        borderRadius: BorderRadius.circular(8.r),
                        child: Row(
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedGlobal,
                              size: 16.r,
                              color: AppColors.muted,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                website,
                                style: AppText.body,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedArrowUpRight01,
                              size: 16.r,
                              color: AppColors.muted,
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (location != null) ...[
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
                              location,
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
              ],

              SizedBox(height: 24.h),
              if (ref.read(activeRoleProvider) == 'employer') ...[
                if (!isClosed)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: HugeIcon(
                      icon: HugeIcons.strokeRoundedLockPassword,
                      color: AppColors.error,
                      size: 24.r,
                    ),
                    title: Text(
                      context.l10n.stopMessageTitle,
                      style: AppText.bodyBold.copyWith(color: AppColors.error),
                    ),
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
                          title: context.l10n.stopMessageTitle,
                          description: context.l10n.stopMessageConfirmMessage,
                          confirmText: context.l10n.stopMessageTitle,
                          onConfirm: () {
                            Navigator.pop(context); // Close dialog
                            _setChatStatus(false);
                          },
                        ),
                      );
                    },
                  )
                else
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: HugeIcon(
                      icon: HugeIcons.strokeRoundedLockPassword,
                      color: AppColors.success,
                      size: 24.r,
                    ),
                    title: Text(context.l10n.reopenChatTitle, style: AppText.bodyBold),
                    onTap: () {
                      Navigator.pop(context); // Close bottom sheet
                      _setChatStatus(true);
                    },
                  ),
              ],
              // Block User hidden for now — not needed right now.
              if (false)
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
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final async = ref.watch(chatMessagesProvider(widget.conversationId));
    ref.listen<AsyncValue<List<ChatMessage>>>(
      chatMessagesProvider(widget.conversationId),
      _onMessagesChanged,
    );
    // ref.listen only fires on a state TRANSITION after it's registered —
    // it never fires for a value already resolved at registration time.
    // chatMessagesProvider isn't autoDispose, so reopening a conversation
    // already loaded earlier this session hands back cached AsyncData with
    // no transition at all, and the screen would silently stay scrolled to
    // wherever it started instead of jumping to the latest message. Handle
    // that "already resolved" case directly here, once.
    final currentMessages = async.valueOrNull;
    if (!_didInitialScroll && currentMessages != null) {
      _didInitialScroll = true;
      _prevMsgCount = currentMessages.length;
      if (currentMessages.isNotEmpty) _jumpToBottom();
    }
    final me = ref.watch(authProvider).valueOrNull;
    final viewerIsEmployer = ref.read(activeRoleProvider.notifier).isEmployer;
    final myConvs = viewerIsEmployer
        ? ref.watch(conversationsProvider).valueOrNull ?? const []
        : ref.watch(seekerConversationsProvider).valueOrNull ?? const [];
    var isClosed = _fallbackClosed;
    for (final c in myConvs) {
      if (c.id == widget.conversationId) {
        isClosed = !c.chatEnabled;
        break;
      }
    }
    // Bubble side/avatar follow the viewer, not a fixed role — whichever
    // account is chatting sees their own messages on the right, same as
    // any standard chat UI (WhatsApp-style), not "employer always right".
    final myInitials = me?.initials ?? '?';
    final myAvatar = me?.avatarUrl;
    final otherInitials = _displayInitials;
    final otherAvatar = _displayAvatar;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: UJobAppBar(
        title: '',
        rightGutter: 88.w,
        customTitle: InkWell(
          onTap: () {
            final isEmployer = ref.read(activeRoleProvider.notifier).isEmployer;
            if (isEmployer) {
              context.push('/employer/applicants/${widget.applicantId ?? widget.otherId}');
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
                    imageUrl: _displayAvatar,
                    initials: _displayInitials,
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
                      _displayName,
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
        rightWidget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedRefresh,
                color: AppColors.text,
                size: 24.r,
              ),
              onPressed: _refreshChat,
            ),
            IconButton(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedMoreVertical,
                color: AppColors.text,
                size: 24.r,
              ),
              onPressed: _showUserDetailsSheet,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: _refreshChat,
                  child: async.when(
              loading: () => ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [UJobLoading(count: 5)],
              ),
              error: (e, _) => ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  UJobError(
                    message: l10n.failedLoadMessages,
                    onRetry: () =>
                        ref.refresh(chatMessagesProvider(widget.conversationId)),
                  ),
                ],
              ),
              data: (messages) {
                if (messages.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: 300.h,
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedMessage01,
                                size: 18.r,
                                color: AppColors.muted,
                              ),
                              SizedBox(width: 8.w),
                              Text(l10n.sayHello),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return ListView.builder(
                  controller: _scrollCtrl,
                  physics: const AlwaysScrollableScrollPhysics(),
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
                        _MessageBubble(
                          message: msg,
                          myInitials: myInitials,
                          myAvatar: myAvatar,
                          otherInitials: otherInitials,
                          otherAvatar: otherAvatar,
                        ),
                      ],
                    );
                  },
                );
              },
                  ),
                ),
                if (_showNewMessagePill)
                  Positioned(
                    bottom: 12.h,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _showNewMessagePill = false);
                          _animateToBottom();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(100.r),
                            boxShadow: AppShadow.card(),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedArrowDown01,
                                color: AppColors.white,
                                size: 16.r,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                l10n.newMessages,
                                style: AppText.small.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (isClosed)
            _ChatStoppedBanner(isEmployer: viewerIsEmployer),
          _InputBar(
            controller: _msgCtrl,
            focusNode: _msgFocusNode,
            sending: _sending,
            enabled: !isClosed,
            hintText: isClosed ? l10n.chatStoppedInputHint : null,
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

class _ChatStoppedBanner extends StatelessWidget {
  final bool isEmployer;
  const _ChatStoppedBanner({required this.isEmployer});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: AppColors.error.withValues(alpha: 0.08),
      child: Row(
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedLockPassword,
            color: AppColors.error,
            size: 18.r,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              isEmployer
                  ? context.l10n.chatStoppedBannerEmployer
                  : context.l10n.chatStoppedBannerSeeker,
              style: AppText.small.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
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
  final String myInitials;
  final String? myAvatar;
  final String otherInitials;
  final String? otherAvatar;

  const _MessageBubble({
    required this.message,
    required this.myInitials,
    this.myAvatar,
    required this.otherInitials,
    this.otherAvatar,
  });

  @override
  Widget build(BuildContext context) {
    // Standard chat convention: whoever is viewing sees their own sent
    // messages on the right, the other party's on the left — same for
    // both seeker and employer accounts, not fixed by role.
    final isRight = message.isMine;
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
                color: isRight ? AppColors.white : AppColors.text,
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
              color: isRight
                  ? AppColors.white.withValues(alpha: 0.2)
                  : AppColors.bg,
              borderRadius: BorderRadius.circular(12.r),
              border: isRight ? null : Border.all(color: AppColors.borderLight),
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
                              color: isRight ? AppColors.white : AppColors.text,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'PDF Document',
                            style: AppText.small.copyWith(
                              color: isRight
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
                        color: isRight
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
                            color: isRight ? AppColors.white : AppColors.primary,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Preview',
                            style: AppText.small.copyWith(
                              color: isRight
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
                color: isRight ? AppColors.white : AppColors.text,
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
          color: isRight ? AppColors.white : AppColors.text,
          height: 1.4,
        ),
      );
    }

    final avatar = UJobAvatar(
      imageUrl: isRight ? myAvatar : otherAvatar,
      initials: isRight ? myInitials : otherInitials,
      size: 28.r,
    );

    final avatarGap = 28.r + 8.w; // avatar size + spacing, so time row lines up under the bubble, not the avatar

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Column(
        crossAxisAlignment:
            isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isRight ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isRight) ...[avatar, SizedBox(width: 8.w)],
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    gradient: isRight
                        ? const LinearGradient(
                            colors: [
                              AppColors.primaryDark,
                              AppColors.primaryAccent,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isRight ? null : AppColors.surface,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: AppShadow.card(),
                  ),
                  child: contentWidget,
                ),
              ),
              if (isRight) ...[SizedBox(width: 8.w), avatar],
            ],
          ),
          SizedBox(height: 3.h),
          Padding(
            padding: EdgeInsets.only(
              left: isRight ? 0 : avatarGap,
              right: isRight ? avatarGap : 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: AppText.caption.copyWith(color: AppColors.muted2),
                ),
                if (message.isMine) ...[
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
          ),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool sending;
  final bool enabled;
  final String? hintText;
  final VoidCallback onSend;
  final String? stagedFileType;
  final String? stagedFilePath;
  final String? stagedFileName;
  final void Function(String type, String path, String name) onStageFile;
  final VoidCallback onRemoveStagedFile;

  const _InputBar({
    required this.controller,
    this.focusNode,
    required this.sending,
    this.enabled = true,
    this.hintText,
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
                // Attach button hidden for now — no attachment endpoint on
                // the chat API yet. Re-enable by restoring this IconButton.
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    enabled: enabled,
                    textCapitalization: TextCapitalization.sentences,
                    style: AppText.body,
                    maxLines: 4,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: hintText ?? l10n.typeMessage,
                      hintStyle: AppText.body.copyWith(
                        color: !enabled ? AppColors.error.withValues(alpha: 0.5) : AppColors.muted2,
                      ),
                      filled: true,
                      fillColor: enabled
                          ? AppColors.bg
                          : AppColors.error.withValues(alpha: 0.05),
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
                  onTap: (sending || !enabled) ? null : onSend,
                  child: Container(
                    width: 42.r,
                    height: 42.r,
                    decoration: BoxDecoration(
                      gradient: enabled
                          ? const LinearGradient(
                              colors: [
                                AppColors.primaryDark,
                                AppColors.primaryAccent,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: enabled ? null : AppColors.error.withValues(alpha: 0.15),
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
                        : Center(
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedSent,
                              color: enabled ? AppColors.white : AppColors.error,
                              size: 20.r,
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
