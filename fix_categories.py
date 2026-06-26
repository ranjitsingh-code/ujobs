import re

with open('lib/features/employer/jobs/post_job_steps/step1_job_details.dart', 'r') as f:
    text = f.read()

target = """          UJobDropdownField<String>.simple(
            label: context.l10n.jobCategory,
            value: state.category.isEmpty ? 'Technology' : state.category,
            options: const [
              ('Accounting & Auditing', 'Accounting & Auditing'),
              ('Agriculture', 'Agriculture'),
              ('Animation & Multimedia', 'Animation & Multimedia'),
              ('Architecture', 'Architecture'),
              (
                'Artificial Intelligence & Machine Learning',
                'Artificial Intelligence & Machine Learning',
              ),
              ('Automotive', 'Automotive'),
              ('Banking', 'Banking'),
              ('Biotechnology', 'Biotechnology'),
              ('Blockchain & Cryptocurrency', 'Blockchain & Cryptocurrency'),
              ('Call Centers', 'Call Centers'),
              ('Construction', 'Construction'),
              ('Consulting', 'Consulting'),
              ('Customer Service & BPO', 'Customer Service & BPO'),
              ('Cybersecurity', 'Cybersecurity'),
              ('Dairy Industry', 'Dairy Industry'),
              ('Data Analytics', 'Data Analytics'),
              ('Design', 'Design'),
              ('Education', 'Education'),
              ('Electronics', 'Electronics'),
              ('Energy', 'Energy'),
              ('Environmental Services', 'Environmental Services'),
              ('Event Management', 'Event Management'),
              ('Fashion & Apparel', 'Fashion & Apparel'),
              ('Finance', 'Finance'),
              ('Financial Services', 'Financial Services'),
              ('FinTech', 'FinTech'),
              ('Food & Beverage', 'Food & Beverage'),
              ('Freelancing & Gig Economy', 'Freelancing & Gig Economy'),
              ('Gaming', 'Gaming'),
              ('Government', 'Government'),
              ('Healthcare', 'Healthcare'),
              ('Hospitality', 'Hospitality'),
              ('Hospitals & Clinics', 'Hospitals & Clinics'),
              ('Human Resources', 'Human Resources'),
              ('Import & Export', 'Import & Export'),
              ('Insurance', 'Insurance'),
              ('Internet & E-commerce', 'Internet & E-commerce'),
              ('Investment Management', 'Investment Management'),
              ('Legal Services', 'Legal Services'),
              ('Logistics & Supply Chain', 'Logistics & Supply Chain'),
              ('Manufacturing', 'Manufacturing'),
              ('Marketing', 'Marketing'),
              ('Media & Entertainment', 'Media & Entertainment'),
              ('Oil & Gas', 'Oil & Gas'),
              ('Operations', 'Operations'),
              ('Pharmaceuticals', 'Pharmaceuticals'),
              ('Poultry Industry', 'Poultry Industry'),
              ('Real Estate', 'Real Estate'),
              ('Recruitment & Staffing', 'Recruitment & Staffing'),
              ('Renewable Energy', 'Renewable Energy'),
              ('Research & Development', 'Research & Development'),
              ('Retail', 'Retail'),
              ('Sales', 'Sales'),
              ('Security Services', 'Security Services'),
              ('Software Development', 'Software Development'),
              ('Sports & Fitness', 'Sports & Fitness'),
              ('Technology', 'Technology'),
              ('Telecommunications', 'Telecommunications'),
              ('Textile Industry', 'Textile Industry'),
              ('Training & Development', 'Training & Development'),
              ('Transportation', 'Transportation'),
              ('Travel & Tourism', 'Travel & Tourism'),
              ('Wholesale', 'Wholesale'),
              ('Other', 'Other'),
            ],
            onChanged: (val) {
              if (val != null) {
                notifier.updateField(state.copyWith(category: val));
              }
            },
          ),"""

replacement = """          UJobDropdownField<String>.simple(
            label: context.l10n.jobCategory,
            value: state.category.isEmpty 
                ? (categories.isNotEmpty ? categories.first.id : '') 
                : state.category,
            options: [
              ...categories.map((c) => (c.id, c.name)),
              ('Other', 'Other'),
            ],
            onChanged: (val) {
              if (val != null) {
                notifier.updateField(state.copyWith(category: val));
              }
            },
          ),"""

if target in text:
    text = text.replace(target, replacement)
    with open('lib/features/employer/jobs/post_job_steps/step1_job_details.dart', 'w') as f:
        f.write(text)
    print("Success")
else:
    print("Target not found")
