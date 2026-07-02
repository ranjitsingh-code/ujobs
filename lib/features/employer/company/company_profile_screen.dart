import 'package:collection/collection.dart';
import '../../../../core/providers/countries_provider.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../../core/providers/categories_provider.dart';

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
import '../../../core/widgets/ujob_rich_text_editor.dart';
import '../../../core/widgets/ujob_dropdown_field.dart';
import '../../../core/widgets/ujob_phone_number_field.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/widgets/ujob_toast.dart';
import '../dashboard/employer_dashboard_provider.dart';

class CompanyProfileScreen extends ConsumerStatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  ConsumerState<CompanyProfileScreen> createState() =>
      _CompanyProfileScreenState();
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
  String _selectedDialCode = '+44';

  // Controllers for Location
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _postcodeController;
  String? _selectedCountry;

  // Controllers for Details
  String? _selectedSize;
  String? _selectedWorkType;
  bool _showContactInfo = false;
  int _refreshKey = 0;
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
    // Populate data once tree is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initFromProvider();
    });
  }

  void _initFromProvider() {
    final company = ref.read(companyProfileProvider);
    _nameController.text = company.name;
    _websiteController.text = company.website ?? '';

    // Strip simple HTML tags for the text field
    final exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    _aboutController.text = (company.description ?? '')
        .replaceAll(exp, '')
        .trim();

    _selectedIndustryId = company.industryCategoryId;

    _contactNameController.text = company.contactPersonName ?? '';
    _contactEmailController.text = company.contactEmail ?? '';

    final fullPhone = company.contactPhone ?? '';
    if (fullPhone.startsWith('+') && fullPhone.contains(' ')) {
      final parts = fullPhone.split(' ');
      _selectedDialCode = parts[0];
      _contactPhoneController.text = parts.sublist(1).join(' ');
    } else {
      _contactPhoneController.text = fullPhone;
    }

    _addressController.text = company.address ?? '';
    _cityController.text = company.city ?? '';
    _postcodeController.text = company.postcode ?? '';
    
    // Map ISO2 from backend back to Country Name for the Dropdown
    final countries = ref.read(countriesProvider).valueOrNull ?? [];
    _selectedCountry = countries.firstWhereOrNull((c) => c.iso2 == company.country)?.name ?? company.country;

    _selectedSize = company.size;
    _selectedWorkType = company.workType;
    _linkedInController.text = company.linkedInUrl ?? '';
    _facebookController.text = company.facebookUrl ?? '';
    _showContactInfo = company.showContactInfo;
    if (mounted) setState(() {});
  }

  Future<void> _onRefresh() async {
    try {
      final dio = ref.read(dioClientProvider).dio;
      final res = await dio.get(Ep.employerMe);
      final data = (res.data['data'] ?? res.data) as Map<String, dynamic>;
      if (data['companies'] != null && (data['companies'] as List).isNotEmpty) {
        final companyData = data['companies'][0] as Map<String, dynamic>;
        ref.read(companyProfileProvider.notifier).state =
            CompanyProfile.fromJson(companyData);
        _initFromProvider();
        if (mounted) setState(() => _refreshKey++);
      }
    } catch (e) {
      // Ignore
    }
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
    // 1. Validate required fields
    if (_nameController.text.trim().isEmpty ||
        _selectedIndustryId == null ||
        _contactNameController.text.trim().isEmpty ||
        _contactEmailController.text.trim().isEmpty ||
        _contactPhoneController.text.trim().isEmpty) {
      UJobToast.error(context, 'Validation Error', sub: 'Please fill all required fields marked with *');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dio = ref.read(dioClientProvider).dio;

      // 2. Prepare HTML for 'About'
      String aboutHtml = _aboutController.text;
      if (aboutHtml.isNotEmpty && !aboutHtml.startsWith('<')) {
        final plainText = getPlainTextFromQuillJson(_aboutController.text);
        aboutHtml = '<p>${plainText.replaceAll('\n', '<br>')}</p>';
      }

      // 3. Build the JSON payload
      final Map<String, dynamic> payload = {
        "name": _nameController.text.trim(),
        "about": aboutHtml,
        "website": _websiteController.text.trim(),
        "contact_person": _contactNameController.text.trim(),
        "contact_email": _contactEmailController.text.trim(),
        "contact_phone": "$_selectedDialCode ${_contactPhoneController.text.trim()}".trim(),
        "show_contact_info": _showContactInfo,
        "address": _addressController.text.trim(),
        "city": _cityController.text.trim(),
        "zip_code": _postcodeController.text.trim(),
        "linkedin_url": _linkedInController.text.trim(),
        "facebook_url": _facebookController.text.trim(),
      };

      if (_selectedIndustryId != null) {
        payload["industry_category_id"] =
            int.tryParse(_selectedIndustryId!) ?? _selectedIndustryId!;
      }
      if (_selectedCountry != null) {
        final countryIso = ref.read(countriesProvider).valueOrNull?.firstWhereOrNull((c) => c.name == _selectedCountry)?.iso2;
        if (countryIso != null) {
          payload["country"] = countryIso;
        }
      }
      if (_selectedSize != null) payload["company_size"] = _selectedSize!;
      if (_selectedWorkType != null) payload["work_type"] = _selectedWorkType!;

      final res = await dio.put(Ep.employerMe, data: payload);

      final data = (res.data['data'] ?? res.data) as Map<String, dynamic>;
      if (data['companies'] != null && (data['companies'] as List).isNotEmpty) {
        final companyData = data['companies'][0] as Map<String, dynamic>;
        ref.read(companyProfileProvider.notifier).state =
            CompanyProfile.fromJson(companyData);
      }

      // 4. Reload data explicitly
      await _onRefresh();
      
      // Invalidate dashboard provider so it re-fetches the new completion %
      ref.invalidate(employerDashboardProvider);

      if (mounted) {
        UJobToast.success(context, 'Success', sub: 'Profile updated successfully!');
      }
    } on DioException {
      if (mounted) {
        UJobToast.error(context, 'Update Failed', sub: 'Failed to update profile. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String? sizeLabel = const [
      ('1-10 employees', 'size_1_10'),
      ('11-50 employees', 'size_11_50'),
      ('51-200 employees', 'size_51_200'),
      ('201-500 employees', 'size_201_500'),
      ('501-1000 employees', 'size_501_1000'),
      ('1000+ employees', 'size_1000_plus'),
    ].where((e) => e.$2 == _selectedSize).firstOrNull?.$1;

    String? workTypeLabel = const [
      ('On-site', 'onsite'),
      ('Hybrid', 'hybrid'),
      ('Remote', 'remote'),
    ].where((e) => e.$2 == _selectedWorkType).firstOrNull?.$1;

    String? hiringSubtitle;
    if (sizeLabel != null && workTypeLabel != null) {
      hiringSubtitle = '$sizeLabel • $workTypeLabel';
    } else if (sizeLabel != null) {
      hiringSubtitle = sizeLabel;
    } else if (workTypeLabel != null) {
      hiringSubtitle = workTypeLabel;
    }

    final categoriesState = ref.watch(categoriesProvider);
    final categories = categoriesState.valueOrNull ?? [];
    
    ref.listen(countriesProvider, (prev, next) {
      if (next.hasValue && next.value != null && next.value!.isNotEmpty) {
        if (_selectedCountry != null && _selectedCountry!.length == 2) {
          final match = next.value!.firstWhereOrNull((c) => c.iso2 == _selectedCountry);
          if (match != null) {
            setState(() {
              _selectedCountry = match.name;
            });
          }
        }
      }
    });
    
    final countriesState = ref.watch(countriesProvider);
    final countries = countriesState.valueOrNull ?? [];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          child: Column(
            key: ValueKey(_refreshKey),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CompanyProfileHeader(
                company: ref.watch(companyProfileProvider),
                completeness: ref.watch(companyProfileCompletenessProvider),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Company Info Form
                    _SectionCard(
                      title: "Company Information",
                      subtitle: _nameController.text.isNotEmpty
                          ? _nameController.text
                          : null,
                      icon: HugeIcons.strokeRoundedBuilding03,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          UJobTextField(
                            label: context.l10n.companyNameLabel,
                            isRequired: true,
                            readOnly: true,
                            controller: _nameController,
                            suffix: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedLock,
                                color: AppColors.muted,
                                size: 20.r,
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          UJobDropdownField<String>(
                            label: context.l10n.industryLabel,
                            isRequired: true,
                            value: _selectedIndustryId,
                            options: categories
                                .map<(String, String)>(
                                  (c) => (c.name, c.id.toString()),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedIndustryId = v),
                          ),
                          SizedBox(height: 16.h),
                          UJobTextField(
                            label: context.l10n.website,
                            controller: _websiteController,
                          ),
                          SizedBox(height: 16.h),
                          UJobTextField(
                            label: "About Company",
                            isRequired: true,
                            hint: context.l10n.tapToOpenEditor,
                            readOnly: true,
                            maxLines: 4,
                            minLines: 4,
                            controller: TextEditingController(
                              text: getPlainTextFromQuillJson(
                                _aboutController.text,
                              ),
                            ),
                            labelTrailing: HugeIcon(
                              icon: HugeIcons.strokeRoundedMaximize01,
                              color: AppColors.primary,
                              size: 20.r,
                            ),
                            onTap: () => showUJobRichTextEditor(
                              context: context,
                              title: 'About Company',
                              initialValue: _aboutController.text,
                              onSave: (val) {
                                setState(() {
                                  _aboutController.text = val;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Contact Info
                    _SectionCard(
                      title: "Contact Information",
                      subtitle: _contactNameController.text.isNotEmpty
                          ? _contactNameController.text
                          : "Contact Details",
                      icon: HugeIcons.strokeRoundedUserGroup,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          UJobTextField(
                            label: "Contact Name",
                            isRequired: true,
                            controller: _contactNameController,
                          ),
                          SizedBox(height: 16.h),
                          UJobTextField(
                            label: "Contact Email",
                            isRequired: true,
                            controller: _contactEmailController,
                          ),
                          SizedBox(height: 16.h),
                          UJobPhoneNumberField(
                            label: "Contact Phone",
                            isRequired: true,
                            countries: countries,
                            controller: _contactPhoneController,
                            initialDialCode: _selectedDialCode,
                            onCountryCodeChanged: (v) {
                              setState(() {
                                _selectedDialCode = v ?? '+44';
                                final matchedCountry = countries
                                    .firstWhereOrNull((c) {
                                      final cDial = c.phoneCode.startsWith('+')
                                          ? c.phoneCode
                                          : '+${c.phoneCode}';
                                      return cDial == _selectedDialCode;
                                    });
                                if (matchedCountry != null) {
                                  _selectedCountry = matchedCountry.name;
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    // Location
                    _SectionCard(
                      title: "Location",
                      subtitle: _cityController.text.isNotEmpty
                          ? _cityController.text
                          : null,
                      icon: HugeIcons.strokeRoundedLocation01,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          UJobTextField(
                            label: "Address",
                            isRequired: true,
                            controller: _addressController,
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              Expanded(
                                child: UJobTextField(
                                  label: "City",
                                  isRequired: true,
                                  controller: _cityController,
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: UJobTextField(
                                  label: "Postcode",
                                  isRequired: true,
                                  controller: _postcodeController,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          UJobCountryDropdown(
                            isRequired: true,
                            value: _selectedCountry,
                            onChanged: (v) {
                              setState(() {
                                _selectedCountry = v;
                                final matchedCountry = countries
                                    .firstWhereOrNull((c) => c.name == v);
                                if (matchedCountry != null &&
                                    matchedCountry.phoneCode.isNotEmpty) {
                                  _selectedDialCode =
                                      matchedCountry.phoneCode.startsWith('+')
                                      ? matchedCountry.phoneCode
                                      : '+${matchedCountry.phoneCode}';
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    // Details
                    _SectionCard(
                      title: "Hiring Information",
                      subtitle: hiringSubtitle,
                      icon: HugeIcons.strokeRoundedInformationCircle,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          UJobDropdownField<String>(
                            label: "Company Size",
                            isRequired: true,
                            value: _selectedSize,
                            options: const [
                              ('1-10 employees', 'size_1_10'),
                              ('11-50 employees', 'size_11_50'),
                              ('51-200 employees', 'size_51_200'),
                              ('201-500 employees', 'size_201_500'),
                              ('501-1000 employees', 'size_501_1000'),
                              ('1000+ employees', 'size_1000_plus'),
                            ],
                            onChanged: (v) => setState(() => _selectedSize = v),
                          ),
                          SizedBox(height: 16.h),
                          UJobDropdownField<String>(
                            label: "Work Type",
                            isRequired: true,
                            value: _selectedWorkType,
                            options: const [
                              ('On-site', 'onsite'),
                              ('Hybrid', 'hybrid'),
                              ('Remote', 'remote'),
                            ],
                            onChanged: (v) =>
                                setState(() => _selectedWorkType = v),
                          ),
                        ],
                      ),
                    ),

                    // Social Links
                    _SectionCard(
                      title: "Social Links (Optional)",
                      subtitle:
                          _linkedInController.text.isNotEmpty ||
                              _facebookController.text.isNotEmpty
                          ? "Links added"
                          : null,
                      icon: HugeIcons.strokeRoundedLink01,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
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
                    ),

                    SizedBox(height: 24.h),

                    UJobButton(
                      label: "Update Profile",
                      isLoading: _isLoading,
                      onTap: _updateProfile,
                    ),

                    SizedBox(height: 48.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final dynamic icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  State<_SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<_SectionCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.xl,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(
              alpha: _isExpanded ? 0.08 : 0.02,
            ),
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
                ? BorderRadius.vertical(
                    top: Radius.circular(AppRadius.xl.topLeft.x),
                  )
                : AppRadius.xl,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20.r,
                20.r,
                20.r,
                _isExpanded ? 0 : 20.r,
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: AppRadius.md,
                    ),
                    child: HugeIcon(
                      icon: widget.icon,
                      color: AppColors.primary,
                      size: 20.r,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: AppText.bodyBold.copyWith(
                            color: AppColors.text2,
                          ),
                        ),
                        if (!_isExpanded &&
                            widget.subtitle != null &&
                            widget.subtitle!.isNotEmpty) ...[
                          SizedBox(height: 2.h),
                          Text(
                            widget.subtitle!,
                            style: AppText.caption.copyWith(
                              color: AppColors.muted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ] else if (!_isExpanded) ...[
                          SizedBox(height: 2.h),
                          Text(
                            'Not set',
                            style: AppText.caption.copyWith(
                              color: AppColors.muted2,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
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
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}

class CompanyProfileHeader extends ConsumerWidget {
  final CompanyProfile company;
  final double completeness;
  const CompanyProfileHeader({
    super.key,
    required this.company,
    required this.completeness,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final percentCompleted = (completeness * 100).toInt();

    // Get real country name instead of ISO2
    final countries = ref.read(countriesProvider).valueOrNull ?? [];
    final countryName = countries.firstWhereOrNull((c) => c.iso2 == company.country)?.name ?? company.country;

    // Construct the subtitle (Industry)
    List<String> subtitleParts = [];
    if (company.industry != null && company.industry!.isNotEmpty) {
      subtitleParts.add(company.industry!);
    }
    final subtitle = subtitleParts.join(' · ');

    // Construct location
    String location = '';
    if (company.city != null &&
        company.city!.isNotEmpty &&
        countryName != null &&
        countryName.isNotEmpty) {
      location = '${company.city}, $countryName';
    } else if (company.city != null && company.city!.isNotEmpty) {
      location = company.city!;
    } else if (countryName != null && countryName.isNotEmpty) {
      location = countryName;
    }

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.authGradient),
      padding: EdgeInsets.fromLTRB(
        20.w,
        MediaQuery.of(context).padding.top + 24.h,
        20.w,
        32.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
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
                          company.name.isNotEmpty
                              ? company.name[0].toUpperCase()
                              : 'A',
                          style: AppText.heading1.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
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
                            style: AppText.heading2.copyWith(
                              color: AppColors.white,
                            ),
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
                        style: AppText.caption.copyWith(
                          color: AppColors.white.withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      Text(
                        'Industry & size not set',
                        style: AppText.caption.copyWith(
                          color: AppColors.white.withValues(alpha: 0.5),
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    SizedBox(height: 2.h),
                    if (location.isNotEmpty)
                      Text(
                        location,
                        style: AppText.caption.copyWith(
                          color: AppColors.white.withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      Text(
                        'Location not set',
                        style: AppText.caption.copyWith(
                          color: AppColors.white.withValues(alpha: 0.5),
                          fontStyle: FontStyle.italic,
                        ),
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
                      '$percentCompleted%',
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
                    style: AppText.caption.copyWith(
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
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
