import re

with open('lib/features/employer/applicants/applicant_detail_screen.dart', 'r') as f:
    text = f.read()

target1 = """                    onConfirm: () {
                      ref
                          .read(employerApplicantsProvider.notifier)
                          .updateStatus(applicant.id, 'Rejected');
                    },"""

replacement1 = """                    onConfirm: () async {
                      try {
                        await ref
                            .read(employerApplicantsProvider.notifier)
                            .updateStatus(applicant.id, 'Rejected');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Applicant rejected.')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to update stage.')),
                          );
                        }
                      }
                    },"""

text = text.replace(target1, replacement1)

target2 = """                    onConfirm: () {
                      ref
                          .read(employerApplicantsProvider.notifier)
                          .updateStatus(applicant.id, nextStageValue!);
                    },"""

replacement2 = """                    onConfirm: () async {
                      try {
                        await ref
                            .read(employerApplicantsProvider.notifier)
                            .updateStatus(applicant.id, nextStageValue!);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Applicant moved to $nextStageValue!')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to update stage.')),
                          );
                        }
                      }
                    },"""

text = text.replace(target2, replacement2)

with open('lib/features/employer/applicants/applicant_detail_screen.dart', 'w') as f:
    f.write(text)

