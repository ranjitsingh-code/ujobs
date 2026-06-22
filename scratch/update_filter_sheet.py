import os
import re

file_path = 'lib/features/seeker/jobs/find_jobs_screen.dart'
with open(file_path, 'r') as f:
    content = f.read()

# Replace _FilterSheet to accept ref
content = content.replace("class _FilterSheet extends StatefulWidget", "class _FilterSheet extends ConsumerStatefulWidget")
content = content.replace("State<_FilterSheet> createState() => _FilterSheetState();", "ConsumerState<_FilterSheet> createState() => _FilterSheetState();")
content = content.replace("class _FilterSheetState extends State<_FilterSheet>", "class _FilterSheetState extends ConsumerState<_FilterSheet>")

# Update init state
init_state = """  @override
  void initState() {
    super.initState();
    final filter = ref.read(activeJobFilterProvider);
    _keywordsCtrl.text = filter.search ?? '';
    _category = filter.category ?? 'All Categories';
    _datePosted = filter.datePosted ?? 'Any time';
    _experienceLevel = filter.experienceLevel ?? 'Any level';
    _minSalary = filter.minSalary ?? 'Any salary';
    _employmentTypes = List.from(filter.employmentTypes);
    _workplaces = List.from(filter.workplaces);
  }"""
content = re.sub(r"class _FilterSheetState extends ConsumerState<_FilterSheet> \{.*?String _category = 'All Categories';", "class _FilterSheetState extends ConsumerState<_FilterSheet> {\n  final _keywordsCtrl = TextEditingController();\n  final _locationCtrl = TextEditingController();\n  final _companyCtrl = TextEditingController();\n  String _datePosted = 'Any time';\n  List<String> _employmentTypes = [];\n  List<String> _workplaces = [];\n  String _experienceLevel = 'Any level';\n  String _minSalary = 'Any salary';\n  String _category = 'All Categories';\n\n" + init_state, content, flags=re.DOTALL)

# Update Apply Filters
apply_logic = """                  onTap: () {
                    ref.read(activeJobFilterProvider.notifier).state = ref.read(activeJobFilterProvider).copyWith(
                      search: _keywordsCtrl.text.isEmpty ? null : _keywordsCtrl.text,
                      category: _category == 'All Categories' ? null : _category,
                      datePosted: _datePosted,
                      experienceLevel: _experienceLevel,
                      minSalary: _minSalary,
                      employmentTypes: _employmentTypes,
                      workplaces: _workplaces,
                    );
                    Navigator.pop(context);
                  },"""
content = re.sub(r"                  onTap: \(\) \{(.*?)\} \/\/,.*?\/\* Apply Filters \*\/", apply_logic, content, flags=re.DOTALL)

# Make sure Apply Filters button actually has this onTap
content = content.replace("onTap: () => Navigator.pop(context), // Apply Filters", apply_logic)

# Replace _SortSheet
content = content.replace("class _SortSheet extends StatelessWidget", "class _SortSheet extends ConsumerWidget")
content = content.replace("Widget build(BuildContext context)", "Widget build(BuildContext context, WidgetRef ref)")

# Update _SortSheet onSelected to use provider
content = content.replace(
    "onSelected: (val) {\n                                  setState(() => _sortBy = val);\n                                  Navigator.pop(context);\n                                }",
    "onSelected: (val) {\n                                  setState(() => _sortBy = val);\n                                  ref.read(activeJobFilterProvider.notifier).state = ref.read(activeJobFilterProvider).copyWith(sortBy: val);\n                                  Navigator.pop(context);\n                                }"
)

with open(file_path, 'w') as f:
    f.write(content)
print("Updated FilterSheet!")
