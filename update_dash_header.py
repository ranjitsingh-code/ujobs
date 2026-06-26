import re

with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'r') as f:
    text = f.read()

target1 = """              _DashboardAppBar(
                companyName: dashboard.companyName,
                name: auth.user?.name ?? 'Employer',
                avatarUrl: auth.user?.avatarUrl,
              ),"""

# Let's wait, `_DashboardHeader` is used in the `body:` CustomScrollView -> SliverToBoxAdapter -> child: _DashboardHeader
# Wait, let's find the exact usage of `_DashboardHeader`.
