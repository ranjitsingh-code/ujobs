import os

file_path = "lib/features/employer/company/company_profile_screen.dart"

content = """import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../../core/providers/categories_provider.dart';
import '../../../../core/models/category.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:dio/dio.dart';

import '../../../core/models/company_profile.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ujob_button.dart';
import '../../../core/widgets/ujob_text_field.dart';
import '../../../core/widgets/ujob_dropdown_field.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/widgets/ujob_toast.dart';
import '../dashboard/employer_dashboard_provider.dart';

class CompanyProfileScreen extends ConsumerStatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  ConsumerState<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends ConsumerState<CompanyProfileScreen> {
  bool _isLoading = false;

  // Controllers for Company Information
  late TextEditingController _nameController;
  late TextEditingController _websiteController;
  late TextEditingController _aboutController;
  String? _selectedIndustryId;

  // Controllers for Contact Information
  late TextEditingController _contactNameController;
  late TextEditingController _contactEmailController;
  late TextEditingController _contactPhoneController;
  bool _showContactInfo = false;

  // Controllers for Location
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _postcodeController;
  String? _selectedCountry;

  // Controllers for Details
  String? _selectedSize;
  String? _selectedWorkType;
  late TextEditingController _linkedInController;
  late TextEditingController _facebookController;

  @override
  void initState() {
    super.initState();
    // Initialize empty controllers
    _nameController = TextEditingController();
    _websiteController = TextEditingController();
    _aboutController = TextEditingController();
    _contactNameController = TextEditingController();
    _contactEmailController = TextEditingController();
    _contactPhoneController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _postcodeController = TextEditingController();
    _linkedInController = TextEditingController();
    _facebookController = TextEditingController();

    // Populate data once tree is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final company = ref.read(companyProfileProvider);
      _nameController.text = company.name;
      _websiteController.text = company.website ?? '';
      
      // Strip simple HTML tags for the text field
      final exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
      _aboutController.text = (company.description ?? '').replaceAll(exp, '').trim();

      _selectedIndustryId = company.industryCategoryId;
      
      _contactNameController.text = company.contactPersonName ?? '';
      _contactEmailController.text = company.contactEmail ?? '';
      _contactPhoneController.text = company.contactPhone ?? '';
      _showContactInfo = company.showContactInfo;

      _addressController.text = company.address ?? '';
      _cityController.text = company.city ?? '';
      _postcodeController.text = company.postcode ?? '';
      _selectedCountry = company.country;

      _selectedSize = company.size;
      _selectedWorkType = company.workType;
      _linkedInController.text = company.linkedInUrl ?? '';
      _facebookController.text = company.facebookUrl ?? '';
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _websiteController.dispose();
    _aboutController.dispose();
    _contactNameController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postcodeController.dispose();
    _linkedInController.dispose();
    _facebookController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    
    try {
      final dio = ref.read(dioClientProvider).dio;
      
      // Build the JSON payload
      final payload = {
        "name": _nameController.text.trim(),
        "website": _websiteController.text.trim(),
        "about": _aboutController.text.trim(), // Sending plain text for now
        "contact_person": _contactNameController.text.trim(),
        "contact_email": _contactEmailController.text.trim(),
        "contact_phone": _contactPhoneController.text.trim(),
        "show_contact_info": _showContactInfo,
        "address": _addressController.text.trim(),
        "city": _cityController.text.trim(),
        "zip_code": _postcodeController.text.trim(),
        "linkedin_url": _linkedInController.text.trim(),
        "facebook_url": _facebookController.text.trim(),
      };
      
      if (_selectedIndustryId != null) payload["industry_category_id"] = _selectedIndustryId!;
      if (_selectedCountry != null) payload["country"] = _selectedCountry!;
      if (_selectedSize != null) payload["company_size"] = _selectedSize!;
      if (_selectedWorkType != null) payload["work_type"] = _selectedWorkType!;

      final res = await dio.put(
        Ep.employerMe,
        data: payload,
      );
      
      final data = (res.data['data'] ?? res.data) as Map<String, dynamic>;
      if (data['companies'] != null && (data['companies'] as List).isNotEmpty) {
        final companyData = data['companies'][0] as Map<String, dynamic>;
        ref.read(companyProfileProvider.notifier).state = CompanyProfile.fromJson(companyData);
      }
      
      if (mounted) {
        UJobToast.showSuccess(context: context, message: "Profile updated successfully!");
      }
    } on DioException catch (e) {
      if (mounted) {
        UJobToast.showError(context: context, message: "Failed to update profile.");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildSection({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        leading: Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: HugeIcon(icon: icon, color: AppColors.primary, size: 20.r),
        ),
        title: Text(title, style: AppText.heading3),
        childrenPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final company = ref.watch(companyProfileProvider);
    final categoriesState = ref.watch(categoriesProvider);
    final categories = categoriesState.valueOrNull ?? [];

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: AppColors.text, size: 24.r),
          onPressed: () => context.pop(),
        ),
        title: Text(context.l10n.companyProfile, style: AppText.heading2),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Company Info Form
            _buildSection(
              title: "Company Information",
              icon: HugeIcons.strokeRoundedBuilding03,
              children: [
                UJobTextField(
                  label: context.l10n.companyNameLabel,
                  controller: _nameController,
                ),
                SizedBox(height: 16.h),
                UJobDropdownField<String>(
                  label: context.l10n.industryLabel,
                  value: _selectedIndustryId,
                  options: categories.map<(String, String)>((c) => (c.name, c.id.toString())).toList(),
                  onChanged: (v) => setState(() => _selectedIndustryId = v),
                ),
                SizedBox(height: 16.h),
                UJobTextField(
                  label: context.l10n.website,
                  controller: _websiteController,
                ),
                SizedBox(height: 16.h),
                UJobTextField(
                  label: "About Company",
                  controller: _aboutController,
                  maxLines: 4,
                ),
              ],
            ),

            // Contact Info
            _buildSection(
              title: "Contact Person",
              icon: HugeIcons.strokeRoundedUserGroup,
              children: [
                UJobTextField(
                  label: "Contact Name",
                  controller: _contactNameController,
                ),
                SizedBox(height: 16.h),
                UJobTextField(
                  label: "Contact Email",
                  controller: _contactEmailController,
                ),
                SizedBox(height: 16.h),
                UJobTextField(
                  label: "Contact Phone",
                  controller: _contactPhoneController,
                ),
                SizedBox(height: 16.h),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text("Show contact info to job seekers", style: AppText.body),
                  activeColor: AppColors.primary,
                  value: _showContactInfo,
                  onChanged: (v) => setState(() => _showContactInfo = v),
                ),
              ],
            ),

            // Location
            _buildSection(
              title: "Location",
              icon: HugeIcons.strokeRoundedLocation01,
              children: [
                UJobTextField(
                  label: "Address",
                  controller: _addressController,
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: UJobTextField(
                        label: "City",
                        controller: _cityController,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: UJobTextField(
                        label: "Postcode",
                        controller: _postcodeController,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                UJobDropdownField<String>(
                  label: "Country",
                  value: _selectedCountry,
                  options: const [
                    ('United Kingdom', 'GB'),
                    ('United States', 'US'),
                  ],
                  onChanged: (v) => setState(() => _selectedCountry = v),
                ),
              ],
            ),

            // Details
            _buildSection(
              title: "Other Details",
              icon: HugeIcons.strokeRoundedInformationCircle,
              children: [
                UJobDropdownField<String>(
                  label: "Company Size",
                  value: _selectedSize,
                  options: const [
                    ('1-10 Employees', 'size_1_10'),
                    ('11-50 Employees', 'size_11_50'),
                    ('51-200 Employees', 'size_51_200'),
                    ('201-500 Employees', 'size_201_500'),
                    ('501-1000 Employees', 'size_501_1000'),
                    ('1000+ Employees', 'size_1000_plus'),
                  ],
                  onChanged: (v) => setState(() => _selectedSize = v),
                ),
                SizedBox(height: 16.h),
                UJobDropdownField<String>(
                  label: "Work Type",
                  value: _selectedWorkType,
                  options: const [
                    ('On-site', 'onsite'),
                    ('Hybrid', 'hybrid'),
                    ('Remote', 'remote'),
                  ],
                  onChanged: (v) => setState(() => _selectedWorkType = v),
                ),
                SizedBox(height: 16.h),
                UJobTextField(
                  label: "LinkedIn URL",
                  controller: _linkedInController,
                ),
                SizedBox(height: 16.h),
                UJobTextField(
                  label: "Facebook URL",
                  controller: _facebookController,
                ),
              ],
            ),
            
            SizedBox(height: 24.h),
            
            UJobButton(
              text: "Update Profile",
              isLoading: _isLoading,
              onPressed: _updateProfile,
            ),
            
            SizedBox(height: 48.h),
          ],
        ),
      ),
    );
  }
}
"""

with open(file_path, "w") as f:
    f.write(content)

