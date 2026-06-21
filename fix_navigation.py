import os

# 1. Update app_router.dart
with open('lib/core/router/app_router.dart', 'r') as f:
    router = f.read()

router = router.replace(
    "builder: (_, _) => const MyJobsScreen(),",
    "builder: (_, state) => MyJobsScreen(initialIndex: (state.extra as int?) ?? 0),"
)

router = router.replace(
    "builder: (_, _) => const ApplicantsScreen(),",
    "builder: (_, state) => ApplicantsScreen(initialIndex: (state.extra as int?) ?? 0),"
)

with open('lib/core/router/app_router.dart', 'w') as f:
    f.write(router)

# 2. Update my_jobs_screen.dart
with open('lib/features/employer/jobs/my_jobs_screen.dart', 'r') as f:
    my_jobs = f.read()

my_jobs = my_jobs.replace(
    "const MyJobsScreen({super.key});",
    "final int initialIndex;\n  const MyJobsScreen({super.key, this.initialIndex = 0});"
)

my_jobs = my_jobs.replace(
    "int _selectedIndex = 0;",
    "late int _selectedIndex;"
)

my_jobs = my_jobs.replace(
    "_pageController = PageController();",
    "_selectedIndex = widget.initialIndex;\n    _pageController = PageController(initialPage: widget.initialIndex);"
)

with open('lib/features/employer/jobs/my_jobs_screen.dart', 'w') as f:
    f.write(my_jobs)

# 3. Update applicants_screen.dart
with open('lib/features/employer/applicants/applicants_screen.dart', 'r') as f:
    applicants = f.read()

applicants = applicants.replace(
    "const ApplicantsScreen({super.key});",
    "final int initialIndex;\n  const ApplicantsScreen({super.key, this.initialIndex = 0});"
)

applicants = applicants.replace(
    "int _selectedIndex = 0;",
    "late int _selectedIndex;"
)

applicants = applicants.replace(
    "super.initState();\n    _tabController = TabController(length: _tabs.length, vsync: this);",
    "super.initState();\n    _selectedIndex = widget.initialIndex;\n    _tabController = TabController(length: _tabs.length, vsync: this, initialIndex: widget.initialIndex);"
)

with open('lib/features/employer/applicants/applicants_screen.dart', 'w') as f:
    f.write(applicants)

# 4. Update employer_dashboard_screen.dart
with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'r') as f:
    dashboard = f.read()

dashboard = dashboard.replace(
    "onTap: onJobsTap,",
    "onTap: () => context.go('/employer/jobs', extra: 0),"
)

# wait, the first one was 'Total Jobs' (0). The second was 'Active Jobs' (1).
# I will use regex or careful replace for dashboard.
