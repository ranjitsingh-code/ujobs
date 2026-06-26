import os

file_path = 'lib/features/shared/notifications/notifications_screen.dart'
with open(file_path, 'r') as f:
    content = f.read()

# 1. Remove NeverScrollableScrollPhysics
old_page_view = """            child: PageView.builder(
              physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,"""
new_page_view = """            child: PageView.builder(
              controller: _pageController,"""
content = content.replace(old_page_view, new_page_view)

# 2. Remove Dismissible
old_dismissible = """                                if (_isSelectionMode) return card;

                                return Dismissible(
                                  key: Key(n.id),
                                  direction: DismissDirection.horizontal,
                                  background: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                                    child: HugeIcon(
                                      icon: n.isRead ? HugeIcons.strokeRoundedMail02 : HugeIcons.strokeRoundedMailOpen01,
                                      color: Colors.white,
                                      size: 28.r,
                                    ),
                                  ),
                                  secondaryBackground: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.error,
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                    alignment: Alignment.centerRight,
                                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                                    child: HugeIcon(
                                      icon: HugeIcons.strokeRoundedDelete02,
                                      color: Colors.white,
                                      size: 28.r,
                                    ),
                                  ),
                                  confirmDismiss: (direction) async {
                                    if (direction == DismissDirection.startToEnd) {
                                      ref.read(notifsProvider.notifier).toggleReadStatus(n.id);
                                      return false; // Don't dismiss, just update state
                                    } else {
                                      return true; // Dismiss and delete
                                    }
                                  },
                                  onDismissed: (direction) {
                                    if (direction == DismissDirection.endToStart) {
                                      ref.read(notifsProvider.notifier).deleteNotifications([n.id]);
                                    }
                                  },
                                  child: card,
                                );"""

new_dismissible = """                                return card;"""

content = content.replace(old_dismissible, new_dismissible)

with open(file_path, 'w') as f:
    f.write(content)
