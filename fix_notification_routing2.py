import re

with open('lib/features/shared/notifications/notifications_screen.dart', 'r') as f:
    text = f.read()

target = """                                                          if (n.data != null && n.data!['redirect_to'] != null) {
                                                            final redirectTo = n.data!['redirect_to'].toString();
                                                            final jobId = n.data!['job_id']?.toString();
                                                            final appId = n.data!['app_id']?.toString();

                                                            if (redirectTo == 'applicant_details' && appId != null) {
                                                              Navigator.push(context, MaterialPageRoute(builder: (_) => ApplicantDetailScreen(applicantId: appId)));
                                                            } else if (redirectTo == 'job_details' && jobId != null) {
                                                              context.push(isEmployer ? '/employer/jobs/$jobId' : '/seeker/jobs/$jobId');
                                                            } else {
                                                              if (n.type == 'message') context.push('/conversations');
                                                            }
                                                          } else {
                                                            if (n.type == 'message') {
                                                              context.push('/conversations/1', extra: {'name': isEmployer ? 'Jim' : 'Nexovia Solutions'});
                                                            } else if (n.type == 'job' || n.type == 'job_approved') {
                                                              context.push(isEmployer ? '/employer/jobs' : '/seeker/jobs');
                                                            } else if (n.type == 'application' || n.type == 'new_application') {
                                                              context.push(isEmployer ? '/employer/applicants' : '/seeker/applications');
                                                            }
                                                          }"""

replacement = """                                                          final jobId = n.data?['job_id']?.toString();
                                                          final appId = n.data?['app_id']?.toString();

                                                          if (n.type == 'new_application' && appId != null) {
                                                            Navigator.push(context, MaterialPageRoute(builder: (_) => ApplicantDetailScreen(applicantId: appId)));
                                                          } else if (n.type == 'job_approved' && jobId != null) {
                                                            context.push(isEmployer ? '/employer/jobs/$jobId' : '/seeker/jobs/$jobId');
                                                          } else if (n.type == 'message') {
                                                            context.push('/conversations/1', extra: {'name': isEmployer ? 'Jim' : 'Nexovia Solutions'});
                                                          } else {
                                                            // Fallbacks if IDs are missing
                                                            if (n.type == 'job' || n.type == 'job_approved') {
                                                              context.push(isEmployer ? '/employer/jobs' : '/seeker/jobs');
                                                            } else if (n.type == 'application' || n.type == 'new_application') {
                                                              context.push(isEmployer ? '/employer/applicants' : '/seeker/applications');
                                                            }
                                                          }"""

text = text.replace(target, replacement)

with open('lib/features/shared/notifications/notifications_screen.dart', 'w') as f:
    f.write(text)
