with open('lib/features/employer/company/company_profile_screen.dart', 'r') as f:
    text = f.read()

bad_hiring_save = """                        onTap: () {
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
                            size: currentSize ?? '',
                            workType: currentWorkType ?? '',
                          );
                          Navigator.pop(ctx);
                        },"""

good_hiring_save = """                        onTap: () {
                          ref.read(companyProfileProvider.notifier).state = company.copyWith(
                            size: currentSize ?? '',
                            workType: currentWorkType ?? '',
                          );
                          Navigator.pop(ctx);
                        },"""

text = text.replace(bad_hiring_save, good_hiring_save)

with open('lib/features/employer/company/company_profile_screen.dart', 'w') as f:
    f.write(text)
