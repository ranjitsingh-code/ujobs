import re

with open("lib/features/employer/jobs/my_jobs_screen.dart", "r") as f:
    content = f.read()

old_data = """        if (jobs.isEmpty) {
          return UJobEmpty(
            title: context.l10n.noJobsFound,
            subtitle: context.l10n.noJobsPostedSub,
            icon: HugeIcons.strokeRoundedJobSearch,
          );
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 112.h),"""

new_data = """        if (jobs.isEmpty) {
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.refresh(employerJobsProvider(status));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                alignment: Alignment.center,
                child: UJobEmpty(
                  title: context.l10n.noJobsFound,
                  subtitle: context.l10n.noJobsPostedSub,
                  icon: HugeIcons.strokeRoundedJobSearch,
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.refresh(employerJobsProvider(status));
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 112.h),"""

content = content.replace(old_data, new_data)

with open("lib/features/employer/jobs/my_jobs_screen.dart", "w") as f:
    f.write(content)
