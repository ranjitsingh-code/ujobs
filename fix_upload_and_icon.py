import re

with open('lib/features/employer/company/company_profile_screen.dart', 'r') as f:
    text = f.read()

# 1. Change the icon from Edit02 to Maximize01
text = text.replace("HugeIcons.strokeRoundedEdit02", "HugeIcons.strokeRoundedMaximize01")

# 2. Add the Upload Logo section right after Company Name
old_name_field = "UJobTextField(label: 'Company Name*', hint: 'e.g. Acme Ltd', controller: nameCtrl),"
new_name_field = """UJobTextField(label: 'Company Name*', hint: 'e.g. Acme Ltd', controller: nameCtrl),
                      SizedBox(height: 16.h),
                      Text('Company Logo', style: AppText.label.copyWith(color: AppColors.text2)),
                      SizedBox(height: 8.h),
                      GestureDetector(
                        onTap: () {
                          // TODO: Implement image picker
                        },
                        child: Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: AppColors.bg,
                            borderRadius: AppRadius.md,
                            border: Border.all(
                              color: AppColors.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48.r,
                                height: 48.r,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: AppRadius.sm,
                                ),
                                child: Center(
                                  child: HugeIcon(
                                    icon: HugeIcons.strokeRoundedImage01,
                                    color: AppColors.primary,
                                    size: 24.r,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Upload Logo', style: AppText.bodyMd.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                                    SizedBox(height: 4.h),
                                    Text(
                                      'PNG, JPG or SVG · Max 3 MB\\nSquare recommended',
                                      style: AppText.caption.copyWith(color: AppColors.muted2, height: 1.2),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),"""

text = text.replace(old_name_field, new_name_field)

with open('lib/features/employer/company/company_profile_screen.dart', 'w') as f:
    f.write(text)
