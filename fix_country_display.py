import re

with open("lib/features/employer/company/company_profile_screen.dart", "r") as f:
    content = f.read()

old_header = """class CompanyProfileHeader extends StatelessWidget {
  final CompanyProfile company;
  final double completeness;
  const CompanyProfileHeader({
    super.key,
    required this.company,
    required this.completeness,
  });

  @override
  Widget build(BuildContext context) {
    final percentCompleted = (completeness * 100).toInt();

    // Construct the subtitle (Industry)
    List<String> subtitleParts = [];
    if (company.industry != null && company.industry!.isNotEmpty) {
      subtitleParts.add(company.industry!);
    }
    final subtitle = subtitleParts.join(' · ');

    // Construct location
    String location = '';
    if (company.city != null &&
        company.city!.isNotEmpty &&
        company.country != null &&
        company.country!.isNotEmpty) {
      location = '${company.city}, ${company.country}';
    } else if (company.city != null && company.city!.isNotEmpty) {
      location = company.city!;
    } else if (company.country != null && company.country!.isNotEmpty) {
      location = company.country!;
    }"""

new_header = """class CompanyProfileHeader extends ConsumerWidget {
  final CompanyProfile company;
  final double completeness;
  const CompanyProfileHeader({
    super.key,
    required this.company,
    required this.completeness,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final percentCompleted = (completeness * 100).toInt();

    // Get real country name instead of ISO2
    final countries = ref.read(countriesProvider).valueOrNull ?? [];
    final countryName = countries.firstWhereOrNull((c) => c.iso2 == company.country)?.name ?? company.country;

    // Construct the subtitle (Industry)
    List<String> subtitleParts = [];
    if (company.industry != null && company.industry!.isNotEmpty) {
      subtitleParts.add(company.industry!);
    }
    final subtitle = subtitleParts.join(' · ');

    // Construct location
    String location = '';
    if (company.city != null &&
        company.city!.isNotEmpty &&
        countryName != null &&
        countryName.isNotEmpty) {
      location = '${company.city}, $countryName';
    } else if (company.city != null && company.city!.isNotEmpty) {
      location = company.city!;
    } else if (countryName != null && countryName.isNotEmpty) {
      location = countryName;
    }"""

if old_header in content:
    content = content.replace(old_header, new_header)
    with open("lib/features/employer/company/company_profile_screen.dart", "w") as f:
        f.write(content)
    print("Success")
else:
    print("Failed to find old_header")

