import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/providers/auth_provider.dart';

class Conversation {
  final String id;
  final String otherName;
  final String? otherInitials;
  final String? otherAvatar;
  final String? lastMessage;
  final DateTime? lastAt;
  final int unreadCount;
  final bool otherOnline;

  const Conversation({
    required this.id,
    required this.otherName,
    this.otherInitials,
    this.otherAvatar,
    this.lastMessage,
    this.lastAt,
    this.unreadCount = 0,
    this.otherOnline = false,
  });

  factory Conversation.fromJson(Map<String, dynamic> j) {
    final other = j['other_user'] as Map<String, dynamic>? ??
        j['employer'] as Map<String, dynamic>? ??
        j['seeker'] as Map<String, dynamic>? ??
        {};
    final name = '${other['first_name'] ?? ''} ${other['last_name'] ?? ''}'.trim();
    final initials = name.isNotEmpty
        ? name.split(' ').take(2).map((w) => w.isNotEmpty ? w[0] : '').join().toUpperCase()
        : '?';
    return Conversation(
      id: j['id']?.toString() ?? '',
      otherName: name.isNotEmpty ? name : (other['company_name'] as String? ?? 'Unknown'),
      otherInitials: initials,
      otherAvatar: other['avatar'] as String? ?? other['logo'] as String?,
      lastMessage: j['last_message'] as String?,
      lastAt: DateTime.tryParse(j['last_message_at'] as String? ?? j['updated_at'] as String? ?? ''),
      unreadCount: j['unread_count'] as int? ?? 0,
      otherOnline: j['is_online'] as bool? ?? false,
    );
  }
}

class ChatMessage {
  final String id;
  final String body;
  final bool isMine;
  final DateTime sentAt;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.body,
    required this.isMine,
    required this.sentAt,
    this.isRead = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> j, String myId) {
    final senderId = j['sender_id']?.toString() ?? '';
    return ChatMessage(
      id: j['id']?.toString() ?? '',
      body: j['body'] as String? ?? j['message'] as String? ?? '',
      isMine: senderId == myId,
      sentAt: DateTime.tryParse(j['created_at'] as String? ?? '') ?? DateTime.now(),
      isRead: j['is_read'] as bool? ?? false,
    );
  }
}

final conversationsProvider = FutureProvider.autoDispose<List<Conversation>>((ref) async {
  final res = await ref.watch(dioClientProvider).dio.get(Ep.conversations);
  final data = res.data['data'] as List? ?? [];
  return data.map((j) => Conversation.fromJson(j as Map<String, dynamic>)).toList();
});

final chatMessagesProvider = FutureProvider.autoDispose.family<List<ChatMessage>, String>((ref, conversationId) async {
  final client = ref.watch(dioClientProvider);
  final res = await client.dio.get(Ep.messages(conversationId));
  final data = res.data['data'] as List? ?? [];
  // Sender ID resolution: use 'me' as placeholder — real apps compare with auth user id
  return data.map((j) => ChatMessage.fromJson(j as Map<String, dynamic>, 'me')).toList();
});
