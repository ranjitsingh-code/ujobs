import re

with open('lib/features/employer/applicants/applicants_screen.dart', 'r') as f:
    text = f.read()

target = """    final allApplicants = ref.watch(employerApplicantsProvider);

    final filteredApplicants = allApplicants.where((app) {
      if (_selectedJobFilter != 'All Jobs' &&
          app.targetJobTitle != _selectedJobFilter) {
        return false;
      }
      if (_selectedStageFilter != 'All Stages' &&
          app.status.toLowerCase() != _selectedStageFilter.toLowerCase()) {
        return false;
      }
      return true;
    }).toList();"""

replacement = """    final asyncApplicants = ref.watch(employerApplicantsProvider);

    final allApplicants = asyncApplicants.value ?? [];
    
    final filteredApplicants = allApplicants.where((app) {
      if (_selectedJobFilter != 'All Jobs' &&
          app.targetJobTitle != _selectedJobFilter) {
        return false;
      }
      if (_selectedStageFilter != 'All Stages' &&
          app.status.toLowerCase() != _selectedStageFilter.toLowerCase()) {
        return false;
      }
      return true;
    }).toList();"""

text = text.replace(target, replacement)

target2 = """              Expanded(
                child: filteredApplicants.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: EdgeInsets.all(20.r),
                        itemCount: filteredApplicants.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 16.h),
                        itemBuilder: (context, index) {
                          final applicant = filteredApplicants[index];
                          return UJobApplicantCard(
                            applicant: applicant,
                            onTap: () {
                              context.push(
                                '/employer/applicants/${applicant.id}',
                                extra: applicant,
                              );
                            },
                          );
                        },
                      ),
              ),"""

replacement2 = """              Expanded(
                child: asyncApplicants.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Failed to load applicants')),
                  data: (_) => filteredApplicants.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          padding: EdgeInsets.all(20.r),
                          itemCount: filteredApplicants.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 16.h),
                          itemBuilder: (context, index) {
                            final applicant = filteredApplicants[index];
                            return UJobApplicantCard(
                              applicant: applicant,
                              onTap: () {
                                context.push(
                                  '/employer/applicants/${applicant.id}',
                                  extra: applicant,
                                );
                              },
                            );
                          },
                        ),
                ),
              ),"""

text = text.replace(target2, replacement2)

with open('lib/features/employer/applicants/applicants_screen.dart', 'w') as f:
    f.write(text)
