import re

with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'r') as f:
    text = f.read()

target = """    final isProfileComplete = ref.watch(isCompanyProfileCompleteProvider);
    final auth = ref.watch(authProvider);
    final dashboardAsync = ref.watch(employerDashboardProvider);
    
    return dashboardAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(child: UJobLoading(count: 4)),
      ),
      error: (err, stack) => Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: UJobError(
            message: 'Failed to load dashboard',
            onRetry: () => ref.refresh(employerDashboardProvider),
          ),
        ),
      ),
      data: (dashboard) {
        return Scaffold(
          backgroundColor: AppColors.bg,
          body: CustomScrollView(
            slivers: [
              _DashboardAppBar(
                companyName: dashboard.companyName,
                name: auth.user?.name ?? 'Employer',
                avatarUrl: auth.user?.avatarUrl,
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 112.h),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _QuickActions(
                      isProfileComplete: isProfileComplete,
                      onPostJob: () {
                        if (!isProfileComplete) {
                          showDialog(
                            context: context,
                            builder: (ctx) => UJobAlertDialog(
                              icon: HugeIcon(
                                icon: HugeIcons.strokeRoundedAlert02,
                                color: AppColors.warning,
                                size: 32.r,
                              ),
                              iconBgColor: AppColors.warning,
                              title: 'Action Required',
                              description:
                                  'You must complete your company profile before you can post a new job.',
                              confirmText: 'Setup Profile',
                              confirmColor: AppColors.primary,
                              cancelText: 'Cancel',
                              onConfirm: () {
                                Navigator.pop(ctx);
                                context.push('/employer/profile');
                              },
                            ),
                          );
                          return;
                        }
                        context.push('/employer/post-job');
                      },
                    ),
                    if (!isProfileComplete) ...["""

replacement = """    final isProfileComplete = ref.watch(isCompanyProfileCompleteProvider);
    final auth = ref.watch(authProvider);
    final dashboardAsync = ref.watch(employerDashboardProvider);
    
    return dashboardAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(child: UJobLoading(count: 4)),
      ),
      error: (err, stack) => Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: UJobError(
            message: 'Failed to load dashboard',
            onRetry: () => ref.refresh(employerDashboardProvider),
          ),
        ),
      ),
      data: (dashboard) {
        final isVerified = dashboard.isVerified;
        
        return Scaffold(
          backgroundColor: AppColors.bg,
          body: CustomScrollView(
            slivers: [
              _DashboardAppBar(
                companyName: dashboard.companyName,
                name: auth.user?.name ?? 'Employer',
                avatarUrl: auth.user?.avatarUrl,
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 112.h),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _QuickActions(
                      isProfileComplete: isVerified,
                      onPostJob: () {
                        if (!isVerified) {
                          showDialog(
                            context: context,
                            builder: (ctx) => UJobAlertDialog(
                              icon: HugeIcon(
                                icon: HugeIcons.strokeRoundedAlert02,
                                color: AppColors.warning,
                                size: 32.r,
                              ),
                              iconBgColor: AppColors.warning,
                              title: 'Verification Required',
                              description:
                                  'Your employer profile must be verified before you can post a new job. Please update your company profile to proceed.',
                              confirmText: 'Setup Profile',
                              confirmColor: AppColors.primary,
                              cancelText: 'Cancel',
                              onConfirm: () {
                                Navigator.pop(ctx);
                                context.push('/employer/profile');
                              },
                            ),
                          );
                          return;
                        }
                        context.push('/employer/post-job');
                      },
                    ),
                    if (!isVerified) ...["""

text = text.replace(target, replacement)

target2 = """                SizedBox(height: 14.h),
                if (dashboard.recentJobs.isEmpty)
                  _EmptyJobs(
                    isProfileComplete: isProfileComplete,
                    onPostJob: () {
                      if (!isProfileComplete) {
                        showDialog(
                          context: context,
                          builder: (ctx) => UJobAlertDialog(
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedAlert02,
                              color: AppColors.warning,
                              size: 32.r,
                            ),
                            iconBgColor: AppColors.warning,
                            title: 'Action Required',
                            description:
                                'You must complete your company profile before you can post a new job.',
                            confirmText: 'Setup Profile',
                            confirmColor: AppColors.primary,
                            cancelText: 'Cancel',
                            onConfirm: () {
                              Navigator.pop(ctx);
                              context.push('/employer/profile');
                            },
                          ),
                        );
                        return;
                      }
                      context.push('/employer/post-job');
                    },
                  ),"""

replacement2 = """                SizedBox(height: 14.h),
                if (dashboard.recentJobs.isEmpty)
                  _EmptyJobs(
                    isProfileComplete: isVerified,
                    onPostJob: () {
                      if (!isVerified) {
                        showDialog(
                          context: context,
                          builder: (ctx) => UJobAlertDialog(
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedAlert02,
                              color: AppColors.warning,
                              size: 32.r,
                            ),
                            iconBgColor: AppColors.warning,
                            title: 'Verification Required',
                            description:
                                'Your employer profile must be verified before you can post a new job. Please update your company profile to proceed.',
                            confirmText: 'Setup Profile',
                            confirmColor: AppColors.primary,
                            cancelText: 'Cancel',
                            onConfirm: () {
                              Navigator.pop(ctx);
                              context.push('/employer/profile');
                            },
                          ),
                        );
                        return;
                      }
                      context.push('/employer/post-job');
                    },
                  ),"""

text = text.replace(target2, replacement2)

with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'w') as f:
    f.write(text)
