with open('lib/features/employer/company/company_profile_screen.dart', 'r') as f:
    text = f.read()

# 1. Restructure the Cards in the Build method
old_cards = """                  _SectionCard(
                    title: 'About Company',
                    icon: HugeIcons.strokeRoundedInformationCircle,
                    onEdit: () => _showEditAboutCompany(context, ref, company),
                    child: Text(
                      company.description?.isNotEmpty == true ? company.description! : 'Describe your company culture, mission, and what makes you a great employer...',
                      style: AppText.bodyMd.copyWith(
                        color: company.description?.isNotEmpty == true ? AppColors.text2 : AppColors.muted2,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _SectionCard(
                    title: 'Company Information',
                    icon: HugeIcons.strokeRoundedBuilding03,
                    onEdit: () => _showEditCompanyInfo(context, ref, company),
                    child: Column(
                      children: [
                        _DetailRow(label: 'Company Name', value: company.name),
                        _DetailRow(label: 'Industry', value: company.industry),
                        _DetailRow(label: 'Company Size', value: company.size),
                        _DetailRow(label: 'Work Type', value: company.workType),
                        _DetailRow(label: 'Website', value: company.website),
                      ],
                    ),
                  ),"""

new_cards = """                  _SectionCard(
                    title: 'Company Information',
                    icon: HugeIcons.strokeRoundedBuilding03,
                    onEdit: () => _showEditCompanyInfo(context, ref, company),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DetailRow(label: 'Company Name', value: company.name),
                        _DetailRow(label: 'Industry', value: company.industry),
                        _DetailRow(label: 'Website', value: company.website),
                        SizedBox(height: 8.h),
                        Text('About Company', style: AppText.bodyMd.copyWith(color: AppColors.muted)),
                        SizedBox(height: 4.h),
                        Text(
                          company.description?.isNotEmpty == true ? company.description! : 'Not set',
                          style: AppText.bodyMd.copyWith(
                            color: company.description?.isNotEmpty == true ? AppColors.text2 : AppColors.muted2,
                            fontStyle: company.description?.isNotEmpty == true ? FontStyle.normal : FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _SectionCard(
                    title: 'Hiring Information',
                    icon: HugeIcons.strokeRoundedBriefcase01,
                    onEdit: () => _showEditHiringInfo(context, ref, company),
                    child: Column(
                      children: [
                        _DetailRow(label: 'Company Size', value: company.size),
                        _DetailRow(label: 'Work Type', value: company.workType),
                      ],
                    ),
                  ),"""
text = text.replace(old_cards, new_cards)

# 2. Add _showEditHiringInfo and modify _showEditCompanyInfo
# First, remove the old _showEditAboutCompany
start_idx = text.find("  void _showEditAboutCompany")
end_idx = text.find("  void _showEditCompanyInfo")
text = text[:start_idx] + text[end_idx:]

# Modify _showEditCompanyInfo
old_edit_company = """  void _showEditCompanyInfo(BuildContext context, WidgetRef ref, CompanyProfile company) {
    final nameCtrl = TextEditingController(text: company.name);
    final industryCtrl = TextEditingController(text: company.industry);
    final sizeCtrl = TextEditingController(text: company.size);
    final workTypeCtrl = TextEditingController(text: company.workType);
    final websiteCtrl = TextEditingController(text: company.website);
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
          UJobDropdownField(
            label: 'Company Size',
            hint: 'Select size...',
            value: company.size?.isNotEmpty == true ? company.size : null,
            options: const [('1-10', '1-10'), ('11-50', '11-50'), ('51-200', '51-200'), ('201-500', '201-500'), ('500+', '500+')],
            onChanged: (val) => sizeCtrl.text = val ?? '',
          ),
          SizedBox(height: 16.h),
          UJobDropdownField(
            label: 'Work Type',
            hint: 'Select work type...',
            value: company.workType?.isNotEmpty == true ? company.workType : null,
            options: const [('Remote', 'Remote'), ('Hybrid', 'Hybrid'), ('On-site', 'On-site')],
            onChanged: (val) => workTypeCtrl.text = val ?? '',
          ),
          SizedBox(height: 16.h),
          UJobTextField(label: 'Website', hint: 'https://acme.com', controller: websiteCtrl),
          SizedBox(height: 24.h),
          UJobButton(
            label: 'Save',
            onTap: () {
              ref.read(companyProfileProvider.notifier).state = company.copyWith(
                name: nameCtrl.text,
                industry: industryCtrl.text,
                size: sizeCtrl.text,
                workType: workTypeCtrl.text,
                website: websiteCtrl.text,
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
  }

  void _showEditHiringInfo(BuildContext context, WidgetRef ref, CompanyProfile company) {
    final sizeCtrl = TextEditingController(text: company.size);
    final workTypeCtrl = TextEditingController(text: company.workType);
    _showBottomSheet(
      context,
      'Hiring Information',
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UJobDropdownField(
            label: 'Company Size',
            hint: 'Select size...',
            value: company.size?.isNotEmpty == true ? company.size : null,
            options: const [('1-10', '1-10'), ('11-50', '11-50'), ('51-200', '51-200'), ('201-500', '201-500'), ('500+', '500+')],
            onChanged: (val) => sizeCtrl.text = val ?? '',
          ),
          SizedBox(height: 16.h),
          UJobDropdownField(
            label: 'Work Type',
            hint: 'Select work type...',
            value: company.workType?.isNotEmpty == true ? company.workType : null,
            options: const [('Remote', 'Remote'), ('Hybrid', 'Hybrid'), ('On-site', 'On-site')],
            onChanged: (val) => workTypeCtrl.text = val ?? '',
          ),
          SizedBox(height: 24.h),
          UJobButton(
            label: 'Save',
            onTap: () {
              ref.read(companyProfileProvider.notifier).state = company.copyWith(
                size: sizeCtrl.text,
                workType: workTypeCtrl.text,
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }"""
text = text.replace(old_edit_company, new_edit_company)

with open('lib/features/employer/company/company_profile_screen.dart', 'w') as f:
    f.write(text)
