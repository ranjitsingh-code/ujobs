with open('lib/features/employer/company/company_profile_screen.dart', 'r') as f:
    text = f.read()

# Fix UJobTextField hintText -> hint
text = text.replace("hintText:", "hint:")

# Fix UJobDropdownField items -> options
text = text.replace("items: const ['Software Development', 'Finance', 'Healthcare', 'Education']", "options: const [('Software Development', 'Software Development'), ('Finance', 'Finance'), ('Healthcare', 'Healthcare'), ('Education', 'Education')]")
text = text.replace("items: const ['1-10', '11-50', '51-200', '201-500', '500+']", "options: const [('1-10', '1-10'), ('11-50', '11-50'), ('51-200', '51-200'), ('201-500', '201-500'), ('500+', '500+')]")
text = text.replace("items: const ['Remote', 'Hybrid', 'On-site']", "options: const [('Remote', 'Remote'), ('Hybrid', 'Hybrid'), ('On-site', 'On-site')]")
text = text.replace("items: const ['United Kingdom', 'United States', 'Canada', 'Australia']", "options: const [('United Kingdom', 'United Kingdom'), ('United States', 'United States'), ('Canada', 'Canada'), ('Australia', 'Australia')]")

# Fix _SectionCard icon type
text = text.replace("final IconData icon;", "final dynamic icon;")

# Fix deprecated activeColor -> activeThumbColor in Switch
text = text.replace("activeColor: AppColors.primary,", "activeColor: AppColors.primary, activeThumbColor: AppColors.primary,")

with open('lib/features/employer/company/company_profile_screen.dart', 'w') as f:
    f.write(text)
