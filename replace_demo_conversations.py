import re

with open('lib/features/shared/chat/conversation_provider.dart', 'r') as f:
    content = f.read()

conversations_data = """[
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
    id: 'conv-a4',
    otherId: 'a4',
    otherName: 'Diana Prince',
    otherAvatar: 'https://i.pravatar.cc/150?u=diana',
    lastMessage: 'Here is my updated resume.',
    lastAt: DateTime.now().subtract(const Duration(days: 2)),
    unreadCount: 0,
    otherOnline: false,
    requiresEmployerReply: false,
    jobTitle: 'Mobile Application Developer',
    applicationStatus: ApplicationStatus.pending,
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
    jobTitle: 'Digital Marketer',
    applicationStatus: ApplicationStatus.rejected,
  ),
]"""

new_content = re.sub(r'final demoConversations = <Conversation>\[.*?\];', 'final demoConversations = <Conversation>' + conversations_data + ';', content, flags=re.DOTALL)

with open('lib/features/shared/chat/conversation_provider.dart', 'w') as f:
    f.write(new_content)

