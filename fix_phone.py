import re

with open("lib/core/widgets/ujob_phone_number_field.dart", "r") as f:
    content = f.read()

# Remove _Country and _kCountries
content = re.sub(r"class _Country \{[\s\S]*?\}\n\nconst _kCountries = \[[\s\S]*?\];\n\n", "", content)

# Add isRequired and countries
content = re.sub(r"class UJobPhoneNumberField extends StatefulWidget \{\n  final String label;\n", r"class UJobPhoneNumberField extends StatefulWidget {\n  final String label;\n  final bool isRequired;\n  final List<Country>? countries;\n", content)
content = re.sub(r"  const UJobPhoneNumberField\(\{\n    required this.label,\n", r"  const UJobPhoneNumberField({\n    required this.label,\n    this.isRequired = false,\n    this.countries,\n", content)

# Update State variables
content = content.replace("late _Country _selected;", "late Country _selected;")
content = content.replace("final _Country selected;", "final Country selected;")
content = content.replace("final ValueChanged<_Country> onSelect;", "final ValueChanged<Country> onSelect;")
content = content.replace("List<_Country> _filtered = _kCountries;", "late List<Country> _filtered;")

# Update initState and add didUpdateWidget
init_code = """  @override
  void initState() {
    super.initState();
    final fallback = Country(id: 0, name: 'United Kingdom', iso2: 'GB', phoneCode: '44', flag: '🇬🇧');
    final active = widget.countries != null && widget.countries!.isNotEmpty ? widget.countries! : [fallback];
    
    String norm = widget.initialDialCode ?? '+44';
    if (!norm.startsWith('+')) norm = '+' + norm;

    _selected = active.firstWhere(
      (c) {
        final cDial = c.phoneCode.startsWith('+') ? c.phoneCode : '+' + c.phoneCode;
        return cDial == norm;
      },
      orElse: () => active.first,
    );
    _focusNode.addListener(() {
      if (mounted) setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void didUpdateWidget(UJobPhoneNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDialCode != oldWidget.initialDialCode || widget.countries != oldWidget.countries) {
      final fallback = Country(id: 0, name: 'United Kingdom', iso2: 'GB', phoneCode: '44', flag: '🇬🇧');
      final active = widget.countries != null && widget.countries!.isNotEmpty ? widget.countries! : [fallback];
      
      String norm = widget.initialDialCode ?? '+44';
      if (!norm.startsWith('+')) norm = '+' + norm;

      setState(() {
        _selected = active.firstWhere(
          (c) {
            final cDial = c.phoneCode.startsWith('+') ? c.phoneCode : '+' + c.phoneCode;
            return cDial == norm;
          },
          orElse: () => _selected,
        );
      });
    }
  }"""
content = re.sub(r"  @override\n  void initState\(\) \{[\s\S]*?\}\n", init_code + "\n", content, count=1)

# Fix widget properties
content = content.replace("_selected.dialCode", "(_selected.phoneCode.startsWith('+') ? _selected.phoneCode : '+' + _selected.phoneCode)")
content = content.replace("country.dialCode", "(country.phoneCode.startsWith('+') ? country.phoneCode : '+' + country.phoneCode)")
content = content.replace("c.dialCode", "(c.phoneCode.startsWith('+') ? c.phoneCode : '+' + c.phoneCode)")

# Pass countries to _CountryPickerSheet
content = content.replace("""      builder: (ctx) => _CountryPickerSheet(
        selected: _selected,""", """      builder: (ctx) => _CountryPickerSheet(
        countries: widget.countries != null && widget.countries!.isNotEmpty ? widget.countries! : [Country(id: 0, name: 'United Kingdom', iso2: 'GB', phoneCode: '44', flag: '🇬🇧')],
        selected: _selected,""")

content = content.replace("class _CountryPickerSheet extends StatefulWidget {", "class _CountryPickerSheet extends StatefulWidget {\n  final List<Country> countries;")
content = content.replace("const _CountryPickerSheet({", "const _CountryPickerSheet({\n    required this.countries,")

# Update sheet initState
content = re.sub(r"class _CountryPickerSheetState extends State<_CountryPickerSheet> \{\n  final _searchCtrl = TextEditingController\(\);\n  late List<Country> _filtered;\n\n  @override\n  void dispose\(\) \{", r"class _CountryPickerSheetState extends State<_CountryPickerSheet> {\n  final _searchCtrl = TextEditingController();\n  late List<Country> _filtered;\n\n  @override\n  void initState() {\n    super.initState();\n    _filtered = widget.countries;\n  }\n\n  @override\n  void dispose() {", content)

# Fix search filter
content = content.replace("_kCountries", "widget.countries")

# Add isRequired red star
star_code = """          RichText(
            text: TextSpan(
              text: widget.label,
              style: AppText.label.copyWith(color: AppColors.muted),
              children: [
                if (widget.isRequired)
                  TextSpan(
                    text: ' *',
                    style: AppText.label.copyWith(color: AppColors.error),
                  ),
              ],
            ),
          ),"""
content = content.replace("""          Text(
            widget.label,
            style: AppText.label.copyWith(color: AppColors.muted),
          ),""", star_code)

with open("lib/core/widgets/ujob_phone_number_field.dart", "w") as f:
    f.write(content)

