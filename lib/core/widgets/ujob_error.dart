import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'ujob_button.dart';

class UJobError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const UJobError({required this.message, required this.onRetry, super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedWifiOff01,
            size: 56,
            color: AppColors.grey400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppText.body.copyWith(color: AppColors.grey600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          UJobButton(label: 'Try Again', onTap: onRetry),
        ],
      ),
    ),
  );
}
