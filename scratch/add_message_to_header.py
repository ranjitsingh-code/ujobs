import re

with open('lib/features/seeker/company/seeker_company_profile_screen.dart', 'r') as f:
    content = f.read()

# 1. Add Message under Info icon
orig_header_end = """                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: HugeIcon(
                                icon: HugeIcons.strokeRoundedInformationCircle,
                                color: AppColors.muted,
                                size: 24.r,
                              ),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: AppColors.surface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(24.r),
                                    ),
                                  ),
                                  builder: (context) =>
                                      _buildCompanyInfoModal(context),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),"""
new_header_end = """                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: HugeIcon(
                                icon: HugeIcons.strokeRoundedInformationCircle,
                                color: AppColors.muted,
                                size: 24.r,
                              ),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: AppColors.surface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(24.r),
                                    ),
                                  ),
                                  builder: (context) =>
                                      _buildCompanyInfoModal(context),
                                );
                              },
                            ),
                            SizedBox(height: 8.h),
                            InkWell(
                              onTap: () {
                                UJobToast.info(
                                  context,
                                  'Not yet available',
                                  sub: 'You can only message the company after being shortlisted for an interview.',
                                );
                              },
                              borderRadius: BorderRadius.circular(8.r),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                                child: Column(
                                  children: [
                                    HugeIcon(
                                      icon: HugeIcons.strokeRoundedMessage02,
                                      color: AppColors.seekPrimary,
                                      size: 20.r,
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      'Message',
                                      style: AppText.small.copyWith(
                                        color: AppColors.seekPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),"""
content = content.replace(orig_header_end, new_header_end)


# 2. Remove Message Company from _buildCompanyInfoModal
orig_modal = """          _infoRow(
            HugeIcons.strokeRoundedGlobal,
            'Website',
            widget.company.website ?? 'N/A',
          ),
          SizedBox(height: 32.h),
          UJobButton(
            label: 'Message Company',
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedMessage02,
              color: AppColors.seekPrimary,
              size: 20.r,
            ),
            color: AppColors.seekPrimary,
            outlined: true,
            onTap: () {
              Navigator.pop(context);
              UJobToast.info(
                context,
                'Not yet available',
                sub: 'You can only message the company after being shortlisted for an interview.',
              );
            },
          ),
        ],
      ),"""
new_modal = """          _infoRow(
            HugeIcons.strokeRoundedGlobal,
            'Website',
            widget.company.website ?? 'N/A',
          ),
        ],
      ),"""
content = content.replace(orig_modal, new_modal)

with open('lib/features/seeker/company/seeker_company_profile_screen.dart', 'w') as f:
    f.write(content)
