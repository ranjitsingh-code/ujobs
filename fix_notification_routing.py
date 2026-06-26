import re

with open('lib/features/shared/notifications/notifications_screen.dart', 'r') as f:
    text = f.read()

import_statement = "import '../../employer/applicants/applicant_detail_screen.dart';"
if import_statement not in text:
    text = text.replace("import 'package:flutter/material.dart';", f"import 'package:flutter/material.dart';\n{import_statement}")

target = """                                                          if (n.type == 'message') {
                                                            context.push('/conversations/1', extra: {'name': isEmployer ? 'Jim' : 'Nexovia Solutions'});
                                                          } else if (n.type == 'job' || n.type == 'job_approved') {
                                                            context.push(isEmployer ? '/employer/jobs/1' : '/seeker/jobs/1');
                                                          } else if (n.type == 'application' || n.type == 'new_application') {
                                                            context.push(isEmployer ? '/employer/applicants' : '/seeker/applications');
                                                          }"""

replacement = """                                                          if (n.data != null && n.data!['redirect_to'] != null) {
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

text = text.replace(target, replacement)

with open('lib/features/shared/notifications/notifications_screen.dart', 'w') as f:
    f.write(text)

