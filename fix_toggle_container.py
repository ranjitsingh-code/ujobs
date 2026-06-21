with open('lib/features/employer/company/company_profile_screen.dart', 'r') as f:
    text = f.read()

old_toggle = """                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Show contact info to job seekers', style: AppText.bodyMd.copyWith(color: AppColors.text2)),
                                SizedBox(height: 4.h),
                                Text(
                                  showContact ? 'Visible on public profile' : 'Hidden from public page', 
                                  style: AppText.caption.copyWith(color: AppColors.muted)
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: showContact,
                            activeColor: AppColors.primary,
                            onChanged: (val) => setState(() => showContact = val),
                          ),
                        ],
                      ),"""

new_toggle = """                      Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: AppColors.bg,
                          borderRadius: AppRadius.md,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: showContact ? AppColors.primaryLight : AppColors.muted.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: HugeIcon(
                                icon: showContact ? HugeIcons.strokeRoundedView : HugeIcons.strokeRoundedViewOffSlash,
                                color: showContact ? AppColors.primary : AppColors.muted2,
                                size: 20.r,
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Show contact info', style: AppText.bodyMd.copyWith(color: AppColors.text2, fontWeight: FontWeight.w600)),
                                  SizedBox(height: 4.h),
                                  Text(
                                    showContact ? 'Visible to job seekers' : 'Hidden from public page', 
                                    style: AppText.caption.copyWith(color: AppColors.muted)
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: showContact,
                              activeColor: AppColors.primary,
                              onChanged: (val) => setState(() => showContact = val),
                            ),
                          ],
                        ),
                      ),"""

text = text.replace(old_toggle, new_toggle)

with open('lib/features/employer/company/company_profile_screen.dart', 'w') as f:
    f.write(text)
