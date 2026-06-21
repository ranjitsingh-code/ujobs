with open('lib/features/employer/company/company_profile_screen.dart', 'r') as f:
    text = f.read()

# Fix _CompanyHeader
old_header = """class _CompanyHeader extends StatelessWidget {
  final CompanyProfile company;
  const _CompanyHeader({required this.company});

  @override
  Widget build(BuildContext context) => Container("""
new_header = """class _CompanyHeader extends ConsumerWidget {
  final CompanyProfile company;
  const _CompanyHeader({super.key, required this.company});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Container("""
text = text.replace(old_header, new_header)

with open('lib/features/employer/company/company_profile_screen.dart', 'w') as f:
    f.write(text)

with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'r') as f:
    text2 = f.read()

# Replace any remaining ref.read(isCompanyProfileCompleteProvider.notifier).state = true; with context.push('/employer/profile');
text2 = text2.replace("ref.read(isCompanyProfileCompleteProvider.notifier).state = true;", "context.push('/employer/profile');")

with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'w') as f:
    f.write(text2)
