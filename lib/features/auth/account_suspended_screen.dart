import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ujob_button.dart';
import '../../../core/utils/l10n_extensions.dart';
import '../../../core/providers/auth_provider.dart';

class AccountSuspendedScreen extends ConsumerWidget {
  const AccountSuspendedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Generate a fixed date for the demo
    final dateStr = DateFormat('MMMM d, yyyy').format(DateTime(2026, 6, 16));

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 24.w),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.05),
                border: Border(
                  top: BorderSide(color: AppColors.error.withValues(alpha: 0.1)),
                  bottom: BorderSide(color: AppColors.error.withValues(alpha: 0.1)),
                ),
              ),
              child: Text(
                context.l10n.accountSuspendedBanner,
                style: AppText.body.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24.w, 40.h, 24.w, 40.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20.h),
                    
                    // Shield Icon
                    Container(
                      width: 120.r,
                      height: 120.r,
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedUserBlock01,
                          color: AppColors.error,
                          size: 56.r,
                        ),
                      ),
                    ),
                    SizedBox(height: 40.h),
                    
                    // Title
                    Text(
                      context.l10n.accountSuspendedTitle,
                      style: AppText.heading1.copyWith(
                        color: AppColors.text,
                        fontSize: 28.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    
                    // Description
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        context.l10n.accountSuspendedDesc,
                        style: AppText.body.copyWith(
                          color: AppColors.muted,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 32.h),
                    
                    // Date Pill
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          context.l10n.suspendedOnDate(dateStr),
                          style: AppText.body.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 48.h),
                    
                    // Contact Support Button
                    SizedBox(
                      width: double.infinity,
                      child: UJobButton(
                        label: context.l10n.contactSupportBtn,
                        color: AppColors.error,
                        gradient: const LinearGradient(
                          colors: [AppColors.error, AppColors.error],
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(context.l10n.supportFeaturesAreNotAvailableInTheDemo)),
                          );
                        },
                      ),
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // Sign Out Button
                    SizedBox(
                      width: double.infinity,
                      child: UJobButton(
                        label: context.l10n.signOutBtn,
                        outlined: true,
                        // Always force the primary blue/cyan color for sign out as per screenshot
                        color: AppColors.primary, 
                        onTap: () {
                          ref.read(authProvider.notifier).logout();
                          context.go('/login');
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
