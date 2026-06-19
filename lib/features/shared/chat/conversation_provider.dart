import 'package:flutter_riverpod/flutter_riverpod.dart';

class Conversation {
  final String id;
  final String otherName;
  final String? otherInitials;
  final String? otherAvatar;
  final String? lastMessage;
  final DateTime? lastAt;
  final int unreadCount;
  final bool otherOnline;
  final bool requiresEmployerReply;

  const Conversation({
    required this.id,
    required this.otherName,
    this.otherInitials,
    this.otherAvatar,
    this.lastMessage,
    this.lastAt,
    this.unreadCount = 0,
    this.otherOnline = false,
    this.requiresEmployerReply = false,
  });
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
}

final demoConversations = <Conversation>[
  Conversation(
    id: 'conversation-sarah',
    otherName: 'Sarah Chen',
    otherInitials: 'SC',
    lastMessage: 'I am available for the interview tomorrow.',
    lastAt: DateTime.now().subtract(const Duration(minutes: 8)),
    unreadCount: 2,
    otherOnline: true,
    requiresEmployerReply: true,
  ),
  Conversation(
    id: 'conversation-ahmed',
    otherName: 'Ahmed Hasan',
    otherInitials: 'AH',
    lastMessage: 'Thank you for reviewing my application.',
    lastAt: DateTime.now().subtract(const Duration(hours: 1)),
    unreadCount: 1,
    requiresEmployerReply: true,
  ),
  Conversation(
    id: 'conversation-maria',
    otherName: 'Maria Garcia',
    otherInitials: 'MG',
    lastMessage: 'Could you share the next steps?',
    lastAt: DateTime.now().subtract(const Duration(hours: 3)),
    unreadCount: 4,
    requiresEmployerReply: true,
  ),
  Conversation(
    id: 'conversation-james',
    otherName: 'James Kim',
    otherInitials: 'JK',
    lastMessage: 'Following up on our conversation.',
    lastAt: DateTime.now().subtract(const Duration(days: 1)),
    requiresEmployerReply: true,
  ),
];

final conversationsProvider = FutureProvider.autoDispose<List<Conversation>>((
  ref,
) async {
  return demoConversations;
});

final chatMessagesProvider =
    StateNotifierProvider.family<
      DemoChatNotifier,
      AsyncValue<List<ChatMessage>>,
      String
    >((ref, conversationId) {
      return DemoChatNotifier(conversationId);
    });

class DemoChatNotifier extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  DemoChatNotifier(this.conversationId)
    : super(AsyncData(_demoMessages(conversationId)));

  final String conversationId;

  void send(String body) {
    final messages = state.valueOrNull ?? const <ChatMessage>[];
    state = AsyncData([
      ...messages,
      ChatMessage(
        id: 'local-${DateTime.now().microsecondsSinceEpoch}',
        body: body,
        isMine: true,
        sentAt: DateTime.now(),
        isRead: true,
      ),
    ]);
  }
}

List<ChatMessage> _demoMessages(String conversationId) {
  final now = DateTime.now();
  final name = switch (conversationId) {
    'conversation-ahmed' => 'Ahmed',
    'conversation-maria' => 'Maria',
    'conversation-james' => 'James',
    _ => 'Sarah',
  };
  return [
    ChatMessage(
      id: '$conversationId-1',
      body: 'Hello, I applied for the position and wanted to follow up.',
      isMine: false,
      sentAt: now.subtract(const Duration(hours: 2)),
      isRead: true,
    ),
    ChatMessage(
      id: '$conversationId-2',
      body: 'Hi $name, thanks for reaching out. We are reviewing applications.',
      isMine: true,
      sentAt: now.subtract(const Duration(hours: 1, minutes: 45)),
      isRead: true,
    ),
    ChatMessage(
      id: '$conversationId-3',
      body: 'Thank you. I am available if you need any additional information.',
      isMine: false,
      sentAt: now.subtract(const Duration(minutes: 20)),
    ),
  ];
}
