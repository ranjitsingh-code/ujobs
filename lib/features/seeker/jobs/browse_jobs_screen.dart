import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ujob_empty.dart';
import '../../../core/widgets/ujob_error.dart';
import '../../../core/widgets/ujob_loading.dart';
import '../../../core/widgets/ujob_job_card.dart';
import '../../../core/widgets/ujob_app_bar.dart';
import 'seeker_job_provider.dart';

class BrowseJobsScreen extends ConsumerStatefulWidget {
  const BrowseJobsScreen({super.key});

  @override
  ConsumerState<BrowseJobsScreen> createState() => _BrowseJobsScreenState();
}

class _BrowseJobsScreenState extends ConsumerState<BrowseJobsScreen> {
  final _searchCtrl = TextEditingController();
  String? _search;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = JobFilter(search: _search);
    final jobsAsync = ref.watch(seekerJobsProvider(filter));

    return Scaffold(
      appBar: UJobAppBar(
        title: 'Browse Jobs',
        showBack: false,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.h),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: context.l10n.searchJobsCompanies,
                prefixIcon: HugeIcon(icon: HugeIcons.strokeRoundedSearch01, color: AppColors.muted2, size: 20.r),
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              onSubmitted: (val) => setState(() => _search = val.isEmpty ? null : val),
            ),
          ),
        ),
      ),
      body: jobsAsync.when(
        loading: () => const UJobLoading(count: 4),
        error: (err, stack) => UJobError(
          message: 'Failed to find jobs',
          onRetry: () => ref.refresh(seekerJobsProvider(filter)),
        ),
        data: (jobs) {
          if (jobs.isEmpty) {
            return const UJobEmpty(
              title: 'No jobs found',
              subtitle: 'Try a different search term or category',
              icon: HugeIcons.strokeRoundedSearch01,
            );
          }

          return ListView.builder(
            padding: AppSpacing.pagePad,
            itemCount: jobs.length,
            itemBuilder: (context, index) => UJobJobCard(
              job: jobs[index],
              onTap: () => context.push('/seeker/jobs/${jobs[index].id}'),
              onSaveTap: () {
                // TODO: implement save logic
              },
            ),
          );
        },
      ),
    );
  }
}
