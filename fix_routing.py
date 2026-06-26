import re

# 1. Update app_router.dart
with open("lib/core/router/app_router.dart", "r") as f:
    router = f.read()

router = router.replace(
"""          GoRoute(
            path: '/employer/jobs/:id',
            builder: (_, state) => EmployerJobDetailScreen(
              jobId: int.parse(state.pathParameters['id']!),
            ),
          ),""",
"""          GoRoute(
            path: '/employer/jobs/:id',
            builder: (_, state) => EmployerJobDetailScreen(
              jobId: int.parse(state.pathParameters['id']!),
              jobData: state.extra as Job?,
            ),
          ),"""
)
with open("lib/core/router/app_router.dart", "w") as f:
    f.write(router)

# 2. Update employer_job_detail_screen.dart
with open("lib/features/employer/jobs/employer_job_detail_screen.dart", "r") as f:
    detail = f.read()

detail = detail.replace(
"""class EmployerJobDetailScreen extends ConsumerWidget {
  final int jobId;

  const EmployerJobDetailScreen({super.key, required this.jobId});""",
"""class EmployerJobDetailScreen extends ConsumerWidget {
  final int jobId;
  final Job? jobData;

  const EmployerJobDetailScreen({super.key, required this.jobId, this.jobData});"""
)

detail = detail.replace(
"""  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobAsync = ref.watch(employerJobDetailProvider(jobId));""",
"""  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobAsync = jobData != null ? AsyncValue.data(jobData!) : ref.watch(employerJobDetailProvider(jobId));"""
)

with open("lib/features/employer/jobs/employer_job_detail_screen.dart", "w") as f:
    f.write(detail)

# 3. Update my_jobs_screen.dart
with open("lib/features/employer/jobs/my_jobs_screen.dart", "r") as f:
    myjobs = f.read()

myjobs = myjobs.replace(
"""onTap: () => context.push('/employer/jobs/${job.id}'),""",
"""onTap: () => context.push('/employer/jobs/${job.id}', extra: job),"""
)

with open("lib/features/employer/jobs/my_jobs_screen.dart", "w") as f:
    f.write(myjobs)

