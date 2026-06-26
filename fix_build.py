import re

with open("lib/features/employer/company/company_profile_screen.dart", "r") as f:
    content = f.read()

bad_block = """  @override
  Widget build(BuildContext context) {
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

good_block = """  @override
  Widget build(BuildContext context) {"""

# Find all occurrences
parts = content.split(bad_block)

# Keep the first one, replace the rest
new_content = parts[0] + bad_block + good_block.join(parts[1:])

with open("lib/features/employer/company/company_profile_screen.dart", "w") as f:
    f.write(new_content)

