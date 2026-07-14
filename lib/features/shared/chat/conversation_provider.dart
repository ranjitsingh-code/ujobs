import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/providers/auth_provider.dart';

enum ApplicationStatus {
  pending,
  shortlisted,
  interviewing,
  hired,
  rejected,
  applied,
  offered,
}

class Conversation {
  final String id;
  final String otherId;
  final String otherName;
  final String? otherInitials;
  final String? otherAvatar;
  final String? lastMessage;
  final DateTime? lastAt;
  final int unreadCount;
  final bool otherOnline;
  final bool requiresEmployerReply;
  final bool chatEnabled;
  // Not returned by GET /conversations — the API has no job linkage on a
  // conversation, so these stay null/false for real data. UI already
  // guards on them being null (see seeker/employer messages screens).
  final String? jobTitle;
  final ApplicationStatus? applicationStatus;

  const Conversation({
    required this.id,
    required this.otherId,
    required this.otherName,
    this.otherInitials,
    this.otherAvatar,
    this.lastMessage,
    this.lastAt,
    this.unreadCount = 0,
    this.otherOnline = false,
    this.requiresEmployerReply = false,
    this.chatEnabled = true,
    this.jobTitle,
    this.applicationStatus,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final otherUser = json['other_user'] as Map<String, dynamic>? ?? {};
    final lastMsg = json['last_message'] as Map<String, dynamic>?;
    return Conversation(
      id: json['id'].toString(),
      otherId: otherUser['id']?.toString() ?? '',
      otherName: otherUser['name']?.toString() ?? '',
      otherAvatar: otherUser['avatar_url']?.toString(),
      lastMessage: lastMsg?['body']?.toString(),
      lastAt: lastMsg?['created_at'] != null
          ? DateTime.tryParse(lastMsg!['created_at'].toString())
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
      chatEnabled: json['chat_enabled'] as bool? ?? true,
    );
  }

  Conversation copyWith({
    int? unreadCount,
    bool? otherOnline,
    String? lastMessage,
    DateTime? lastAt,
    ApplicationStatus? applicationStatus,
    bool? requiresEmployerReply,
    bool? chatEnabled,
  }) {
    return Conversation(
      id: id,
      otherId: otherId,
      otherName: otherName,
      otherInitials: otherInitials,
      otherAvatar: otherAvatar,
      lastMessage: lastMessage ?? this.lastMessage,
      lastAt: lastAt ?? this.lastAt,
      unreadCount: unreadCount ?? this.unreadCount,
      otherOnline: otherOnline ?? this.otherOnline,
      requiresEmployerReply:
          requiresEmployerReply ?? this.requiresEmployerReply,
      chatEnabled: chatEnabled ?? this.chatEnabled,
      jobTitle: jobTitle,
      applicationStatus: applicationStatus ?? this.applicationStatus,
    );
  }
}

class ChatMessage {
  final String id;
  final String body;
  final bool isMine;
  final DateTime sentAt;
  final bool isRead;
  final String? attachmentType; // 'image', 'pdf'
  final String? attachmentUrl;
  final String? attachmentName;

  const ChatMessage({
    required this.id,
    required this.body,
    required this.isMine,
    required this.sentAt,
    this.isRead = false,
    this.attachmentType,
    this.attachmentUrl,
    this.attachmentName,
  });

