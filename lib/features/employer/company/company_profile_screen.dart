import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../core/models/company_profile.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ujob_app_bar.dart';
import '../../../core/widgets/ujob_button.dart';
import '../../../core/widgets/ujob_text_field.dart';
import '../../../core/widgets/ujob_dropdown_field.dart';
import '../../../core/widgets/ujob_rich_text_editor.dart';
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
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CompanyProfileHeader(
              company: company, 
              completeness: completeness,
              onEditLogo: () => _showEditCompanyInfo(context, ref, company),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SectionCard(
                    title: 'Company Information',
                    subtitle: [company.name, company.industry, company.website].where((e) => e != null && e.isNotEmpty).join(' · '),
                    icon: HugeIcons.strokeRoundedBuilding03,
                    onEdit: () => _showEditCompanyInfo(context, ref, company),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DetailRow(label: context.l10n.companyNameLabel, value: company.name),
                        _DetailRow(label: context.l10n.industryLabel, value: company.industry),
                        _DetailRow(label: context.l10n.website, value: company.website),
                        SizedBox(height: 8.h),
                        Text('About Company', style: AppText.bodyMd.copyWith(color: AppColors.muted)),
                        SizedBox(height: 4.h),
                        Text(
                          company.description?.isNotEmpty == true ? getPlainTextFromQuillJson(company.description!) : 'Not set',
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
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
                    subtitle: [company.size, company.workType].where((e) => e != null && e.isNotEmpty).join(' · '),
                    icon: HugeIcons.strokeRoundedBriefcase01,
                    onEdit: () => _showEditHiringInfo(context, ref, company),
                    child: Column(
                      children: [
                        _DetailRow(label: context.l10n.companySizeLabel, value: company.size),
                        _DetailRow(label: context.l10n.workType, value: company.workType),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _SectionCard(
                    title: 'Location',
                    subtitle: [company.city, company.country].where((e) => e != null && e.isNotEmpty).join(' · '),
                    icon: HugeIcons.strokeRoundedLocation01,
                    onEdit: () => _showEditLocation(context, ref, company),
                    child: Column(
                      children: [
                        _DetailRow(label: context.l10n.address, value: company.address),
                        _DetailRow(label: context.l10n.city, value: company.city),
                        _DetailRow(label: context.l10n.postcode, value: company.postcode),
                        _DetailRow(label: context.l10n.country, value: company.country),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _SectionCard(
                    title: 'Contact Information',
                    subtitle: [company.contactPersonName, company.contactEmail].where((e) => e != null && e.isNotEmpty).join(' · '),
                    icon: HugeIcons.strokeRoundedContactBook,
                    onEdit: () => _showEditContact(context, ref, company),
                    child: Column(
                      children: [
                        _DetailRow(label: context.l10n.contactPerson, value: company.contactPersonName),
                        _DetailRow(label: context.l10n.emailLabel, value: company.contactEmail),
                        _DetailRow(label: context.l10n.phone, value: company.contactPhone),
                        _DetailRow(label: context.l10n.visibility, value: company.showContactInfo ? 'Visible to job seekers' : 'Hidden from public page'),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _SectionCard(
                    title: 'Social Links',
                    subtitle: [
                      if (company.linkedInUrl != null && company.linkedInUrl!.isNotEmpty) 'LinkedIn',
                      if (company.facebookUrl != null && company.facebookUrl!.isNotEmpty) 'Facebook',
                    ].join(' · '),
                    icon: HugeIcons.strokeRoundedLink01,
                    onEdit: () => _showEditSocialLinks(context, ref, company),
                    child: Column(
                      children: [
                        _DetailRow(label: context.l10n.linkedin, value: company.linkedInUrl),
                        _DetailRow(label: context.l10n.facebook, value: company.facebookUrl),
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

  void _showEditCompanyInfo(BuildContext context, WidgetRef ref, CompanyProfile company) {
    final nameCtrl = TextEditingController(text: company.name);
    String? currentIndustry = company.industry?.isNotEmpty == true ? company.industry : null;
    final websiteCtrl = TextEditingController(text: company.website);
    String currentDescription = company.description ?? '';
    String? currentLogo = company.logo;
    String? nameError;
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
                      UJobTextField(label: context.l10n.companyName, hint: context.l10n.egAcmeLtd, controller: nameCtrl, errorText: nameError),
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
                                      'PNG, JPG or SVG · Max 3 MB\nSquare recommended',
                                      style: AppText.caption.copyWith(color: AppColors.muted2, height: 1.2),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      UJobDropdownField(
                        label: context.l10n.industryLabel,
                        hint: context.l10n.selectIndustry,
                        value: currentIndustry,
                        options: const [('Software Development', 'Software Development'), ('Finance', 'Finance'), ('Healthcare', 'Healthcare'), ('Education', 'Education')],
                        onChanged: (val) {
                          setState(() {
                            currentIndustry = val;
                          });
                        },
                      ),
                      SizedBox(height: 16.h),
                      UJobTextField(
                        label: context.l10n.website, 
                        hint: context.l10n.egHttpsacmecom, 
                        controller: websiteCtrl,
                        errorText: websiteError,
                      ),
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
                          label: context.l10n.aboutCompany,
                          hint: context.l10n.tapToOpenEditor,
                          readOnly: true,
                          maxLines: 4,
                          minLines: 4,
                          controller: TextEditingController(text: getPlainTextFromQuillJson(currentDescription)),
                          labelTrailing: HugeIcon(
                            icon: HugeIcons.strokeRoundedMaximize01,
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
                        label: context.l10n.save,
                        onTap: () {
                          setState(() {
                            nameError = null;
                            websiteError = null;
                          });
                          
                          bool hasError = false;
                          if (nameCtrl.text.trim().isEmpty) {
                            setState(() => nameError = 'Company Name is required');
                            hasError = true;
                          }
                          
                          if (websiteCtrl.text.isNotEmpty) {
                            if (!websiteCtrl.text.startsWith('http://') && !websiteCtrl.text.startsWith('https://')) {
                              setState(() => websiteError = 'URL must start with http:// or https://');
                              hasError = true;
                            }
                          }
                          
                          if (hasError) return;
                          
                          ref.read(companyProfileProvider.notifier).state = company.copyWith(
                            name: nameCtrl.text,
                            logo: currentLogo,
                            industry: currentIndustry ?? '',
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
  }

  void _showEditHiringInfo(BuildContext context, WidgetRef ref, CompanyProfile company) {
    String? currentSize = company.size?.isNotEmpty == true ? company.size : null;
    String? currentWorkType = company.workType?.isNotEmpty == true ? company.workType : null;
    
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
                      Text('Hiring Information', style: AppText.heading3.copyWith(color: AppColors.text2)),
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
                      UJobDropdownField(
                        label: context.l10n.companySizeLabel,
                        hint: context.l10n.selectSize,
                        value: currentSize,
                        options: const [('1-10', '1-10'), ('11-50', '11-50'), ('51-200', '51-200'), ('201-500', '201-500'), ('500+', '500+')],
                        onChanged: (val) {
                          setState(() => currentSize = val);
                        },
                      ),
                      SizedBox(height: 16.h),
                      UJobDropdownField(
                        label: context.l10n.workType,
                        hint: context.l10n.selectWorkType,
                        value: currentWorkType,
                        options: const [('Remote', 'Remote'), ('Hybrid', 'Hybrid'), ('On-site', 'On-site')],
                        onChanged: (val) {
                          setState(() => currentWorkType = val);
                        },
                      ),
                      SizedBox(height: 24.h),
                      UJobButton(
                        label: context.l10n.save,
                        onTap: () {
                          ref.read(companyProfileProvider.notifier).state = company.copyWith(
                            size: currentSize ?? '',
                            workType: currentWorkType ?? '',
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

  void _showEditLocation(BuildContext context, WidgetRef ref, CompanyProfile company) {
    final addressCtrl = TextEditingController(text: company.address);
    final cityCtrl = TextEditingController(text: company.city);
    final postCtrl = TextEditingController(text: company.postcode);
    String? currentCountry = company.country?.isNotEmpty == true ? company.country : null;
    String? addressError;
    String? cityError;
    String? countryError;
    
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
                      Text('Location', style: AppText.heading3.copyWith(color: AppColors.text2)),
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
                      UJobTextField(label: context.l10n.address1, hint: context.l10n.eg123BusinessStreet, controller: addressCtrl, errorText: addressError),
                      SizedBox(height: 16.h),
                      UJobTextField(label: context.l10n.city1, hint: context.l10n.cityHint, controller: cityCtrl, errorText: cityError),
                      SizedBox(height: 16.h),
                      UJobTextField(label: context.l10n.postcodePin, hint: context.l10n.egSw1a1aa, controller: postCtrl),
                      SizedBox(height: 16.h),
                      UJobDropdownField(
                        label: context.l10n.country1,
                        hint: context.l10n.selectCountry,
                        errorText: countryError,
                        value: currentCountry,
                        options: const [('United Kingdom', 'United Kingdom'), ('United States', 'United States'), ('Canada', 'Canada'), ('Australia', 'Australia')],
                        onChanged: (val) {
                          setState(() => currentCountry = val);
                        },
                      ),
                      SizedBox(height: 24.h),
                      UJobButton(
                        label: context.l10n.save,
                        onTap: () {
                          setState(() {
                            addressError = null;
                            cityError = null;
                            countryError = null;
                          });
                          
                          bool hasError = false;
                          if (addressCtrl.text.trim().isEmpty) {
                            setState(() => addressError = 'Address is required');
                            hasError = true;
                          }
                          if (cityCtrl.text.trim().isEmpty) {
                            setState(() => cityError = 'City is required');
                            hasError = true;
                          }
                          if (currentCountry == null || currentCountry!.isEmpty) {
                            setState(() => countryError = 'Country is required');
                            hasError = true;
                          }
                          
                          if (hasError) return;

                          ref.read(companyProfileProvider.notifier).state = company.copyWith(
                            address: addressCtrl.text,
                            city: cityCtrl.text,
                            postcode: postCtrl.text,
                            country: currentCountry ?? '',
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

  void _showEditContact(BuildContext context, WidgetRef ref, CompanyProfile company) {
    final personCtrl = TextEditingController(text: company.contactPersonName);
    final emailCtrl = TextEditingController(text: company.contactEmail);
    final phoneCtrl = TextEditingController(text: company.contactPhone);
    bool showContact = company.showContactInfo;
    String? personError;
    String? emailError;
    String? phoneError;

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
                      UJobTextField(label: context.l10n.contactPersonName, hint: context.l10n.egJaneSmith, controller: personCtrl, errorText: personError),
                      SizedBox(height: 16.h),
                      UJobTextField(
                        label: context.l10n.emailLabel, 
                        hint: context.l10n.egHracmecom, 
                        controller: emailCtrl,
                        errorText: emailError,
                      ),
                      SizedBox(height: 16.h),
                      UJobTextField(
                        label: context.l10n.phone, 
                        hint: context.l10n.eg7911123456, 
                        controller: phoneCtrl,
                        errorText: phoneError,
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 16.h),
                      Container(
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
                      ),
                      SizedBox(height: 24.h),
                      UJobButton(
                        label: context.l10n.save,
                        onTap: () {
                          setState(() {
                            personError = null;
                            emailError = null;
                            phoneError = null;
                          });
                          
                          bool hasError = false;
                          if (personCtrl.text.trim().isEmpty) {
                            setState(() => personError = 'Contact Person Name is required');
                            hasError = true;
                          }
                          if (emailCtrl.text.isNotEmpty && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailCtrl.text)) {
                            setState(() => emailError = 'Please enter a valid email address');
                            hasError = true;
                          }
                          
                          if (phoneCtrl.text.isNotEmpty && !RegExp(r'^\+?[0-9\s\-\(\)]{7,}$').hasMatch(phoneCtrl.text)) {
                            setState(() => phoneError = 'Please enter a valid phone number');
                            hasError = true;
                          }
                          
                          if (hasError) return;
                          
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
    String? linkedinError;
    String? fbError;
    
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
                      Text('Social Links (Optional)', style: AppText.heading3.copyWith(color: AppColors.text2)),
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
                      UJobTextField(
                        label: context.l10n.linkedin, 
                        hint: context.l10n.egHttpslinkedincomcompanyacme, 
                        controller: linkedinCtrl,
                        errorText: linkedinError,
                      ),
                      SizedBox(height: 16.h),
                      UJobTextField(
                        label: context.l10n.facebook, 
                        hint: context.l10n.egHttpsfacebookcomacme, 
                        controller: fbCtrl,
                        errorText: fbError,
                      ),
                      SizedBox(height: 24.h),
                      UJobButton(
                        label: context.l10n.save,
                        onTap: () {
                          setState(() {
                            linkedinError = null;
                            fbError = null;
                          });
                          
                          bool hasError = false;
                          if (linkedinCtrl.text.isNotEmpty && !linkedinCtrl.text.startsWith('http://') && !linkedinCtrl.text.startsWith('https://')) {
                            setState(() => linkedinError = 'URL must start with http:// or https://');
                            hasError = true;
                          }
                          
                          if (fbCtrl.text.isNotEmpty && !fbCtrl.text.startsWith('http://') && !fbCtrl.text.startsWith('https://')) {
                            setState(() => fbError = 'URL must start with http:// or https://');
                            hasError = true;
                          }
                          
                          if (hasError) return;

                          ref.read(companyProfileProvider.notifier).state = company.copyWith(
                            linkedInUrl: linkedinCtrl.text,
                            facebookUrl: fbCtrl.text,
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
}

class CompanyProfileHeader extends StatelessWidget {
  final CompanyProfile company;
  final double completeness;
  final VoidCallback onEditLogo;
  const CompanyProfileHeader({super.key, required this.company, required this.completeness, required this.onEditLogo});

  @override
  Widget build(BuildContext context) {
    final percentCompleted = (completeness * 100).toInt();

    // Construct the subtitle (Industry · Size)
    List<String> subtitleParts = [];
    if (company.industry != null && company.industry!.isNotEmpty) subtitleParts.add(company.industry!);
    if (company.size != null && company.size!.isNotEmpty) subtitleParts.add(company.size!);
    final subtitle = subtitleParts.join(' · ');

    // Construct location
    String location = '';
    if (company.city != null && company.city!.isNotEmpty && company.country != null && company.country!.isNotEmpty) {
      location = '${company.city}, ${company.country}';
    } else if (company.city != null && company.city!.isNotEmpty) {
      location = company.city!;
    } else if (company.country != null && company.country!.isNotEmpty) {
      location = company.country!;
    }

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.authGradient,
      ),
      padding: EdgeInsets.fromLTRB(20.w, MediaQuery.of(context).padding.top + 24.h, 20.w, 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 72.r,
                    height: 72.r,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.xl,
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: company.logo != null && company.logo!.isNotEmpty
                        ? (company.logo!.startsWith('http') 
                            ? Image.network(company.logo!, fit: BoxFit.cover)
                            : Image.file(File(company.logo!), fit: BoxFit.cover))
                        : Center(
                            child: Text(
                              company.name.isNotEmpty ? company.name[0].toUpperCase() : 'A',
                              style: AppText.heading1.copyWith(color: AppColors.primary),
                            ),
                          ),
                  ),
                  Positioned(
                    bottom: -6.r,
                    right: -6.r,
                    child: GestureDetector(
                      onTap: onEditLogo,
                      child: Container(
                        width: 24.r,
                        height: 24.r,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: HugeIcon(icon: HugeIcons.strokeRoundedCamera01, size: 14.r, color: AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 16.w),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            company.name,
                            style: AppText.heading2.copyWith(color: AppColors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (completeness == 1.0) ...[
                          SizedBox(width: 6.w),
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedCheckmarkBadge01,
                            color: AppColors.white,
                            size: 20.r,
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4.h),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: AppText.caption.copyWith(color: AppColors.white.withValues(alpha: 0.8)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      Text(
                        'Industry & size not set',
                        style: AppText.caption.copyWith(color: AppColors.white.withValues(alpha: 0.5), fontStyle: FontStyle.italic),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    
                    SizedBox(height: 2.h),
                    if (location.isNotEmpty)
                      Text(
                        location,
                        style: AppText.caption.copyWith(color: AppColors.white.withValues(alpha: 0.8)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      Text(
                        'Location not set',
                        style: AppText.caption.copyWith(color: AppColors.white.withValues(alpha: 0.5), fontStyle: FontStyle.italic),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              // Settings Button
              IconButton(
                onPressed: () => context.push('/employer/settings'),
                tooltip: 'Settings',
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surface.withValues(alpha: 0.12),
                  fixedSize: Size(44.r, 44.r),
                ),
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedSettings01,
                  color: AppColors.surface,
                  size: 23.r,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          // Progress Section
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.15),
              borderRadius: AppRadius.lg,
              border: Border.all(color: AppColors.white.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile Completeness',
                      style: AppText.bodyMd.copyWith(color: AppColors.white),
                    ),
                    Text(
                      '${percentCompleted}%',
                      style: AppText.bodyBold.copyWith(color: AppColors.white),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
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
                  SizedBox(height: 12.h),
                  Text(
                    'Complete your profile to unlock all features',
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

class _SectionCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final dynamic icon;
  final Widget child;
  final VoidCallback onEdit;

  const _SectionCard({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.child,
    required this.onEdit,
  });

  @override
  State<_SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<_SectionCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.xl,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: _isExpanded ? 0.08 : 0.02),
            blurRadius: _isExpanded ? 24 : 10,
            offset: Offset(0, _isExpanded ? 8 : 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: _isExpanded 
                ? BorderRadius.vertical(top: Radius.circular(AppRadius.xl.topLeft.x))
                : AppRadius.xl,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.r, 20.r, 20.r, _isExpanded ? 0 : 20.r),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: AppRadius.md,
                    ),
                    child: HugeIcon(icon: widget.icon, color: AppColors.primary, size: 20.r),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(widget.title, style: AppText.bodyBold.copyWith(color: AppColors.text2)),
                        if (!_isExpanded && widget.subtitle != null && widget.subtitle!.isNotEmpty) ...[
                          SizedBox(height: 2.h),
                          Text(
                            widget.subtitle!,
                            style: AppText.caption.copyWith(color: AppColors.muted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ] else if (!_isExpanded) ...[
                          SizedBox(height: 2.h),
                          Text(
                            'Not set',
                            style: AppText.caption.copyWith(color: AppColors.muted2, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: widget.onEdit,
                    icon: HugeIcon(icon: HugeIcons.strokeRoundedEdit02, color: AppColors.primary, size: 14.r),
                    label: Text('Edit', style: AppText.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.125 : 0.0, // Rotates + to x
                    duration: const Duration(milliseconds: 300),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedAdd01,
                      color: AppColors.muted,
                      size: 20.r,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: EdgeInsets.fromLTRB(20.r, 0, 20.r, 20.r),
              child: widget.child,
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
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
