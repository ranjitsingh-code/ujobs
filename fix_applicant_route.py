import re

with open('lib/core/router/app_router.dart', 'r') as f:
    text = f.read()

import_statement = "import '../../features/employer/applicants/applicant_detail_screen.dart';"
if import_statement not in text:
    text = text.replace("import '../../features/employer/applicants/applicants_screen.dart';", f"import '../../features/employer/applicants/applicants_screen.dart';\n{import_statement}")

target_route = """          GoRoute(
            path: '/employer/applicants',
            pageBuilder: (_, state) => NoTransitionPage(
              child: ApplicantsScreen(initialIndex: (state.extra as int?) ?? 0),
            ),
          ),"""

replacement_route = """          GoRoute(
            path: '/employer/applicants',
            pageBuilder: (_, state) => NoTransitionPage(
              child: ApplicantsScreen(initialIndex: (state.extra as int?) ?? 0),
            ),
          ),
          GoRoute(
            path: '/employer/applicants/:app_id',
            builder: (_, state) => ApplicantDetailScreen(
              applicantId: state.pathParameters['app_id'],
            ),
          ),"""

text = text.replace(target_route, replacement_route)

with open('lib/core/router/app_router.dart', 'w') as f:
    f.write(text)

