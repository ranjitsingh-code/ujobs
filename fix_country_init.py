import re

with open("lib/features/employer/company/company_profile_screen.dart", "r") as f:
    content = f.read()

old_init = """    _addressController.text = company.address ?? '';
    _cityController.text = company.city ?? '';
    _postcodeController.text = company.postcode ?? '';
    _selectedCountry = company.country;"""

new_init = """    _addressController.text = company.address ?? '';
    _cityController.text = company.city ?? '';
    _postcodeController.text = company.postcode ?? '';
    
    // Map ISO2 from backend back to Country Name for the Dropdown
    final countries = ref.read(countriesProvider).valueOrNull ?? [];
    _selectedCountry = countries.firstWhereOrNull((c) => c.iso2 == company.country)?.name ?? company.country;"""

if old_init in content:
    content = content.replace(old_init, new_init)
    with open("lib/features/employer/company/company_profile_screen.dart", "w") as f:
        f.write(content)
    print("Success")
else:
    print("Not found")

