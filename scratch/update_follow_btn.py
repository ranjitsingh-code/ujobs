import re

with open('lib/features/seeker/company/seeker_company_profile_screen.dart', 'r') as f:
    content = f.read()

orig_actions = """                  // Actions Section
                  Container(
                    color: AppColors.surface,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 16.h,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: UJobButton(
                            label: 'Follow Us',
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedUserAdd01,
                              color: AppColors.text,
                              size: 20.r,
                            ),
                            color: AppColors.text,
                            outlined: true,
                            onTap: () => _showSocialsModal(context),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: UJobButton(
                            label: context.l10n.website,
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedLink01,
                              color: AppColors.surface,
                              size: 20.r,
                            ),
                            gradient: AppColors.authGradient,
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                  ),"""

new_actions = """                  // Actions Section
                  Container(
                    color: AppColors.surface,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 16.h,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: InkWell(
                            onTap: () => _showSocialsModal(context),
                            borderRadius: BorderRadius.circular(16.r),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              decoration: BoxDecoration(
                                color: AppColors.seekPrimary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  HugeIcon(
                                    icon: HugeIcons.strokeRoundedUserAdd01,
                                    color: AppColors.seekPrimary,
                                    size: 20.r,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Follow Us',
                                    style: AppText.bodyBold.copyWith(
                                      color: AppColors.seekPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          flex: 5,
                          child: UJobButton(
                            label: context.l10n.website,
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedLink01,
                              color: AppColors.surface,
                              size: 20.r,
                            ),
                            gradient: AppColors.authGradient,
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                  ),"""

content = content.replace(orig_actions, new_actions)

with open('lib/features/seeker/company/seeker_company_profile_screen.dart', 'w') as f:
    f.write(content)
