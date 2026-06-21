with open('lib/features/employer/company/company_profile_screen.dart', 'r') as f:
    text = f.read()

old_location_save = """                        onTap: () {
                          ref.read(companyProfileProvider.notifier).state = company.copyWith(
                            address: addressCtrl.text,
                            city: cityCtrl.text,
                            postcode: postCtrl.text,
                            country: currentCountry ?? '',
                          );
                          Navigator.pop(ctx);
                        },"""

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

                          ref.read(companyProfileProvider.notifier).state = company.copyWith(
                            address: addressCtrl.text,
                            city: cityCtrl.text,
                            postcode: postCtrl.text,
                            country: currentCountry ?? '',
                          );
                          Navigator.pop(ctx);
                        },"""

text = text.replace(old_location_save, new_location_save)

with open('lib/features/employer/company/company_profile_screen.dart', 'w') as f:
    f.write(text)
