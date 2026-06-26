import re

with open('lib/features/seeker/company/seeker_company_profile_screen.dart', 'r') as f:
    content = f.read()

# Add import
if "import '../../../core/widgets/ujob_alert_dialog.dart';" not in content:
    content = content.replace("import '../../../core/widgets/ujob_button.dart';", "import '../../../core/widgets/ujob_button.dart';\nimport '../../../core/widgets/ujob_alert_dialog.dart';")

# Replace dialog
orig_dialog = """                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: AppColors.surface,
                                  title: Text('Open Browser?', style: AppText.heading3),
                                  content: Text(
                                    'This will open the company website in your external web browser. Do you want to continue?',
                                    style: AppText.body.copyWith(color: AppColors.text2),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Cancel', style: AppText.bodyBold.copyWith(color: AppColors.muted)),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        final uri = Uri.parse(url);
                                        if (await canLaunchUrl(uri)) {
                                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                                        } else {
                                          if (context.mounted) {
                                            UJobToast.error(context, 'Could not launch URL');
                                          }
                                        }
                                      },
                                      child: Text('Open', style: AppText.bodyBold.copyWith(color: AppColors.primary)),
                                    ),
                                  ],
                                ),
                              );"""

new_dialog = """                              showDialog(
                                context: context,
                                builder: (context) => UJobAlertDialog(
                                  icon: HugeIcon(
                                    icon: HugeIcons.strokeRoundedGlobal,
                                    color: AppColors.seekPrimary,
                                    size: 32.r,
                                  ),
                                  iconBgColor: AppColors.seekPrimary,
                                  title: 'Open Browser?',
                                  description: 'This will open the company website in your external web browser. Do you want to continue?',
                                  confirmText: 'Open',
                                  confirmColor: AppColors.seekPrimary,
                                  onConfirm: () async {
                                    Navigator.pop(context);
                                    final uri = Uri.parse(url);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                                    } else {
                                      if (context.mounted) {
                                        UJobToast.error(context, 'Could not launch URL');
                                      }
                                    }
                                  },
                                ),
                              );"""

content = content.replace(orig_dialog, new_dialog)

with open('lib/features/seeker/company/seeker_company_profile_screen.dart', 'w') as f:
    f.write(content)
