import re

with open("lib/features/employer/company/company_profile_screen.dart", "r") as f:
    content = f.read()

old_method = """  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);

    try {
      final dio = ref.read(dioClientProvider).dio;

      // Build the JSON payload
      final Map<String, dynamic> payload = {
        "name": _nameController.text.trim(),
        "website": _websiteController.text.trim(),
        "about": _aboutController.text.trim(), // Sending plain text for now
        "contact_person": _contactNameController.text.trim(),
        "contact_email": _contactEmailController.text.trim(),
        "contact_phone":
            "$_selectedDialCode ${_contactPhoneController.text.trim()}",
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
      if (_selectedCountry != null) payload["country"] = _selectedCountry!;
      if (_selectedSize != null) payload["company_size"] = _selectedSize!;
      if (_selectedWorkType != null) payload["work_type"] = _selectedWorkType!;

      final res = await dio.put(Ep.employerMe, data: payload);

      final data = (res.data['data'] ?? res.data) as Map<String, dynamic>;
      if (data['companies'] != null && (data['companies'] as List).isNotEmpty) {
        final companyData = data['companies'][0] as Map<String, dynamic>;
        ref.read(companyProfileProvider.notifier).state =
            CompanyProfile.fromJson(companyData);
      }

      if (mounted) {
        UJobToast.success(context, "Profile updated successfully!");
      }
    } on DioException {
      if (mounted) {
        UJobToast.error(context, "Failed to update profile.");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }"""

new_method = """  Future<void> _updateProfile() async {
    // 1. Validate required fields
    if (_nameController.text.trim().isEmpty ||
        _selectedIndustryId == null ||
        _contactNameController.text.trim().isEmpty ||
        _contactEmailController.text.trim().isEmpty ||
        _contactPhoneController.text.trim().isEmpty) {
      UJobToast.error(context, "Please fill all required fields marked with *");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dio = ref.read(dioClientProvider).dio;

      // 2. Prepare HTML for 'About'
      String aboutHtml = _aboutController.text;
      if (aboutHtml.isNotEmpty && !aboutHtml.startsWith('<')) {
        final plainText = getPlainTextFromQuillJson(_aboutController.text);
        aboutHtml = '<p>${plainText.replaceAll('\\n', '<br>')}</p>';
      }

      // 3. Build the JSON payload
      final Map<String, dynamic> payload = {
        "name": _nameController.text.trim(),
        "about": aboutHtml,
        "website": _websiteController.text.trim(),
        "contact_person": _contactNameController.text.trim(),
        "contact_email": _contactEmailController.text.trim(),
        "contact_phone": "$_selectedDialCode ${_contactPhoneController.text.trim()}".trim(),
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

      if (mounted) {
        UJobToast.success(context, "Profile updated successfully!");
      }
    } on DioException {
      if (mounted) {
        UJobToast.error(context, "Failed to update profile.");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }"""

if old_method in content:
    content = content.replace(old_method, new_method)
    with open("lib/features/employer/company/company_profile_screen.dart", "w") as f:
        f.write(content)
    print("Success")
else:
    print("Failed to match")

