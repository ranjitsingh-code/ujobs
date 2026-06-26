import os

file_path = 'lib/features/shared/notifications/notifications_screen.dart'
with open(file_path, 'r') as f:
    content = f.read()

old_routing = """                                      if (n.type == 'message') {
                                        context.push(
                                          '/conversations/1',
                                          extra: {'name': 'nexovia solutions'},
                                        );
                                      } else if (n.type == 'job') {
                                        context.push('/seeker/jobs/1');
                                      } else if (n.type == 'application') {
                                        context.push('/seeker/applications');
                                      }"""

new_routing = """                                      final role = ref.read(roleProvider);
                                      if (n.type == 'message') {
                                        if (role == AppRole.employer) {
                                          context.push(
                                            '/conversations/1',
                                            extra: {'name': 'Jim'},
                                          );
                                        } else {
                                          context.push(
                                            '/conversations/1',
                                            extra: {'name': 'Nexovia Solutions'},
                                          );
                                        }
                                      } else if (n.type == 'job') {
                                        if (role == AppRole.employer) {
                                          context.push('/employer/jobs/1');
                                        } else {
                                          context.push('/seeker/jobs/1');
                                        }
                                      } else if (n.type == 'application') {
                                        if (role == AppRole.employer) {
                                          context.push('/employer/applicants');
                                        } else {
                                          context.push('/seeker/applications');
                                        }
                                      }"""

content = content.replace(old_routing, new_routing)

with open(file_path, 'w') as f:
    f.write(content)
