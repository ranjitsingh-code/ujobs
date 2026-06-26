import re

with open('lib/features/shared/notifications/notifications_screen.dart', 'r') as f:
    text = f.read()

# Replace the onTap block
ontap_target = """                                  onTap: () {
                                      ref
                                          .read(notificationsProvider.notifier)
                                          .markAsRead(n.id);

                                      final isEmployer =
                                          ref.read(activeRoleProvider) ==
                                          'employer';
                                      if (n.type == 'message') {
                                        if (isEmployer) {
                                          context.push(
                                            '/conversations/1',
                                            extra: {'name': 'Jim'},
                                          );
                                        } else {
                                          context.push(
                                            '/conversations/1',
                                            extra: {
                                              'name': 'Nexovia Solutions',
                                            },
                                          );
                                        }
                                      } else if (n.type == 'job') {
                                        if (isEmployer) {
                                          context.push('/employer/jobs/1');
                                        } else {
                                          context.push('/seeker/jobs/1');
                                        }
                                      } else if (n.type == 'application' || n.type == 'new_application') {
                                        if (isEmployer) {
                                          context.push('/employer/applicants');
                                        } else {
                                          context.push('/seeker/applications');
                                        }
                                      }
                                  },"""

ontap_replacement = """                                  onTap: () {
                                    ref.read(notificationsProvider.notifier).markAsRead(n.id);
                                    final isEmployer = ref.read(activeRoleProvider) == 'employer';
                                    
                                    final bool isActionable = n.type == 'message' || 
                                                              n.type == 'job' || 
                                                              n.type == 'job_approved' || 
                                                              n.type == 'application' || 
                                                              n.type == 'new_application';

                                    showDialog(
                                      context: context,
                                      builder: (ctx) => Dialog(
                                        backgroundColor: AppColors.surface,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                                        child: Padding(
                                          padding: EdgeInsets.all(24.r),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(16.r),
                                                decoration: BoxDecoration(
                                                  color: _borderColor(n.type, primaryColor).withValues(alpha: 0.1),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: HugeIcon(
                                                  icon: _iconFor(n.type),
                                                  color: _borderColor(n.type, primaryColor),
                                                  size: 32.r,
                                                ),
                                              ),
                                              SizedBox(height: 20.h),
                                              Text(n.title, style: AppText.heading3, textAlign: TextAlign.center),
                                              SizedBox(height: 12.h),
                                              Text(
                                                n.body,
                                                style: AppText.bodyMedium.copyWith(color: AppColors.muted),
                                                textAlign: TextAlign.center,
                                              ),
                                              SizedBox(height: 28.h),
                                              if (isActionable)
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: OutlinedButton(
                                                        onPressed: () => Navigator.pop(ctx),
                                                        style: OutlinedButton.styleFrom(
                                                          foregroundColor: AppColors.muted,
                                                          side: const BorderSide(color: AppColors.border),
                                                          padding: EdgeInsets.symmetric(vertical: 14.h),
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                                        ),
                                                        child: Text('Close', style: AppText.bodyBold),
                                                      ),
                                                    ),
                                                    SizedBox(width: 12.w),
                                                    Expanded(
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.pop(ctx);
                                                          if (n.type == 'message') {
                                                            context.push('/conversations/1', extra: {'name': isEmployer ? 'Jim' : 'Nexovia Solutions'});
                                                          } else if (n.type == 'job' || n.type == 'job_approved') {
                                                            context.push(isEmployer ? '/employer/jobs/1' : '/seeker/jobs/1');
                                                          } else if (n.type == 'application' || n.type == 'new_application') {
                                                            context.push(isEmployer ? '/employer/applicants' : '/seeker/applications');
                                                          }
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: primaryColor,
                                                          padding: EdgeInsets.symmetric(vertical: 14.h),
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                                        ),
                                                        child: Text('View', style: AppText.bodyBold.copyWith(color: Colors.white)),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              else
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: ElevatedButton(
                                                    onPressed: () => Navigator.pop(ctx),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: primaryColor,
                                                      padding: EdgeInsets.symmetric(vertical: 14.h),
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                                    ),
                                                    child: Text('Close', style: AppText.bodyBold.copyWith(color: Colors.white)),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },"""

text = text.replace(ontap_target, ontap_replacement)

with open('lib/features/shared/notifications/notifications_screen.dart', 'w') as f:
    f.write(text)

