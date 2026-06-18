import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ujob_loading.dart';
import '../../../core/widgets/ujob_stat_card.dart';
import '../../../core/widgets/ujob_action_card.dart';
import '../../../core/widgets/ujob_section_header.dart';

class EmployerDashboardScreen extends ConsumerWidget {
  const EmployerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: auth.when(
          data: (u) => Text('Hello, ${u?.firstName ?? 'there'} 👋'),
          loading: () => const Text('Loading...'),
          error: (_, _) => const Text('UJob'),
        ),
        actions: [
          IconButton(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedNotification01, color: AppColors.text, size: 24),
            onPressed: () => context.push('/employer/notifications'),
          ),
        ],
      ),
      body: auth.when(
        loading: () => const UJobLoading(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (_) => const _DashboardBody(),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: AppSpacing.pagePad,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: [
        Row(
          children: [
            UJobStatCard(label: 'Active Jobs',  value: '0', color: AppColors.empPrimary),
            const SizedBox(width: 12),
            UJobStatCard(label: 'Applicants',   value: '0', color: AppColors.info),
            const SizedBox(width: 12),
            UJobStatCard(label: 'Views',        value: '0', color: AppColors.success),
          ],
        ),
        const SizedBox(height: 24),
        const UJobSectionHeader(title: 'Quick Actions'),
        UJobActionCard(
          icon: HugeIcons.strokeRoundedPlusSignCircle,
          color: AppColors.empPrimary,
          title: 'Post a Job',
          subtitle: 'Create a new job listing',
          onTap: () => context.push('/employer/post-job'),
        ),
        const SizedBox(height: 12),
        UJobActionCard(
          icon: HugeIcons.strokeRoundedUserGroup,
          color: AppColors.info,
          title: 'View Applicants',
          subtitle: 'Review candidates for your jobs',
          onTap: () => context.push('/employer/applicants'),
        ),
        const SizedBox(height: 12),
        UJobActionCard(
          icon: HugeIcons.strokeRoundedBuilding04,
          color: AppColors.success,
          title: 'Company Profile',
          subtitle: 'Update your company information',
          onTap: () => context.push('/employer/profile'),
        ),
        const SizedBox(height: 24),
        UJobSectionHeader(
          title: 'Recent Jobs',
          actionLabel: 'See All',
          onActionTap: () => context.go('/employer/jobs'),
        ),
        const UJobLoading(count: 3),
      ],
    ),
  );
}
