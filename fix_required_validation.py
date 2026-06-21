import re

with open('lib/features/employer/company/company_profile_screen.dart', 'r') as f:
    text = f.read()

# 1. Company Information: Add nameError validation
old_company_info_vars = """    String? currentLogo = company.logo;
    String? websiteError;"""

new_company_info_vars = """    String? currentLogo = company.logo;
    String? nameError;
    String? websiteError;"""
text = text.replace(old_company_info_vars, new_company_info_vars)

old_company_name_field = "UJobTextField(label: 'Company Name*', hint: 'e.g. Acme Ltd', controller: nameCtrl),"
new_company_name_field = "UJobTextField(label: 'Company Name*', hint: 'e.g. Acme Ltd', controller: nameCtrl, errorText: nameError),"
text = text.replace(old_company_name_field, new_company_name_field)

old_company_save = """                        onTap: () {
                          setState(() => websiteError = null);
                          
                          if (websiteCtrl.text.isNotEmpty) {"""
new_company_save = """                        onTap: () {
                          setState(() {
                            nameError = null;
                            websiteError = null;
                          });
                          
                          bool hasError = false;
                          if (nameCtrl.text.trim().isEmpty) {
                            setState(() => nameError = 'Company Name is required');
                            hasError = true;
                          }
                          
                          if (websiteCtrl.text.isNotEmpty) {"""
text = text.replace(old_company_save, new_company_save)

old_company_save_end = """                              return;
                            }
                          }
                          
                          ref.read(companyProfileProvider.notifier).state = company.copyWith("""
new_company_save_end = """                              hasError = true;
                            }
                          }
                          
                          if (hasError) return;
                          
                          ref.read(companyProfileProvider.notifier).state = company.copyWith("""
text = text.replace(old_company_save_end, new_company_save_end)


# 2. Location: Add addressError, cityError, countryError validation
old_location_vars = """    final addressCtrl = TextEditingController(text: company.address);
    final cityCtrl = TextEditingController(text: company.city);
    final postCtrl = TextEditingController(text: company.postcode);
    String? currentCountry = company.country?.isNotEmpty == true ? company.country : null;"""

new_location_vars = """    final addressCtrl = TextEditingController(text: company.address);
    final cityCtrl = TextEditingController(text: company.city);
    final postCtrl = TextEditingController(text: company.postcode);
    String? currentCountry = company.country?.isNotEmpty == true ? company.country : null;
    String? addressError;
    String? cityError;
    String? countryError;"""
text = text.replace(old_location_vars, new_location_vars)

old_address_field = "UJobTextField(label: 'Address*', hint: 'e.g. 123 Business Street', controller: addressCtrl)"
new_address_field = "UJobTextField(label: 'Address*', hint: 'e.g. 123 Business Street', controller: addressCtrl, errorText: addressError)"
text = text.replace(old_address_field, new_address_field)

old_city_field = "UJobTextField(label: 'City*', hint: 'e.g. London', controller: cityCtrl)"
new_city_field = "UJobTextField(label: 'City*', hint: 'e.g. London', controller: cityCtrl, errorText: cityError)"
text = text.replace(old_city_field, new_city_field)

old_country_field = """                      UJobDropdownField(
                        label: 'Country*',
                        hint: 'Select country...',
                        value: currentCountry,"""
new_country_field = """                      UJobDropdownField(
                        label: 'Country*',
                        hint: 'Select country...',
                        errorText: countryError,
                        value: currentCountry,"""
text = text.replace(old_country_field, new_country_field)

old_location_save = """                        onTap: () {
                          ref.read(companyProfileProvider.notifier).state = company.copyWith("""
new_location_save = """                        onTap: () {
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

                          ref.read(companyProfileProvider.notifier).state = company.copyWith("""
text = text.replace(old_location_save, new_location_save)


# 3. Contact Information: Add personError validation
old_contact_vars = """    final phoneCtrl = TextEditingController(text: company.contactPhone);
    bool showContact = company.showContactInfo;
    String? emailError;
    String? phoneError;"""

new_contact_vars = """    final phoneCtrl = TextEditingController(text: company.contactPhone);
    bool showContact = company.showContactInfo;
    String? personError;
    String? emailError;
    String? phoneError;"""
text = text.replace(old_contact_vars, new_contact_vars)

old_person_field = "UJobTextField(label: 'Contact Person Name*', hint: 'e.g. Jane Smith', controller: personCtrl)"
new_person_field = "UJobTextField(label: 'Contact Person Name*', hint: 'e.g. Jane Smith', controller: personCtrl, errorText: personError)"
text = text.replace(old_person_field, new_person_field)

old_contact_save = """                        onTap: () {
                          setState(() {
                            emailError = null;
                            phoneError = null;
                          });
                          
                          bool hasError = false;"""
new_contact_save = """                        onTap: () {
                          setState(() {
                            personError = null;
                            emailError = null;
                            phoneError = null;
                          });
                          
                          bool hasError = false;
                          if (personCtrl.text.trim().isEmpty) {
                            setState(() => personError = 'Contact Person Name is required');
                            hasError = true;
                          }"""
text = text.replace(old_contact_save, new_contact_save)

with open('lib/features/employer/company/company_profile_screen.dart', 'w') as f:
    f.write(text)
