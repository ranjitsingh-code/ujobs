import os

file_path = 'lib/features/shared/notifications/notifications_screen.dart'
with open(file_path, 'r') as f:
    content = f.read()

single_options_method = """  void _showSingleNotifOptions(BuildContext context, WidgetRef ref, Notif n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 40.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Notification Options', style: AppText.heading3),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedCancel01,
                    color: AppColors.text,
                    size: 24.r,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            ListTile(
              leading: HugeIcon(
                icon: n.isRead ? HugeIcons.strokeRoundedMail02 : HugeIcons.strokeRoundedMailOpen01,
                color: AppColors.text,
                size: 24.r,
              ),
              title: Text(
                n.isRead ? 'Mark as Unread' : 'Mark as Read',
                style: AppText.bodyBold,
              ),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(notifsProvider.notifier).toggleReadStatus(n.id);
              },
            ),
            ListTile(
              leading: HugeIcon(
                icon: HugeIcons.strokeRoundedDelete02,
                color: AppColors.error,
                size: 24.r,
              ),
              title: Text(
                'Delete Notification',
                style: AppText.bodyBold.copyWith(color: AppColors.error),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDeleteSingle(ref, n);
              },
            ),
          ],
        ),
      ),
    );
  }

"""

# Insert _showSingleNotifOptions before _showMoreOptionsSheet
content = content.replace("  void _showMoreOptionsSheet(", single_options_method + "  void _showMoreOptionsSheet(")

# Update the longPress handler inside itemBuilder
old_long_press = """                                  onLongPress: () {
                                    if (!_isSelectionMode)
                                      _showMoreOptionsSheet(
                                        context,
                                        ref,
                                        primaryColor,
                                      );
                                  },"""

new_long_press = """                                  onLongPress: () {
                                    if (!_isSelectionMode)
                                      _showSingleNotifOptions(context, ref, n);
                                  },"""

content = content.replace(old_long_press, new_long_press)

with open(file_path, 'w') as f:
    f.write(content)
