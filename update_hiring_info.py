import re

with open("lib/features/employer/company/company_profile_screen.dart", "r") as f:
    content = f.read()

build_vars = """    final isProfileComplete = ref.watch(isCompanyProfileCompleteProvider);

    String? sizeLabel = const [
      ('1-10 employees', 'size_1_10'),
      ('11-50 employees', 'size_11_50'),
      ('51-200 employees', 'size_51_200'),
      ('201-500 employees', 'size_201_500'),
      ('501-1000 employees', 'size_501_1000'),
      ('1000+ employees', 'size_1000_plus'),
    ].where((e) => e.$2 == _selectedSize).firstOrNull?.$1;

    String? workTypeLabel = const [
      ('On-site', 'onsite'),
      ('Hybrid', 'hybrid'),
      ('Remote', 'remote'),
    ].where((e) => e.$2 == _selectedWorkType).firstOrNull?.$1;

    String? hiringSubtitle;
    if (sizeLabel != null && workTypeLabel != null) {
      hiringSubtitle = '$sizeLabel • $workTypeLabel';
    } else if (sizeLabel != null) {
      hiringSubtitle = sizeLabel;
    } else if (workTypeLabel != null) {
      hiringSubtitle = workTypeLabel;
    }"""

content = content.replace("    final isProfileComplete = ref.watch(isCompanyProfileCompleteProvider);", build_vars)

content = content.replace('title: "Other Details",\n                      subtitle: "Size & Work Type",', 'title: "Hiring Information",\n                      subtitle: hiringSubtitle,')

# Wait, 'title: "Other Details",' is there but maybe spacing is slightly different.
# Let's use regex to be safe.
content = re.sub(r'title:\s*"Other Details",\s*subtitle:\s*"Size & Work Type",', r'title: "Hiring Information",\n                      subtitle: hiringSubtitle,', content)

with open("lib/features/employer/company/company_profile_screen.dart", "w") as f:
    f.write(content)

