import re

with open("lib/features/employer/company/company_profile_screen.dart", "r") as f:
    content = f.read()

# Import countries provider
if "import '../../../../core/providers/countries_provider.dart';" not in content:
    content = "import '../../../../core/providers/countries_provider.dart';\n" + content

# Watch countriesProvider in build method
content = content.replace("final categories = categoriesState.valueOrNull ?? [];", "final categories = categoriesState.valueOrNull ?? [];\n    final countriesState = ref.watch(countriesProvider);\n    final countries = countriesState.valueOrNull ?? [];")

# Update countries parameter in UJobPhoneNumberField
content = content.replace("countries: categoriesState.valueOrNull == null ? [] : ref.read(countriesProvider).valueOrNull ?? [],", "countries: countries,")

# Update Country dropdown to use dynamic countries and update dial code on change
dropdown_replacement = """                  UJobSearchableDropdownField<String>(
                    label: "Country",
                    value: _selectedCountry,
                    options: countries.map<(String, String)>((c) => (c.name, c.iso2)).toList(),
                    onChanged: (v) {
                      setState(() {
                        _selectedCountry = v;
                        final matchedCountry = countries.firstWhereOrNull((c) => c.iso2 == v);
                        if (matchedCountry != null && matchedCountry.phoneCode.isNotEmpty) {
                          _selectedDialCode = matchedCountry.phoneCode.startsWith('+') ? matchedCountry.phoneCode : '+' + matchedCountry.phoneCode;
                        }
                      });
                    },
                  ),"""

content = re.sub(r"                  UJobDropdownField<String>\(\s*label: \"Country\",\s*value: _selectedCountry,\s*options: const \[\s*\('United Kingdom', 'GB'\),\s*\('United States', 'US'\),\s*\],\s*onChanged: \(v\) => setState\(\(\) => _selectedCountry = v\),\s*\),", dropdown_replacement, content)

with open("lib/features/employer/company/company_profile_screen.dart", "w") as f:
    f.write(content)

