import re

with open('lib/features/employer/applicants/applicant_detail_screen.dart', 'r') as f:
    text = f.read()

target1 = """    final applicantAsync = ref.watch(singleApplicantProvider(initialApplicant));

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const UJobAppBar(title: 'Applicant Profile'),
      body: applicantAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, stack) => Center(child: Text('Failed to load profile.', style: AppText.bodyMedium.copyWith(color: AppColors.error))),
        data: (applicant) => Column(
          children: ["""

replacement1 = """    final applicant = initialApplicant;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const UJobAppBar(title: 'Applicant Profile'),
      body: Column(
        children: ["""

text = text.replace(target1, replacement1)

target2 = """          // Sticky Bottom Bar
          _buildStickyBottomBar(applicant),
        ],
      ),
      ),
    );
  }"""

replacement2 = """          // Sticky Bottom Bar
          _buildStickyBottomBar(applicant),
        ],
      ),
    );
  }"""

text = text.replace(target2, replacement2)

with open('lib/features/employer/applicants/applicant_detail_screen.dart', 'w') as f:
    f.write(text)
