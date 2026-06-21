import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class UJobAuthLinks extends StatelessWidget {
  final String primaryText;
  final String primaryLinkText;
  final VoidCallback onPrimaryTap;

  const UJobAuthLinks({
    required this.primaryText,
    required this.primaryLinkText,
    required this.onPrimaryTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _AuthLink(
            text: primaryText,
            linkText: primaryLinkText,
            onTap: onPrimaryTap,
          ),
        ],
      ),
    );
  }
}

class _AuthLink extends StatelessWidget {
  final String text;
  final String linkText;
  final VoidCallback onTap;

  const _AuthLink({
    required this.text,
    required this.linkText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4.w,
      children: [
        Text(text, style: AppText.small.copyWith(color: AppColors.muted)),
        GestureDetector(
          onTap: onTap,
          child: Text(
            linkText,
            style: AppText.small.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
