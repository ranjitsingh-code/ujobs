import re

file_path = 'lib/features/seeker/dashboard/seeker_dashboard_screen.dart'
with open(file_path, 'r') as f:
    content = f.read()

# Check if already added
if "_ProfileSetupPrompt" not in content:
    new_components = """
class _ProfileSetupPrompt extends StatelessWidget {
  final VoidCallback onSetup;

  const _ProfileSetupPrompt({required this.onSetup});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.text.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedUserAdd01,
              color: AppColors.warning,
              size: 28.r,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Complete your profile',
                  style: AppText.titleSm.copyWith(color: AppColors.text),
                ),
                SizedBox(height: 4.h),
                Text(
                  'A complete profile helps you stand out to employers.',
                  style: AppText.small.copyWith(color: AppColors.muted),
                ),
                SizedBox(height: 16.h),
                FilledButton(
                  onPressed: onSetup,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.seekPrimary,
                    foregroundColor: AppColors.surface,
                    minimumSize: Size(120.w, 36.h),
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: const Text('Setup now'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessagesToReply extends StatelessWidget {
  final VoidCallback onViewAll;

  const _MessagesToReply({
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Needs Reply',
          actionLabel: 'View all',
          onActionTap: onViewAll,
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 78.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: 4, // Mock count
            separatorBuilder: (_, _) => SizedBox(width: 16.w),
            itemBuilder: (context, index) {
              return _MessageAvatar(
                name: ['TechCorp', 'DesignCo', 'InnovateInc', 'StartupX'][index],
                count: index == 0 ? 2 : 1,
                hasUnread: true,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MessageAvatar extends StatelessWidget {
  final String name;
  final int count;
  final bool hasUnread;

  const _MessageAvatar({
    required this.name,
    required this.count,
    required this.hasUnread,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 28.r,
              backgroundColor: AppColors.borderLight,
              child: Text(
                name.substring(0, 1),
                style: AppText.bodyBold.copyWith(color: AppColors.text2),
              ),
            ),
            if (hasUnread)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    count.toString(),
                    style: AppText.caption.copyWith(
                      color: AppColors.surface,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 4.h),
        SizedBox(
          width: 56.r,
          child: Text(
            name,
            style: AppText.caption,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
"""
    content += "\n" + new_components

# Insert widgets in layout
target_layout = """                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: ["""

new_layout = """                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner
                    _ProfileSetupPrompt(
                      onSetup: () => context.push('/seeker/profile'),
                    ),
                    
                    // Messages
                    _MessagesToReply(
                      onViewAll: () => context.push('/seeker/messages'),
                    ),
                    SizedBox(height: 32.h),
"""

content = content.replace(target_layout, new_layout)

# Also fix the opacity issues in the added code
content = content.replace('withOpacity(0.15)', 'withValues(alpha: 0.15)')
content = content.replace('withOpacity(0.03)', 'withValues(alpha: 0.03)')

with open(file_path, 'w') as f:
    f.write(content)