  // Real API has no sender_role — identity comes from sender_user_id
  // compared against the viewer's own user id.
  factory ChatMessage.fromJson(
    Map<String, dynamic> json, {
    required String currentUserId,
  }) {
    return ChatMessage(
      id: json['id'].toString(),
      body: json['body']?.toString() ?? '',
      isMine: json['sender_user_id']?.toString() == currentUserId,
      sentAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      isRead: json['is_read'] as bool? ?? false,
    );
  }
}

Future<List<Conversation>> _fetchConversations(Ref ref) async {
  final dio = ref.read(dioClientProvider).dio;
  final response = await dio.get(Ep.conversations);
  final data = response.data['data'] as List;
  return data
      .map((json) => Conversation.fromJson(json as Map<String, dynamic>))
      .toList();
}

/// Seeker-side. The API has no job_id on a conversation, so there is no
/// exact way to resolve "the conversation for this job." Best-effort: if
/// there's only one conversation, use it; otherwise try to match by company
/// name against the other party's name, falling back to the most recent
/// conversation.
Future<Conversation?> resolveJobConversation(
  WidgetRef ref, {
  String? companyName,
}) async {
  final dio = ref.read(dioClientProvider).dio;
  final response = await dio.get(Ep.conversations);
  final data = response.data['data'] as List;
  final conversations = data
      .map((json) => Conversation.fromJson(json as Map<String, dynamic>))
      .toList();
  if (conversations.isEmpty) return null;
  if (conversations.length == 1) return conversations.first;

  if (companyName != null && companyName.trim().isNotEmpty) {
    final needle = companyName.trim().toLowerCase();
    for (final conv in conversations) {
      final otherName = conv.otherName.trim().toLowerCase();
      if (otherName.isNotEmpty &&
          (otherName.contains(needle) || needle.contains(otherName))) {
        return conv;
      }
    }
  }

  conversations.sort(
    (a, b) => (b.lastAt ?? DateTime(0)).compareTo(a.lastAt ?? DateTime(0)),
  );
  return conversations.first;
}

/// Employer-only. Opens (or retrieves the existing) conversation with a
/// seeker for a specific job. Returns the conversation id.
Future<String> openConversation(
  WidgetRef ref, {
  required String seekerUserId,
  required String jobId,
}) async {
  final dio = ref.read(dioClientProvider).dio;
  final response = await dio.post(
    Ep.conversations,
    data: {
      'seeker_user_id': int.tryParse(seekerUserId) ?? seekerUserId,
      'job_id': int.tryParse(jobId) ?? jobId,
    },
  );
  return (response.data['data']['id']).toString();
}

/// Employer-only. Enables/disables further messages on a conversation.
Future<bool> setChatStatus(WidgetRef ref, String conversationId, bool enabled) async {
  final dio = ref.read(dioClientProvider).dio;
  final response = await dio.patch(
    Ep.conversationChatStatus(conversationId),
    data: {'enabled': enabled},
  );
  return response.data['data']['chat_enabled'] as bool? ?? enabled;
}

class ConversationsNotifier
    extends StateNotifier<AsyncValue<List<Conversation>>> {
  ConversationsNotifier(this.ref) : super(const AsyncLoading()) {
    _init();
  }

  final Ref ref;

  Future<void> _init() async {
    try {
      state = AsyncData(await _fetchConversations(ref));
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<void> refresh() => _init();

  void markAllAsRead() {
    state.whenData((convs) {
      state = AsyncData(convs.map((c) => c.copyWith(unreadCount: 0)).toList());
    });
  }

  void markAsRead(String id) {
    state.whenData((convs) {
      state = AsyncData(
        convs
            .map(
              (c) => c.id == id
                  ? c.copyWith(unreadCount: 0, requiresEmployerReply: false)
                  : c,
            )
            .toList(),
      );
    });
  }

  void deleteConversation(String id) {
    state.whenData((convs) {
      state = AsyncData(convs.where((c) => c.id != id).toList());
    });
  }

  void updateLastMessage(String id, String lastMessage, DateTime lastAt) {
    state.whenData((convs) {
      state = AsyncData(
        convs
            .map(
              (c) => c.id == id
                  ? c.copyWith(lastMessage: lastMessage, lastAt: lastAt)
                  : c,
            )
            .toList(),
      );
    });
  }

  void updateChatEnabled(String id, bool enabled) {
    state.whenData((convs) {
      state = AsyncData(
        convs
            .map((c) => c.id == id ? c.copyWith(chatEnabled: enabled) : c)
            .toList(),
      );
    });
  }

  void deleteConversations(List<String> ids) {
    state.whenData((convs) {
      state = AsyncData(convs.where((c) => !ids.contains(c.id)).toList());
    });
  }
}

final conversationsProvider =
    StateNotifierProvider<
      ConversationsNotifier,
      AsyncValue<List<Conversation>>
    >((ref) {
      return ConversationsNotifier(ref);
    });

class SeekerConversationsNotifier
    extends StateNotifier<AsyncValue<List<Conversation>>> {
  SeekerConversationsNotifier(this.ref) : super(const AsyncLoading()) {
    _init();
  }

  final Ref ref;

  Future<void> _init() async {
    try {
      state = AsyncData(await _fetchConversations(ref));
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<void> refresh() => _init();

  void markAllAsRead() {
    state.whenData((convs) {
      state = AsyncData(convs.map((c) => c.copyWith(unreadCount: 0)).toList());
    });
  }

  void markAsRead(String id) {
    state.whenData((convs) {
      state = AsyncData(
        convs.map((c) => c.id == id ? c.copyWith(unreadCount: 0) : c).toList(),
      );
    });
  }

  void deleteConversation(String id) {
    state.whenData((convs) {
      state = AsyncData(convs.where((c) => c.id != id).toList());
    });
  }

  void updateLastMessage(String id, String lastMessage, DateTime lastAt) {
    state.whenData((convs) {
      state = AsyncData(
        convs
            .map(
              (c) => c.id == id
                  ? c.copyWith(lastMessage: lastMessage, lastAt: lastAt)
                  : c,
            )
            .toList(),
      );
    });
  }

  void updateChatEnabled(String id, bool enabled) {
    state.whenData((convs) {
      state = AsyncData(
        convs
            .map((c) => c.id == id ? c.copyWith(chatEnabled: enabled) : c)
            .toList(),
      );
    });
  }

  void deleteConversations(List<String> ids) {
    state.whenData((convs) {
      state = AsyncData(convs.where((c) => !ids.contains(c.id)).toList());
    });
  }
}

final seekerConversationsProvider =
    StateNotifierProvider<
      SeekerConversationsNotifier,
      AsyncValue<List<Conversation>>
    >((ref) {
      return SeekerConversationsNotifier(ref);
    });

final chatMessagesProvider =
    StateNotifierProvider.family<
      ChatMessagesNotifier,
      AsyncValue<List<ChatMessage>>,
      String
    >((ref, conversationId) {
      return ChatMessagesNotifier(ref, conversationId);
    });

class ChatMessagesNotifier extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  ChatMessagesNotifier(this.ref, this.conversationId)
    : super(const AsyncLoading()) {
    _load();
  }

  final Ref ref;
  final String conversationId;

  Future<void> _load() async {
    try {
      final dio = ref.read(dioClientProvider).dio;
      final response = await dio.get(Ep.messages(conversationId));
      final data = response.data['data'] as List;
      final userId = ref.read(authProvider).valueOrNull?.id ?? '';
      state = AsyncData(
        data
            .map((json) => ChatMessage.fromJson(
                  json as Map<String, dynamic>,
                  currentUserId: userId,
                ))
            .toList(),
      );
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<void> refresh() => _load();

  Future<void> send(String body) async {
    final dio = ref.read(dioClientProvider).dio;
    final response = await dio.post(
      Ep.messages(conversationId),
      data: {'body': body},
    );
    final json = response.data['data'] as Map<String, dynamic>;
    final sent = ChatMessage(
      id: json['id'].toString(),
      body: json['body']?.toString() ?? body,
      isMine: true,
      sentAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      isRead: json['is_read'] as bool? ?? false,
    );
    final messages = state.valueOrNull ?? const <ChatMessage>[];
    state = AsyncData([...messages, sent]);
    ref
        .read(conversationsProvider.notifier)
        .updateLastMessage(conversationId, sent.body, sent.sentAt);
    ref
        .read(seekerConversationsProvider.notifier)
        .updateLastMessage(conversationId, sent.body, sent.sentAt);
  }

  /// No attachment endpoint exists on the chat API — this stays a
  /// local-only, non-persisted message (pre-existing limitation, not new).
  void sendAttachment({
    required String type,
    required String url,
    required String name,
    required String body,
  }) {
    final messages = state.valueOrNull ?? const <ChatMessage>[];
    state = AsyncData([
      ...messages,
      ChatMessage(
        id: 'local-${DateTime.now().microsecondsSinceEpoch}',
        body: body,
        isMine: true,
        sentAt: DateTime.now(),
        isRead: false,
        attachmentType: type,
        attachmentUrl: url,
        attachmentName: name,
      ),
    ]);
  }
}
