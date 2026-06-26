import re

with open('lib/features/employer/applicants/applicant_detail_screen.dart', 'r') as f:
    text = f.read()

target = """    final applicant = initialApplicant;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const UJobAppBar(title: 'Applicant Profile'),
      body: Column("""

replacement = """    final asyncApplicant = ref.watch(singleApplicantProvider(initialApplicant));
    
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const UJobAppBar(title: 'Applicant Profile'),
      body: asyncApplicant.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Failed to load applicant details')),
        data: (applicant) => Column("""

text = text.replace(target, replacement)

# Now we need to add the closing parenthesis for asyncApplicant.when() at the end of the Scaffold body.
# Let's see the end of the build method.
target_end = """        ],
      ),
    );
  }

  void _showApplicantInfoSheet("""

replacement_end = """        ],
      ),
      ),
    );
  }

  void _showApplicantInfoSheet("""
text = text.replace(target_end, replacement_end)

with open('lib/features/employer/applicants/applicant_detail_screen.dart', 'w') as f:
    f.write(text)

