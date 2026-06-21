with open('lib/features/employer/company/company_profile_screen.dart', 'r') as f:
    text = f.read()

# Fix CompanyProfileHeader
old_header = """class CompanyProfileHeader extends StatelessWidget {
  final CompanyProfile company;
  const CompanyProfileHeader({required this.company});

  @override
  Widget build(BuildContext context) => Container("""
new_header = """class CompanyProfileHeader extends ConsumerWidget {
  final CompanyProfile company;
  const CompanyProfileHeader({super.key, required this.company});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Container("""
text = text.replace(old_header, new_header)

with open('lib/features/employer/company/company_profile_screen.dart', 'w') as f:
    f.write(text)
