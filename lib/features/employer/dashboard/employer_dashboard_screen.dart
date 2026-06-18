import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ujob_error.dart';
import '../../../core/widgets/ujob_loading.dart';
import '../../../core/widgets/ujob_stat_card.dart';
import '../../../core/widgets/ujob_action_card.dart';
import '../../../core/widgets/ujob_section_header.dart';
import '../../../core/widgets/ujob_app_bar.dart';
import '../../../core/widgets/ujob_job_card.dart';
import 'employer_dashboard_provider.dart';

class EmployerDashboardScreen extends ConsumerWidget {
  const EmployerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final dashboardAsync = ref.watch(employerDashboardProvider);

    final String appBarTitle = auth.when(
      data: (u) => 'Hello, ${u?.firstName ?? 'there'} 👋',
      loading: () => 'Loading...',
      error: (_, _) => 'UJob',
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: UJobAppBar(
        title: appBarTitle,
        showBack: false,
        rightWidget: IconButton(
          icon: const HugeIcon(icon: HugeIcons.strokeRoundedNotification01, color: AppColors.text, size: 24),
          onPressed: () => context.push('/employer/notifications'),
        ),
      ),
      body: dashboardAsync.when(
        loading: () => const UJobLoading(),
        error: (e, _) => UJobError(
          message: 'Failed to load dashboard',
          onRetry: () => ref.refresh(employerDashboardProvider),
        ),
        data: (data) => SingleChildScrollView(
          padding: AppSpacing.pagePad,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              Row(
                children: [
                  UJobStatCard(label: 'Active Jobs',  value: data.activeJobs.toString(), color: AppColors.empPrimary),
                  const SizedBox(width: 12),
                  UJobStatCard(label: 'Applicants',   value: data.totalApplicants.toString(), color: AppColors.info),
                  const SizedBox(width: 12),
                  UJobStatCard(label: 'Views',        value: '-', color: AppColors.success),
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
              if (data.recentJobs.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text('No recent jobs found')),
                )
              else
                ...data.recentJobs.map((j) => UJobJobCard(
                  job: j,
                  showCompany: false, // Don't need to show own company logo
                  onTap: () => context.push('/employer/jobs/${j.id}'),
                )),
            ],
          ),
        ),
      ),
    );
  }
}
