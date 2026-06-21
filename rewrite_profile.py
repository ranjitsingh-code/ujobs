with open('lib/features/employer/company/company_profile_screen.dart', 'w') as f:
    f.write("""import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/models/company_profile.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ujob_app_bar.dart';
import '../../../core/widgets/ujob_button.dart';
import '../../../core/widgets/ujob_text_field.dart';
import '../../../core/widgets/ujob_dropdown_field.dart';
import '../dashboard/employer_dashboard_provider.dart';

class CompanyProfileScreen extends ConsumerStatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  ConsumerState<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends ConsumerState<CompanyProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final company = ref.watch(companyProfileProvider);
    final completeness = ref.watch(companyProfileCompletenessProvider);
    
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const UJobAppBar(title: 'Company Profile'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CompanyProfileHeader(company: company, completeness: completeness),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SectionCard(
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
                  ),
                  SizedBox(height: 16.h),
                  _SectionCard(
                    title: 'Location',
                    icon: HugeIcons.strokeRoundedLocation01,
                    onEdit: () => _showEditLocation(context, ref, company),
                    child: Column(
                      children: [
                        _DetailRow(label: 'Address', value: company.address),
                        _DetailRow(label: 'City', value: company.city),
                        _DetailRow(label: 'Postcode', value: company.postcode),
                        _DetailRow(label: 'Country', value: company.country),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _SectionCard(
                    title: 'Contact Information',
                    icon: HugeIcons.strokeRoundedContactBook,
                    onEdit: () => _showEditContact(context, ref, company),
                    child: Column(
                      children: [
                        _DetailRow(label: 'Contact Person', value: company.contactPersonName),
                        _DetailRow(label: 'Email Address', value: company.contactEmail),
                        _DetailRow(label: 'Phone Number', value: company.contactPhone),
                        _DetailRow(label: 'Visibility', value: company.showContactInfo ? 'Visible to job seekers' : 'Hidden from public page'),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _SectionCard(
                    title: 'Social Links',
                    icon: HugeIcons.strokeRoundedLink01,
                    onEdit: () => _showEditSocialLinks(context, ref, company),
                    child: Column(
                      children: [
                        _DetailRow(label: 'LinkedIn', value: company.linkedInUrl),
                        _DetailRow(label: 'Facebook', value: company.facebookUrl),
                      ],
                    ),
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context, String title, Widget child) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
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
                    Text(title, style: AppText.heading3.copyWith(color: AppColors.text2)),
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
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditAboutCompany(BuildContext context, WidgetRef ref, CompanyProfile company) {
    final descCtrl = TextEditingController(text: company.description);
    _showBottomSheet(
      context,
      'About Company',
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UJobTextField(
            label: 'Description',
            hintText: 'Describe your company culture, mission...',
            controller: descCtrl,
            maxLines: 5,
          ),
          SizedBox(height: 16.h),
          UJobButton(
            label: 'Save',
            onTap: () {
              ref.read(companyProfileProvider.notifier).state = company.copyWith(description: descCtrl.text);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showEditCompanyInfo(BuildContext context, WidgetRef ref, CompanyProfile company) {
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
            items: const ['Software Development', 'Finance', 'Healthcare', 'Education'],
            onChanged: (val) => industryCtrl.text = val ?? '',
          ),
          SizedBox(height: 16.h),
          UJobDropdownField(
            label: 'Company Size',
            hint: 'Select size...',
            value: company.size?.isNotEmpty == true ? company.size : null,
            items: const ['1-10', '11-50', '51-200', '201-500', '500+'],
            onChanged: (val) => sizeCtrl.text = val ?? '',
          ),
          SizedBox(height: 16.h),
          UJobDropdownField(
            label: 'Work Type',
            hint: 'Select work type...',
            value: company.workType?.isNotEmpty == true ? company.workType : null,
            items: const ['Remote', 'Hybrid', 'On-site'],
            onChanged: (val) => workTypeCtrl.text = val ?? '',
          ),
          SizedBox(height: 16.h),
          UJobTextField(label: 'Website', hintText: 'https://acme.com', controller: websiteCtrl),
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
  }

  void _showEditLocation(BuildContext context, WidgetRef ref, CompanyProfile company) {
    final addressCtrl = TextEditingController(text: company.address);
    final cityCtrl = TextEditingController(text: company.city);
    final postCtrl = TextEditingController(text: company.postcode);
    final countryCtrl = TextEditingController(text: company.country);
    _showBottomSheet(
      context,
      'Location',
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UJobTextField(label: 'Address*', controller: addressCtrl),
          SizedBox(height: 16.h),
          UJobTextField(label: 'City*', controller: cityCtrl),
          SizedBox(height: 16.h),
          UJobTextField(label: 'Postcode / PIN', controller: postCtrl),
          SizedBox(height: 16.h),
          UJobDropdownField(
            label: 'Country*',
            hint: 'Select country...',
            value: company.country?.isNotEmpty == true ? company.country : null,
            items: const ['United Kingdom', 'United States', 'Canada', 'Australia'],
            onChanged: (val) => countryCtrl.text = val ?? '',
          ),
          SizedBox(height: 24.h),
          UJobButton(
            label: 'Save',
            onTap: () {
              ref.read(companyProfileProvider.notifier).state = company.copyWith(
                address: addressCtrl.text,
                city: cityCtrl.text,
                postcode: postCtrl.text,
                country: countryCtrl.text,
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showEditContact(BuildContext context, WidgetRef ref, CompanyProfile company) {
    final personCtrl = TextEditingController(text: company.contactPersonName);
    final emailCtrl = TextEditingController(text: company.contactEmail);
    final phoneCtrl = TextEditingController(text: company.contactPhone);
    bool showContact = company.showContactInfo;

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
                      Text('Contact Information', style: AppText.heading3.copyWith(color: AppColors.text2)),
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
                      UJobTextField(label: 'Contact Person Name*', controller: personCtrl),
                      SizedBox(height: 16.h),
                      UJobTextField(label: 'Email Address', controller: emailCtrl),
                      SizedBox(height: 16.h),
                      UJobTextField(label: 'Phone Number', controller: phoneCtrl),
                      SizedBox(height: 16.h),
                      Row(
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
                      ),
                      SizedBox(height: 24.h),
                      UJobButton(
                        label: 'Save',
                        onTap: () {
                          ref.read(companyProfileProvider.notifier).state = company.copyWith(
                            contactPersonName: personCtrl.text,
                            contactEmail: emailCtrl.text,
                            contactPhone: phoneCtrl.text,
                            showContactInfo: showContact,
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
  }

  void _showEditSocialLinks(BuildContext context, WidgetRef ref, CompanyProfile company) {
    final linkedinCtrl = TextEditingController(text: company.linkedInUrl);
    final fbCtrl = TextEditingController(text: company.facebookUrl);
    _showBottomSheet(
      context,
      'Social Links (Optional)',
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UJobTextField(label: 'LinkedIn', hintText: 'https://linkedin.com/company/acme', controller: linkedinCtrl),
          SizedBox(height: 16.h),
          UJobTextField(label: 'Facebook', hintText: 'https://facebook.com/acme', controller: fbCtrl),
          SizedBox(height: 24.h),
          UJobButton(
            label: 'Save',
            onTap: () {
              ref.read(companyProfileProvider.notifier).state = company.copyWith(
                linkedInUrl: linkedinCtrl.text,
                facebookUrl: fbCtrl.text,
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class CompanyProfileHeader extends StatelessWidget {
  final CompanyProfile company;
  final double completeness;
  const CompanyProfileHeader({super.key, required this.company, required this.completeness});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 80.r,
                height: 80.r,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppRadius.lg,
                ),
                child: Center(
                  child: Text(
                    company.name.isNotEmpty ? company.name[0].toUpperCase() : 'A',
                    style: AppText.heading1.copyWith(color: AppColors.white),
                  ),
                ),
              ),
              Positioned(
                bottom: -8.r,
                right: -8.r,
                child: Container(
                  width: 32.r,
                  height: 32.r,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border, width: 2),
                  ),
                  child: Center(
                    child: Icon(Icons.camera_alt_outlined, size: 16.r, color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            company.name,
            style: AppText.heading2.copyWith(color: AppColors.text2),
          ),
          if (company.city != null && company.country != null) ...[
            SizedBox(height: 4.h),
            Text(
              '${company.city}, ${company.country}',
              style: AppText.bodyMd.copyWith(color: AppColors.muted),
            ),
          ],
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: AppRadius.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile Completion',
                      style: AppText.label.copyWith(color: AppColors.white),
                    ),
                    Text(
                      '${(completeness * 100).toInt()}%',
                      style: AppText.label.copyWith(color: AppColors.white),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                ClipRRect(
                  borderRadius: AppRadius.pill,
                  child: LinearProgressIndicator(
                    value: completeness,
                    backgroundColor: AppColors.white.withValues(alpha: 0.2),
                    color: AppColors.white,
                    minHeight: 6.h,
                  ),
                ),
                if (completeness < 1.0) ...[
                  SizedBox(height: 8.h),
                  Text(
                    'Complete your profile to post jobs',
                    style: AppText.caption.copyWith(color: AppColors.white.withValues(alpha: 0.8)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final VoidCallback onEdit;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.xl,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: AppRadius.md,
                ),
                child: HugeIcon(icon: icon, color: AppColors.primary, size: 20.r),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(title, style: AppText.heading3.copyWith(color: AppColors.text2)),
              ),
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: const BoxDecoration(
                    color: AppColors.bg,
                    shape: BoxShape.circle,
                  ),
                  child: HugeIcon(icon: HugeIcons.strokeRoundedEdit02, color: AppColors.primary, size: 18.r),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String? value;

  const _DetailRow({required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = value == null || value!.isEmpty;
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(label, style: AppText.bodyMd.copyWith(color: AppColors.muted)),
          ),
          Expanded(
            child: Text(
              isEmpty ? 'Not set' : value!,
              style: AppText.bodyMd.copyWith(
                color: isEmpty ? AppColors.muted2 : AppColors.text2,
                fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
""")
