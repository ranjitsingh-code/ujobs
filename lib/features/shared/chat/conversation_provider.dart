import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    this.jobTitle,
    this.applicationStatus,
  });

  Conversation copyWith({
    int? unreadCount,
    bool? otherOnline,
    String? lastMessage,
    DateTime? lastAt,
    ApplicationStatus? applicationStatus,
    bool? requiresEmployerReply,
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
      requiresEmployerReply: requiresEmployerReply ?? this.requiresEmployerReply,
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
}

final demoConversations = <Conversation>[
  Conversation(
    id: 'conv-a1',
    otherId: 'a1',
    otherName: 'Alice Johnson',
    otherAvatar: 'https://i.pravatar.cc/150?u=alice',
    lastMessage: 'Thank you for the offer!',
    lastAt: DateTime.now().subtract(const Duration(minutes: 5)),
    unreadCount: 0,
    otherOnline: true,
    requiresEmployerReply: false,
    jobTitle: 'Software Engineer',
    applicationStatus: ApplicationStatus.hired,
  ),
  Conversation(
    id: 'conv-a2',
    otherId: 'a2',
    otherName: 'Bob Smith',
    otherAvatar: 'https://i.pravatar.cc/150?u=bob',
    lastMessage: 'Looking forward to the next steps.',
    lastAt: DateTime.now().subtract(const Duration(hours: 3)),
    unreadCount: 2,
    otherOnline: false,
    requiresEmployerReply: true,
    jobTitle: 'Software Engineer',
    applicationStatus: ApplicationStatus.shortlisted,
  ),
  Conversation(
    id: 'conv-a3',
    otherId: 'a3',
    otherName: 'Charlie Brown',
    otherAvatar: 'https://i.pravatar.cc/150?u=charlie',
    lastMessage: 'What time is the technical interview?',
    lastAt: DateTime.now().subtract(const Duration(days: 1)),
    unreadCount: 1,
    otherOnline: true,
    requiresEmployerReply: true,
    jobTitle: 'Website Developer',
    applicationStatus: ApplicationStatus.interviewing,
  ),
  Conversation(
    id: 'conv-a5',
    otherId: 'a5',
    otherName: 'Evan Wright',
    otherAvatar: 'https://i.pravatar.cc/150?u=evan',
    lastMessage: 'Thank you for your consideration.',
    lastAt: DateTime.now().subtract(const Duration(days: 3)),
    unreadCount: 0,
    otherOnline: false,
    requiresEmployerReply: false,
    jobTitle: 'SEO Expert',
    applicationStatus: ApplicationStatus.offered,
  ),
];

class ConversationsNotifier extends StateNotifier<AsyncValue<List<Conversation>>> {
  ConversationsNotifier() : super(const AsyncLoading()) {
    _init();
  }

  void _init() async {
    await Future.delayed(const Duration(milliseconds: 300));
    state = AsyncData(List.from(demoConversations));
  }

  void markAllAsRead() {
    state.whenData((convs) {
      state = AsyncData(convs.map((c) => c.copyWith(unreadCount: 0)).toList());
    });
  }

  void markAsRead(String id) {
    state.whenData((convs) {
      state = AsyncData(convs.map((c) => c.id == id ? c.copyWith(unreadCount: 0, requiresEmployerReply: false) : c).toList());
    });
  }

  void deleteConversation(String id) {
    state.whenData((convs) {
      state = AsyncData(convs.where((c) => c.id != id).toList());
    });
  }

  
  void updateLastMessage(String id, String lastMessage, DateTime lastAt) {
    state.whenData((convs) {
      state = AsyncData(convs.map((c) => c.id == id ? c.copyWith(lastMessage: lastMessage, lastAt: lastAt) : c).toList());
    });
  }

  void deleteConversations(List<String> ids) {
    state.whenData((convs) {
      state = AsyncData(convs.where((c) => !ids.contains(c.id)).toList());
    });
  }
}

final conversationsProvider = StateNotifierProvider<ConversationsNotifier, AsyncValue<List<Conversation>>>((ref) {
  return ConversationsNotifier();
});


final demoSeekerConversations = <Conversation>[
  Conversation(
    id: 'conv-e1',
    otherId: 'e1',
    otherName: 'Google',
    otherInitials: 'G',
    lastMessage: 'Congratulations! We would like to offer you the position.',
    lastAt: DateTime.now().subtract(const Duration(minutes: 5)),
    unreadCount: 0,
    otherOnline: true,
    jobTitle: 'Senior Flutter Developer',
    applicationStatus: ApplicationStatus.offered,
  ),
  Conversation(
    id: 'conv-e2',
    otherId: 'e2',
    otherName: 'Nexovia Solutions',
    otherInitials: 'N',
    lastMessage: 'Your technical interview is scheduled for tomorrow.',
    lastAt: DateTime.now().subtract(const Duration(hours: 3)),
    unreadCount: 2,
    otherOnline: false,
    jobTitle: 'Mobile App Developer',
    applicationStatus: ApplicationStatus.shortlisted,
  ),
  Conversation(
    id: 'conv-e3',
    otherId: 'e3',
    otherName: 'Amazon',
    otherInitials: 'A',
    lastMessage: 'Thank you for your application. We are reviewing it.',
    lastAt: DateTime.now().subtract(const Duration(days: 1)),
    unreadCount: 1,
    otherOnline: true,
    jobTitle: 'Software Engineer',
    applicationStatus: ApplicationStatus.applied,
  ),
  Conversation(
    id: 'conv-e4',
    otherId: 'e4',
    otherName: 'Microsoft',
    otherInitials: 'M',
    lastMessage: 'Unfortunately, we have moved forward with other candidates.',
    lastAt: DateTime.now().subtract(const Duration(days: 3)),
    unreadCount: 0,
    otherOnline: false,
    jobTitle: 'Backend Developer',
    applicationStatus: ApplicationStatus.rejected,
  ),
];

class SeekerConversationsNotifier extends StateNotifier<AsyncValue<List<Conversation>>> {
  SeekerConversationsNotifier() : super(const AsyncLoading()) {
    _init();
  }

  void _init() async {
    await Future.delayed(const Duration(milliseconds: 300));
    state = AsyncData(List.from(demoSeekerConversations));
  }

  void markAllAsRead() {
    state.whenData((convs) {
      state = AsyncData(convs.map((c) => c.copyWith(unreadCount: 0)).toList());
    });
  }

  void markAsRead(String id) {
    state.whenData((convs) {
      state = AsyncData(convs.map((c) => c.id == id ? c.copyWith(unreadCount: 0) : c).toList());
    });
  }

  void deleteConversation(String id) {
    state.whenData((convs) {
      state = AsyncData(convs.where((c) => c.id != id).toList());
    });
  }
  
  void updateLastMessage(String id, String lastMessage, DateTime lastAt) {
    state.whenData((convs) {
      state = AsyncData(convs.map((c) => c.id == id ? c.copyWith(lastMessage: lastMessage, lastAt: lastAt) : c).toList());
    });
  }

  void deleteConversations(List<String> ids) {
    state.whenData((convs) {
      state = AsyncData(convs.where((c) => !ids.contains(c.id)).toList());
    });
  }
}

final seekerConversationsProvider = StateNotifierProvider<SeekerConversationsNotifier, AsyncValue<List<Conversation>>>((ref) {
  return SeekerConversationsNotifier();
});


final chatMessagesProvider =
    StateNotifierProvider.family<
      DemoChatNotifier,
      AsyncValue<List<ChatMessage>>,
      String
    >((ref, conversationId) {
      return DemoChatNotifier(ref, conversationId);
    });

class DemoChatNotifier extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  DemoChatNotifier(this.ref, this.conversationId)
    : super(AsyncData(_demoMessages(conversationId)));

  final Ref ref;
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
    ref.read(conversationsProvider.notifier).updateLastMessage(conversationId, body, DateTime.now());
    ref.read(seekerConversationsProvider.notifier).updateLastMessage(conversationId, body, DateTime.now());

  }

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
        isRead: true,
        attachmentType: type,
        attachmentUrl: url,
        attachmentName: name,
      ),
    ]);
  }
}

