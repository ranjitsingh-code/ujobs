import re

file_path = 'lib/features/seeker/jobs/find_jobs_screen.dart'
with open(file_path, 'r') as f:
    content = f.read()

target = """              onTap: () {
                Navigator.pop(context);
                // Apply filter logic
              },"""

replacement = """              onTap: () {
                Navigator.pop(context);
                ref.read(activeJobFilterProvider.notifier).state = JobFilter(
                  search: _keywordsCtrl.text.isEmpty ? null : _keywordsCtrl.text,
                  category: _category == 'All Categories' ? null : _category,
                  datePosted: _datePosted == 'Any time' ? null : _datePosted,
                  employmentTypes: _employmentTypes,
                  workplaces: _workplaces,
                  experienceLevel: _experienceLevel == 'Any level' ? null : _experienceLevel,
                  minSalary: _minSalary == 'Any salary' ? null : _minSalary,
                );
              },"""

content = content.replace(target, replacement)

with open(file_path, 'w') as f:
    f.write(content)

