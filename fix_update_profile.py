import re

with open("lib/features/employer/company/company_profile_screen.dart", "r") as f:
    content = f.read()

old_payload = """      final payload = {
        "name": _nameController.text.trim(),
        "about": _aboutController.text.trim(),
        "website": _websiteController.text.trim(),
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

      if (_selectedIndustryId != null) {
        payload["industry_category_id"] =
            int.tryParse(_selectedIndustryId!) ?? _selectedIndustryId!;
      }
      if (_selectedCountry != null) payload["country"] = _selectedCountry!;
      if (_selectedSize != null) payload["company_size"] = _selectedSize!;
      if (_selectedWorkType != null) payload["work_type"] = _selectedWorkType!;"""

new_payload = """      String aboutHtml = _aboutController.text;
      if (aboutHtml.isNotEmpty && !aboutHtml.startsWith('<')) {
        // Basic fallback to wrap plain text in paragraph or convert Quill JSON to plain text
        final plainText = getPlainTextFromQuillJson(_aboutController.text);
        aboutHtml = '<p>${plainText.replaceAll('\\n', '<br>')}</p>';
      }

      final payload = {
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
        final countryIso = ref.read(countriesProvider).valueOrNull?.firstWhere((c) => c.name == _selectedCountry)?.iso2;
        if (countryIso != null) {
          payload["country"] = countryIso;
        }
      }
      if (_selectedSize != null) payload["company_size"] = _selectedSize!;
      if (_selectedWorkType != null) payload["work_type"] = _selectedWorkType!;"""

content = content.replace(old_payload, new_payload)

with open("lib/features/employer/company/company_profile_screen.dart", "w") as f:
    f.write(content)

