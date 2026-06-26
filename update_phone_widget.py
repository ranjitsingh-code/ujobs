import re

with open("lib/core/widgets/ujob_phone_number_field.dart", "r") as f:
    content = f.read()

# Import Country model
if "import '../models/country.dart';" not in content:
    content = content.replace("import 'ujob_text_field.dart';", "import 'ujob_text_field.dart';\nimport '../models/country.dart';")

# Remove _Country and _kCountries
content = re.sub(r"class _Country \{[\s\S]*?\}\n\nconst _kCountries = \[[\s\S]*?\];\n", "", content)

# Add countries parameter
content = re.sub(r"(final String\? hint;\n)", r"\1  final List<Country>? countries;\n", content)
content = re.sub(r"(this\.hint,\n)", r"\1    this.countries,\n", content)

# Change _Country selected to Country selected
content = content.replace("late _Country _selected;", "late Country _selected;")
content = content.replace("final _Country selected;", "final Country selected;")
content = content.replace("final ValueChanged<_Country> onSelect;", "final ValueChanged<Country> onSelect;")
content = content.replace("List<_Country> _filtered", "List<Country> _filtered")

# Update initState to use widget.countries
init_state_replacement = """  @override
  void initState() {
    super.initState();
    final fallbackCountry = Country(id: 0, name: 'United Kingdom', iso2: 'GB', phoneCode: '44', flag: '🇬🇧');
    final activeCountries = widget.countries != null && widget.countries!.isNotEmpty ? widget.countries! : [fallbackCountry];
    
    // Ensure dial codes have + prefix for comparison
    String normalizedInitial = widget.initialDialCode ?? '+44';
    if (!normalizedInitial.startsWith('+')) normalizedInitial = '+' + normalizedInitial;

    _selected = activeCountries.firstWhere(
      (c) {
        final cDial = c.phoneCode.startsWith('+') ? c.phoneCode : '+' + c.phoneCode;
        return cDial == normalizedInitial;
      },
      orElse: () => activeCountries.first,
    );
    _focusNode.addListener(() {
      if (mounted) setState(() => _focused = _focusNode.hasFocus);
    });
  }"""
content = re.sub(r"  @override\n  void initState\(\) \{[\s\S]*?\}\n\n", init_state_replacement + "\n\n", content)

# Fix country properties in build methods
content = content.replace("_selected.dialCode", "(_selected.phoneCode.startsWith('+') ? _selected.phoneCode : '+' + _selected.phoneCode)")
content = content.replace("c.dialCode", "(c.phoneCode.startsWith('+') ? c.phoneCode : '+' + c.phoneCode)")
content = content.replace("widget.onCountryCodeChanged?.call(country.dialCode);", "widget.onCountryCodeChanged?.call(country.phoneCode.startsWith('+') ? country.phoneCode : '+' + country.phoneCode);")

# Update _CountryPickerSheet to use countries
content = re.sub(r"class _CountryPickerSheet extends StatefulWidget \{", r"""class _CountryPickerSheet extends StatefulWidget {
  final List<Country> countries;""", content)

content = re.sub(r"const _CountryPickerSheet\(\{", r"""const _CountryPickerSheet({
    required this.countries,""", content)

content = content.replace("List<Country> _filtered = _kCountries;", "late List<Country> _filtered;")

content = re.sub(r"  @override\n  void dispose\(\) \{", r"""  @override
  void initState() {
    super.initState();
    _filtered = widget.countries;
  }

  @override
  void dispose() {""", content)

content = content.replace("""    setState(() {
      _filtered = _kCountries
          .where((c) =>
              c.name.toLowerCase().contains(query) ||
              (c.phoneCode.startsWith('+') ? c.phoneCode : '+' + c.phoneCode).contains(query))
          .toList();
    });""", """    setState(() {
      _filtered = widget.countries
          .where((c) =>
              c.name.toLowerCase().contains(query) ||
              (c.phoneCode.startsWith('+') ? c.phoneCode : '+' + c.phoneCode).contains(query))
          .toList();
    });""")

# Fix the showModalBottomSheet call
content = content.replace("""builder: (ctx) => _CountryPickerSheet(
        selected: _selected,""", """builder: (ctx) => _CountryPickerSheet(
        countries: widget.countries != null && widget.countries!.isNotEmpty ? widget.countries! : [Country(id: 0, name: 'United Kingdom', iso2: 'GB', phoneCode: '44', flag: '🇬🇧')],
        selected: _selected,""")

with open("lib/core/widgets/ujob_phone_number_field.dart", "w") as f:
    f.write(content)

