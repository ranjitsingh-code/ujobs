import re

with open('lib/features/employer/company/company_profile_screen.dart', 'r') as f:
    text = f.read()

# 1. Add image_picker import
if "import 'package:image_picker/image_picker.dart';" not in text:
    text = text.replace("import 'package:hugeicons/hugeicons.dart';", "import 'package:hugeicons/hugeicons.dart';\nimport 'package:image_picker/image_picker.dart';\nimport 'dart:io';")

# 2. Change Edit02 back to Maximize01 for About Company
text = text.replace("icon: HugeIcons.strokeRoundedEdit02,\n                            color: AppColors.primary,\n                            size: 20.r,", "icon: HugeIcons.strokeRoundedMaximize01,\n                            color: AppColors.primary,\n                            size: 20.r,")

# 3. Update the Upload Logo section to support image picking and displaying preview
old_edit_company = """  void _showEditCompanyInfo(BuildContext context, WidgetRef ref, CompanyProfile company) {
    final nameCtrl = TextEditingController(text: company.name);
    String? currentIndustry = company.industry?.isNotEmpty == true ? company.industry : null;
    final websiteCtrl = TextEditingController(text: company.website);
    String currentDescription = company.description ?? '';
    String? websiteError;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Company Information', style: AppText.heading3.copyWith(color: AppColors.text2)),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: const BoxDecoration(
                            color: AppColors.bg,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close_rounded, size: 20.r, color: AppColors.text2),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppColors.border, height: 1),
                Padding(
                  padding: EdgeInsets.all(20.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      UJobTextField(label: 'Company Name*', hint: 'e.g. Acme Ltd', controller: nameCtrl),
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

new_edit_company = """  void _showEditCompanyInfo(BuildContext context, WidgetRef ref, CompanyProfile company) {
    final nameCtrl = TextEditingController(text: company.name);
    String? currentIndustry = company.industry?.isNotEmpty == true ? company.industry : null;
    final websiteCtrl = TextEditingController(text: company.website);
    String currentDescription = company.description ?? '';
    String? currentLogo = company.logo;
    String? websiteError;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Company Information', style: AppText.heading3.copyWith(color: AppColors.text2)),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: const BoxDecoration(
                            color: AppColors.bg,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close_rounded, size: 20.r, color: AppColors.text2),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppColors.border, height: 1),
                Padding(
                  padding: EdgeInsets.all(20.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      UJobTextField(label: 'Company Name*', hint: 'e.g. Acme Ltd', controller: nameCtrl),
                      SizedBox(height: 16.h),
                      Text('Company Logo', style: AppText.label.copyWith(color: AppColors.text2)),
                      SizedBox(height: 8.h),
                      GestureDetector(
                        onTap: () async {
                          final picker = ImagePicker();
                          final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                          if (pickedFile != null) {
                            setState(() {
                              currentLogo = pickedFile.path;
                            });
                          }
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
                                clipBehavior: Clip.hardEdge,
                                child: currentLogo != null && currentLogo!.isNotEmpty
                                  ? (currentLogo!.startsWith('http') 
                                      ? Image.network(currentLogo!, fit: BoxFit.cover)
                                      : Image.file(File(currentLogo!), fit: BoxFit.cover))
                                  : Center(
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
                                    Text(currentLogo != null && currentLogo!.isNotEmpty ? 'Change Logo' : 'Upload Logo', style: AppText.bodyMd.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
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

text = text.replace(old_edit_company, new_edit_company)

# Add saving the logo inside the Save button of Company Information
text = text.replace("""                          ref.read(companyProfileProvider.notifier).state = company.copyWith(
                            name: nameCtrl.text,
                            industry: currentIndustry ?? '',
                            website: websiteCtrl.text,
                            description: currentDescription,
                          );""", """                          ref.read(companyProfileProvider.notifier).state = company.copyWith(
                            name: nameCtrl.text,
                            logo: currentLogo,
                            industry: currentIndustry ?? '',
                            website: websiteCtrl.text,
                            description: currentDescription,
                          );""")

with open('lib/features/employer/company/company_profile_screen.dart', 'w') as f:
    f.write(text)
