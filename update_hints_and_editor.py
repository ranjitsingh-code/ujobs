with open('lib/features/employer/company/company_profile_screen.dart', 'r') as f:
    text = f.read()

# 1. Add missing import for rich text editor
if "import '../../../core/widgets/ujob_rich_text_editor.dart';" not in text:
    text = text.replace("import '../../../core/widgets/ujob_dropdown_field.dart';", "import '../../../core/widgets/ujob_dropdown_field.dart';\nimport '../../../core/widgets/ujob_rich_text_editor.dart';")

# 2. Update About Company rendering in _SectionCard
old_about = """                        Text(
                          company.description?.isNotEmpty == true ? company.description! : 'Not set',
                          style: AppText.bodyMd.copyWith(
                            color: company.description?.isNotEmpty == true ? AppColors.text2 : AppColors.muted2,
                            fontStyle: company.description?.isNotEmpty == true ? FontStyle.normal : FontStyle.italic,
                          ),
                        ),"""

new_about = """                        Text(
                          company.description?.isNotEmpty == true ? getPlainTextFromQuillJson(company.description!) : 'Not set',
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.bodyMd.copyWith(
                            color: company.description?.isNotEmpty == true ? AppColors.text2 : AppColors.muted2,
                            fontStyle: company.description?.isNotEmpty == true ? FontStyle.normal : FontStyle.italic,
                          ),
                        ),"""
text = text.replace(old_about, new_about)

# 3. Update text fields with e.g. hints and change description field to rich text editor
old_edit_company = """  void _showEditCompanyInfo(BuildContext context, WidgetRef ref, CompanyProfile company) {
    final nameCtrl = TextEditingController(text: company.name);
    final industryCtrl = TextEditingController(text: company.industry);
    final websiteCtrl = TextEditingController(text: company.website);
    final descCtrl = TextEditingController(text: company.description);
    _showBottomSheet(
      context,
      'Company Information',
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UJobTextField(label: 'Company Name*', controller: nameCtrl),
          SizedBox(height: 16.h),
          UJobDropdownField(
            label: 'Industry',
            hint: 'Select industry...',
            value: company.industry?.isNotEmpty == true ? company.industry : null,
            options: const [('Software Development', 'Software Development'), ('Finance', 'Finance'), ('Healthcare', 'Healthcare'), ('Education', 'Education')],
            onChanged: (val) => industryCtrl.text = val ?? '',
          ),
          SizedBox(height: 16.h),
          UJobTextField(label: 'Website', hint: 'https://acme.com', controller: websiteCtrl),
          SizedBox(height: 16.h),
          UJobTextField(
            label: 'About Company',
            hint: 'Describe your company culture, mission...',
            controller: descCtrl,
            maxLines: 5,
          ),
          SizedBox(height: 24.h),
          UJobButton(
            label: 'Save',
            onTap: () {
              ref.read(companyProfileProvider.notifier).state = company.copyWith(
                name: nameCtrl.text,
                industry: industryCtrl.text,
                website: websiteCtrl.text,
                description: descCtrl.text,
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }"""

new_edit_company = """  void _showEditCompanyInfo(BuildContext context, WidgetRef ref, CompanyProfile company) {
    final nameCtrl = TextEditingController(text: company.name);
    final industryCtrl = TextEditingController(text: company.industry);
    final websiteCtrl = TextEditingController(text: company.website);
    String currentDescription = company.description ?? '';
    
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
                      UJobDropdownField(
                        label: 'Industry',
                        hint: 'Select industry...',
                        value: company.industry?.isNotEmpty == true ? company.industry : null,
                        options: const [('Software Development', 'Software Development'), ('Finance', 'Finance'), ('Healthcare', 'Healthcare'), ('Education', 'Education')],
                        onChanged: (val) => industryCtrl.text = val ?? '',
                      ),
                      SizedBox(height: 16.h),
                      UJobTextField(label: 'Website', hint: 'e.g. https://acme.com', controller: websiteCtrl),
                      SizedBox(height: 16.h),
                      GestureDetector(
                        onTap: () => showUJobRichTextEditor(
                          context: context,
                          title: 'About Company',
                          initialValue: currentDescription,
                          onSave: (val) {
                            setState(() {
                              currentDescription = val;
                            });
                          },
                        ),
                        child: UJobTextField(
                          label: 'About Company',
                          hint: 'Tap to open editor...',
                          readOnly: true,
                          maxLines: 4,
                          minLines: 4,
                          controller: TextEditingController(text: getPlainTextFromQuillJson(currentDescription)),
                          labelTrailing: HugeIcon(
                            icon: HugeIcons.strokeRoundedEdit02,
                            color: AppColors.primary,
                            size: 20.r,
                          ),
                          onTap: () => showUJobRichTextEditor(
                            context: context,
                            title: 'About Company',
                            initialValue: currentDescription,
                            onSave: (val) {
                              setState(() {
                                currentDescription = val;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      UJobButton(
                        label: 'Save',
                        onTap: () {
                          ref.read(companyProfileProvider.notifier).state = company.copyWith(
                            name: nameCtrl.text,
                            industry: industryCtrl.text,
                            website: websiteCtrl.text,
                            description: currentDescription,
                          );
                          Navigator.pop(ctx);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }"""
text = text.replace(old_edit_company, new_edit_company)

# Add hints to other fields
text = text.replace("UJobTextField(label: 'Address*', controller: addressCtrl)", "UJobTextField(label: 'Address*', hint: 'e.g. 123 Business Street', controller: addressCtrl)")
text = text.replace("UJobTextField(label: 'City*', controller: cityCtrl)", "UJobTextField(label: 'City*', hint: 'e.g. London', controller: cityCtrl)")
text = text.replace("UJobTextField(label: 'Postcode / PIN', controller: postCtrl)", "UJobTextField(label: 'Postcode / PIN', hint: 'e.g. SW1A 1AA', controller: postCtrl)")

text = text.replace("UJobTextField(label: 'Contact Person Name*', controller: personCtrl)", "UJobTextField(label: 'Contact Person Name*', hint: 'e.g. Jane Smith', controller: personCtrl)")
text = text.replace("UJobTextField(label: 'Email Address', controller: emailCtrl)", "UJobTextField(label: 'Email Address', hint: 'e.g. hr@acme.com', controller: emailCtrl)")
text = text.replace("UJobTextField(label: 'Phone Number', controller: phoneCtrl)", "UJobTextField(label: 'Phone Number', hint: 'e.g. 7911 123456', controller: phoneCtrl)")

text = text.replace("hint: 'https://linkedin.com/company/acme'", "hint: 'e.g. https://linkedin.com/company/acme'")
text = text.replace("hint: 'https://facebook.com/acme'", "hint: 'e.g. https://facebook.com/acme'")

with open('lib/features/employer/company/company_profile_screen.dart', 'w') as f:
    f.write(text)
