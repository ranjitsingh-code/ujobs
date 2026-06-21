with open('lib/features/shared/chat/conversation_provider.dart', 'r') as f:
    content = f.read()

# 1. Update ApplicationStatus enum to include 'applied' and 'offered'
if 'offered' not in content:
    content = content.replace('  rejected,\n}', '  rejected,\n  applied,\n  offered,\n}')

# 2. Update Conversations Notifier autoDispose
content = content.replace('StateNotifierProvider.autoDispose<', 'StateNotifierProvider<')

# 3. Add updateLastMessage to ConversationsNotifier
if 'updateLastMessage' not in content:
    update_func = """
  void updateLastMessage(String id, String lastMessage, DateTime lastAt) {
    state.whenData((convs) {
      state = AsyncData(convs.map((c) => c.id == id ? c.copyWith(lastMessage: lastMessage, lastAt: lastAt) : c).toList());
    });
  }
"""
    content = content.replace('void deleteConversations(List<String> ids) {', update_func + '\n  void deleteConversations(List<String> ids) {')

# 4. Modify chatMessagesProvider to pass ref
content = content.replace('return DemoChatNotifier(conversationId);', 'return DemoChatNotifier(ref, conversationId);')
content = content.replace('DemoChatNotifier(this.conversationId)', 'DemoChatNotifier(this.ref, this.conversationId)')
content = content.replace('final String conversationId;', 'final Ref ref;\n  final String conversationId;')

# 5. Modify send() to call updateLastMessage
send_update = """
    ref.read(conversationsProvider.notifier).updateLastMessage(conversationId, body, DateTime.now());
"""
content = content.replace('isRead: true,\n      ),\n    ]);', 'isRead: true,\n      ),\n    ]);' + send_update)

# 6. Update demoConversations array
convs_data = """[
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
];"""

start_idx = content.find('final demoConversations = <Conversation>[')
end_idx = content.find('];', start_idx)
if start_idx != -1 and end_idx != -1:
    content = content[:start_idx] + 'final demoConversations = <Conversation>' + convs_data + content[end_idx+2:]

with open('lib/features/shared/chat/conversation_provider.dart', 'w') as f:
    f.write(content)
