import re

with open('lib/core/widgets/ujob_employer_job_card.dart', 'r') as f:
    text = f.read()

# Revert _StatItem build method
text = text.replace("""class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featureFlags = ref.watch(featureFlagsProvider);
    final bool jobApprovalRequired = featureFlags.maybeWhen(
      data: (flags) => flags.jobApprovalRequired,
      orElse: () => false,
    );""", """class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {""")

# Revert _ActionButton build method
text = text.replace("""class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final bool outlined;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featureFlags = ref.watch(featureFlagsProvider);
    final bool jobApprovalRequired = featureFlags.maybeWhen(
      data: (flags) => flags.jobApprovalRequired,
      orElse: () => false,
    );""", """class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final bool outlined;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {""")

with open('lib/core/widgets/ujob_employer_job_card.dart', 'w') as f:
    f.write(text)

