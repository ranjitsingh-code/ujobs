import re

with open('lib/core/widgets/ujob_employer_job_actions_sheet.dart', 'r') as f:
    text = f.read()

# Revert _UJobEmployerJobActionsSheet
text = text.replace("""class _UJobEmployerJobActionsSheet extends StatelessWidget {
  final Job job;
  final VoidCallback onEdit;
  final VoidCallback onViewApplicants;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback? onPublish;
  final VoidCallback? onReopen;
  final VoidCallback onClose;
  final VoidCallback onDelete;

  const _UJobEmployerJobActionsSheet({
    required this.job,
    required this.onEdit,
    required this.onViewApplicants,
    required this.onPause,
    required this.onResume,
    this.onPublish,
    this.onReopen,
    required this.onClose,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featureFlags = ref.watch(featureFlagsProvider);
    final bool jobApprovalRequired = featureFlags.maybeWhen(
      data: (flags) => flags.jobApprovalRequired,
      orElse: () => false,
    );""", """class _UJobEmployerJobActionsSheet extends ConsumerWidget {
  final Job job;
  final VoidCallback onEdit;
  final VoidCallback onViewApplicants;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback? onPublish;
  final VoidCallback? onReopen;
  final VoidCallback onClose;
  final VoidCallback onDelete;

  const _UJobEmployerJobActionsSheet({
    required this.job,
    required this.onEdit,
    required this.onViewApplicants,
    required this.onPause,
    required this.onResume,
    this.onPublish,
    this.onReopen,
    required this.onClose,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featureFlags = ref.watch(featureFlagsProvider);
    final bool jobApprovalRequired = featureFlags.maybeWhen(
      data: (flags) => flags.jobApprovalRequired,
      orElse: () => false,
    );""")

# Revert _ActionTile build method
text = text.replace("""class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featureFlags = ref.watch(featureFlagsProvider);
    final bool jobApprovalRequired = featureFlags.maybeWhen(
      data: (flags) => flags.jobApprovalRequired,
      orElse: () => false,
    );""", """class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {""")

with open('lib/core/widgets/ujob_employer_job_actions_sheet.dart', 'w') as f:
    f.write(text)

