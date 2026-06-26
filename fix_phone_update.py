import re

with open("lib/core/widgets/ujob_phone_number_field.dart", "r") as f:
    content = f.read()

# Add didUpdateWidget
did_update_widget = """  @override
  void didUpdateWidget(UJobPhoneNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDialCode != oldWidget.initialDialCode) {
      final fallbackCountry = Country(id: 0, name: 'United Kingdom', iso2: 'GB', phoneCode: '44', flag: '🇬🇧');
      final activeCountries = widget.countries != null && widget.countries!.isNotEmpty ? widget.countries! : [fallbackCountry];
      
      String normalizedInitial = widget.initialDialCode ?? '+44';
      if (!normalizedInitial.startsWith('+')) normalizedInitial = '+' + normalizedInitial;

      setState(() {
        _selected = activeCountries.firstWhere(
          (c) {
            final cDial = c.phoneCode.startsWith('+') ? c.phoneCode : '+' + c.phoneCode;
            return cDial == normalizedInitial;
          },
          orElse: () => _selected,
        );
      });
    }
  }

"""

content = re.sub(r"  @override\n  void dispose\(\)", did_update_widget + "  @override\n  void dispose()", content)

with open("lib/core/widgets/ujob_phone_number_field.dart", "w") as f:
    f.write(content)

