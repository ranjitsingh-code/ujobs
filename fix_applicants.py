import re

with open('lib/features/employer/applicants/applicants_screen.dart', 'r') as f:
    text = f.read()

target = """  @override
  Widget build(BuildContext context) {
    final allApplicants = ref.watch(employerApplicantsProvider);

    // Extract unique job titles from applicants for the filter
    final availableJobs = allApplicants
        .where((a) => a.targetJobTitle != null && a.targetJobTitle!.isNotEmpty)
        .map((a) => a.targetJobTitle!)
        .toSet()
        .toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const UJobAppBar(title: 'Applicants', showBack: false),
      body: NestedScrollView("""

replacement = """  @override
  Widget build(BuildContext context) {
    final asyncApplicants = ref.watch(employerApplicantsProvider);
    
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const UJobAppBar(title: 'Applicants', showBack: false),
      body: asyncApplicants.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, stack) => Center(child: Text('Failed to load applicants', style: AppText.bodyMedium.copyWith(color: AppColors.error))),
        data: (allApplicants) {
          final availableJobs = allApplicants
              .where((a) => a.targetJobTitle != null && a.targetJobTitle!.isNotEmpty)
              .map((a) => a.targetJobTitle!)
              .toSet()
              .toList();

          return NestedScrollView("""

text = text.replace(target, replacement)

target2 = """            return ListView.separated(
              padding: AppSpacing.pagePad,
              itemCount: filtered.length,
              separatorBuilder: (_, _) => SizedBox(height: 10.h),
              itemBuilder: (context, index) {
                final applicant = filtered[index];
                return UJobApplicantCard(
                  applicant: applicant,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ApplicantDetailScreen(applicantId: applicant.id, applicant: applicant),
                      ),
                    );
                  },
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}"""

# Actually, the file has Navigator.push with ONLY applicantId!
# Wait, let's just add the closing brackets for asyncApplicants.when.
text = text.replace("        ),\n      ),\n    );\n  }\n}", "        ),\n      );\n        }\n      ),\n    );\n  }\n}")

with open('lib/features/employer/applicants/applicants_screen.dart', 'w') as f:
    f.write(text)
