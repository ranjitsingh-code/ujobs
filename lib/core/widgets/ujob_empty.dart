import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'ujob_button.dart';

class UJobEmpty extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final List<List<dynamic>> icon;

  const UJobEmpty({
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.icon = HugeIcons.strokeRoundedInbox,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(icon: icon, size: 64, color: AppColors.grey400),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppText.heading3.copyWith(color: AppColors.grey600),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: AppText.body.copyWith(color: AppColors.grey400),
              textAlign: TextAlign.center,
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 24),
            UJobButton(label: actionLabel!, onTap: onAction),
          ],
        ],
      ),
    ),
  );
}
