import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/l10n_extensions.dart';
import 'ujob_checkbox.dart';

class UJobTermsAgreement extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback onTermsTap;
  final VoidCallback onPrivacyTap;
  final String? prefix;
  final String? termsLabel;
  final String? privacyLabel;

  const UJobTermsAgreement({
    required this.value,
    required this.onChanged,
    required this.onTermsTap,
    required this.onPrivacyTap,
    this.prefix,
    this.termsLabel,
    this.privacyLabel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final linkStyle = AppText.small.copyWith(
      color: AppColors.primary,
      fontWeight: FontWeight.w700,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.primary,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 1.h, bottom: 8.h, right: 8.w),
          child: UJobCheckbox(
            value: value,
            onChanged: onChanged,
            semanticsLabel: prefix ?? l10n.agreeTo,
          ),
        ),
        Expanded(
          child: Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 3.w,
            runSpacing: 2.h,
            children: [
              Text(
                prefix ?? l10n.agreeTo,
                style: AppText.small.copyWith(color: AppColors.muted),
              ),
              GestureDetector(
                onTap: onTermsTap,
                child: Text(
                  termsLabel ?? l10n.termsAndConditions,
                  style: linkStyle,
                ),
              ),
              Text(
                l10n.and,
                style: AppText.small.copyWith(color: AppColors.muted),
              ),
              GestureDetector(
                onTap: onPrivacyTap,
                child: Text(
                  privacyLabel ?? l10n.privacyPolicy,
                  style: linkStyle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
