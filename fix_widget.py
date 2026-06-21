with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'r') as f:
    text = f.read()

start_idx = text.find('class _CompanyProfileSetup extends StatelessWidget {')
if start_idx != -1:
    text = text[:start_idx] + """class _CompanyProfileSetup extends StatelessWidget {
  final VoidCallback onSetup;

  const _CompanyProfileSetup({required this.onSetup});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.xl,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedBuilding03,
              color: AppColors.primary,
              size: 28.r,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Complete your company profile',
                  style: AppText.titleSm.copyWith(color: AppColors.text),
                ),
                SizedBox(height: 4.h),
                Text(
                  'A complete profile helps attract better candidates and builds trust.',
                  style: AppText.small.copyWith(color: AppColors.muted),
                ),
                SizedBox(height: 16.h),
                FilledButton(
                  onPressed: onSetup,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
                  ),
                  child: Text('Setup', style: AppText.button),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
"""
    with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'w') as f:
        f.write(text)