List<ChatMessage> _demoMessages(String conversationId) {
  final now = DateTime.now();
  final name = switch (conversationId) {
    'conv-a1' => 'Alice',
    'conv-a2' => 'Bob',
    'conv-a3' => 'Charlie',
    'conv-a4' => 'Diana',
    'conv-a5' => 'Evan',
    _ => 'Applicant',
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
      body: 'Hi $name, could you please send your latest portfolio?',
      isMine: true,
      sentAt: now.subtract(const Duration(hours: 1, minutes: 50)),
      isRead: true,
    ),
    ChatMessage(
      id: '$conversationId-3',
      body: 'Sure, here is my design portfolio.',
      isMine: false,
      sentAt: now.subtract(const Duration(hours: 1, minutes: 45)),
      isRead: true,
      attachmentType: 'image',
      attachmentUrl: 'https://images.unsplash.com/photo-1542435503-956c469947f6?auto=format&fit=crop&q=80&w=600',
    ),
    ChatMessage(
      id: '$conversationId-4',
      body: 'And here is my detailed resume.',
      isMine: false,
      sentAt: now.subtract(const Duration(hours: 1, minutes: 44)),
      isRead: true,
      attachmentType: 'pdf',
      attachmentName: '${name}_Resume_2026.pdf',
      attachmentUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
    ),
    ChatMessage(
      id: '$conversationId-5',
      body: 'Thank you. I am available if you need any additional information.',
      isMine: false,
      sentAt: now.subtract(const Duration(minutes: 20)),
    ),
  ];
}
