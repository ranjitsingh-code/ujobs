with open('lib/features/shared/chat/chat_screen.dart', 'r') as f:
    text = f.read()

# Add import
import_statement = "import '../../../core/widgets/ujob_alert_dialog.dart';"
if import_statement not in text:
    # insert after the last import
    last_import = text.rfind("import '")
    if last_import != -1:
        end_of_line = text.find('\n', last_import)
        text = text[:end_of_line] + f"\n{import_statement}" + text[end_of_line:]

# Update Close Chat
close_chat_old = """                  onTap: () {
                    setState(() {
                      _isClosed = true;
                    });
                    Navigator.pop(context);
                  },"""

close_chat_new = """                  onTap: () {
                    Navigator.pop(context); // Close bottom sheet
                    showDialog(
                      context: context,
                      builder: (context) => UJobAlertDialog(
                        icon: HugeIcon(icon: HugeIcons.strokeRoundedLockPassword, color: AppColors.error, size: 28.r),
                        title: 'Close Chat',
                        description: 'Are you sure you want to close this chat? You will not be able to send or receive messages until you reopen it.',
                        confirmText: 'Close Chat',
                        onConfirm: () {
                          setState(() {
                            _isClosed = true;
                          });
                          Navigator.pop(context); // Close dialog
                        },
                      ),
                    );
                  },"""

text = text.replace(close_chat_old, close_chat_new)

# Update Block User
block_user_old = """                onTap: () {
                  Navigator.pop(context);
                },"""

block_user_new = """                onTap: () {
                  Navigator.pop(context); // Close bottom sheet
                  showDialog(
                    context: context,
                    builder: (context) => UJobAlertDialog(
                      icon: HugeIcon(icon: HugeIcons.strokeRoundedUserBlock01, color: AppColors.error, size: 28.r),
                      title: 'Block User',
                      description: 'Are you sure you want to block this user? They will no longer be able to message you or apply to your jobs.',
                      confirmText: 'Block User',
                      onConfirm: () {
                        // Implement block user logic here
                        Navigator.pop(context); // Close dialog
                      },
                    ),
                  );
                },"""

text = text.replace(block_user_old, block_user_new)

with open('lib/features/shared/chat/chat_screen.dart', 'w') as f:
    f.write(text)
