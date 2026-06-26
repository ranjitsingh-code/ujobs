import re

with open("lib/features/employer/company/company_profile_screen.dart", "r") as f:
    content = f.read()

sync_replacement = """                    onCountryCodeChanged: (v) {
                      setState(() {
                        _selectedDialCode = v ?? '+44';
                        final matchedCountry = countries.firstWhereOrNull((c) {
                          final cDial = c.phoneCode.startsWith('+') ? c.phoneCode : '+' + c.phoneCode;
                          return cDial == _selectedDialCode;
                        });
                        if (matchedCountry != null) {
                          _selectedCountry = matchedCountry.name;
                        }
                      });
                    },"""

content = re.sub(r"                    onCountryCodeChanged: \(v\) => setState\(\(\) => _selectedDialCode = v \?\? '\+44'\),", sync_replacement, content)

with open("lib/features/employer/company/company_profile_screen.dart", "w") as f:
    f.write(content)

