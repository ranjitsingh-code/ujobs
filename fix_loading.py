import os

# Applicant Detail Screen
fpath = 'lib/features/employer/applicants/applicant_detail_screen.dart'
with open(fpath, 'r') as f: text = f.read()
if "import '../../../core/widgets/ujob_loading.dart';" not in text:
    text = text.replace("import '../../../core/widgets/ujob_button.dart';", "import '../../../core/widgets/ujob_button.dart';\nimport '../../../core/widgets/ujob_loading.dart';")
text = text.replace("loading: () => const Center(child: CircularProgressIndicator()),", "loading: () => const UJobLoading(count: 1),")
text = text.replace("return const Scaffold(body: Center(child: CircularProgressIndicator()));", "return const Scaffold(body: UJobLoading(count: 1));")
with open(fpath, 'w') as f: f.write(text)

# Applicants Screen
fpath = 'lib/features/employer/applicants/applicants_screen.dart'
with open(fpath, 'r') as f: text = f.read()
if "import '../../../core/widgets/ujob_loading.dart';" not in text:
    text = text.replace("import '../../../core/widgets/ujob_empty.dart';", "import '../../../core/widgets/ujob_empty.dart';\nimport '../../../core/widgets/ujob_loading.dart';")
text = text.replace("loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),", "loading: () => const UJobLoading(count: 4),")
with open(fpath, 'w') as f: f.write(text)

# Seeker Company Profile Screen
fpath = 'lib/features/seeker/company/seeker_company_profile_screen.dart'
with open(fpath, 'r') as f: text = f.read()
if "import '../../../core/widgets/ujob_loading.dart';" not in text:
    text = text.replace("import '../../../core/widgets/ujob_button.dart';", "import '../../../core/widgets/ujob_button.dart';\nimport '../../../core/widgets/ujob_loading.dart';")
text = text.replace("loading: () => const Center(child: CircularProgressIndicator()),", "loading: () => const UJobLoading(count: 1),")
with open(fpath, 'w') as f: f.write(text)

# Apply Screen
fpath = 'lib/features/seeker/apply/apply_screen.dart'
with open(fpath, 'r') as f: text = f.read()
if "import '../../../core/widgets/ujob_loading.dart';" not in text:
    text = text.replace("import '../../../core/widgets/ujob_button.dart';", "import '../../../core/widgets/ujob_button.dart';\nimport '../../../core/widgets/ujob_loading.dart';")
text = text.replace("return const Scaffold(body: Center(child: CircularProgressIndicator()));", "return const Scaffold(body: UJobLoading(count: 1));")
with open(fpath, 'w') as f: f.write(text)

