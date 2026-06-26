import re

file_path = 'lib/features/shared/notifications/notifications_screen.dart'
with open(file_path, 'r') as f:
    content = f.read()

# 1. Add toggleReadStatus
old_notif_methods = """  void deleteNotifications(List<String> ids) {
    state = state.where((n) => !ids.contains(n.id)).toList();
  }
}"""

new_notif_methods = """  void toggleReadStatus(String id) {
    state = state.map((n) => n.id == id ? n.copyWith(isRead: !n.isRead) : n).toList();
  }

  void deleteNotifications(List<String> ids) {
    state = state.where((n) => !ids.contains(n.id)).toList();
  }
}"""

content = content.replace(old_notif_methods, new_notif_methods)

# 2. Update itemBuilder to use Dismissible
old_item_builder = """                              itemBuilder: (ctx, i) {
                                final n = filtered[i];
                                final isSelected = _selectedIds.contains(n.id);
                                return _NotifCard(
                                  notif: n,
                                  icon: _iconFor(n.type),
                                  borderColor: _borderColor(
                                    n.type,
                                    primaryColor,
                                  ),
                                  primaryColor: primaryColor,
                                  isSelectionMode: _isSelectionMode,
                                  isSelected: isSelected,
                                  onTap: () {
                                    if (_isSelectionMode) {
                                      setState(() {
                                        isSelected
                                            ? _selectedIds.remove(n.id)
                                            : _selectedIds.add(n.id);
                                      });
                                    } else {
                                      ref
                                          .read(_notifsProvider.notifier)
                                          .markAsRead(n.id);
                                    }
                                  },
                                  onLongPress: () {
                                    if (!_isSelectionMode)
                                      _showMoreOptionsSheet(
                                        context,
                                        ref,
                                        primaryColor,
                                      );
                                  },
                                );
                              },"""

new_item_builder = """                              itemBuilder: (ctx, i) {
                                final n = filtered[i];
                                final isSelected = _selectedIds.contains(n.id);
                                
                                final card = _NotifCard(
                                  notif: n,
                                  icon: _iconFor(n.type),
                                  borderColor: _borderColor(
                                    n.type,
                                    primaryColor,
                                  ),
                                  primaryColor: primaryColor,
                                  isSelectionMode: _isSelectionMode,
                                  isSelected: isSelected,
                                  onTap: () {
                                    if (_isSelectionMode) {
                                      setState(() {
                                        isSelected
                                            ? _selectedIds.remove(n.id)
                                            : _selectedIds.add(n.id);
                                      });
                                    } else {
                                      ref
                                          .read(_notifsProvider.notifier)
                                          .markAsRead(n.id);
                                    }
                                  },
                                  onLongPress: () {
                                    if (!_isSelectionMode)
                                      _showMoreOptionsSheet(
                                        context,
                                        ref,
                                        primaryColor,
                                      );
                                  },
                                );

                                if (_isSelectionMode) return card;

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
                                      ref.read(_notifsProvider.notifier).toggleReadStatus(n.id);
                                      return false; // Don't dismiss, just update state
                                    } else {
                                      return true; // Dismiss and delete
                                    }
                                  },
                                  onDismissed: (direction) {
                                    if (direction == DismissDirection.endToStart) {
                                      ref.read(_notifsProvider.notifier).deleteNotifications([n.id]);
                                    }
                                  },
                                  child: card,
                                );
                              },"""

content = content.replace(old_item_builder, new_item_builder)

with open(file_path, 'w') as f:
    f.write(content)
