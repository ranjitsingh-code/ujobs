import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/models/company.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/l10n_extensions.dart';
import '../../../core/widgets/ujob_text_field.dart';
import '../../employer/jobs/employer_job_provider.dart';

class SeekerCompaniesScreen extends ConsumerStatefulWidget {
  const SeekerCompaniesScreen({super.key});

  @override
  ConsumerState<SeekerCompaniesScreen> createState() =>
      _SeekerCompaniesScreenState();
}

class _SeekerCompaniesScreenState extends ConsumerState<SeekerCompaniesScreen> {
  String _query = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobs = ref.watch(demoEmployerJobsProvider);
    final l10n = context.l10n;

    final Map<int, Company> companyMap = {};
    final Map<int, int> jobCountMap = {};
    for (final job in jobs) {
      if (job.company != null) {
        companyMap[job.company!.id] = job.company!;
        jobCountMap[job.company!.id] =
            (jobCountMap[job.company!.id] ?? 0) + 1;
      }
    }

    var entries = companyMap.entries.toList();
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      entries = entries.where((e) {
        final c = e.value;
        return c.name.toLowerCase().contains(q) ||
            (c.location?.toLowerCase().contains(q) ?? false) ||
            (c.industry?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // Pinned zero-height bar — keeps status bar surface color always
          SliverAppBar(
            primary: true,
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            pinned: true,
            floating: false,
            elevation: 0,
            scrolledUnderElevation: 0,
            toolbarHeight: 0,
            automaticallyImplyLeading: false,
          ),
          // Floating search bar — disappears on scroll down, snaps back up
          SliverAppBar(
            primary: false,
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            pinned: false,
            floating: true,
            snap: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            toolbarHeight: 72.h,
            titleSpacing: 0,
            automaticallyImplyLeading: false,
            title: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 8.h),
              child: UJobTextField(
                hint: l10n.searchCompanies,
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                prefix: Padding(
                  padding: EdgeInsets.only(left: 12.w, right: 8.w),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedSearch01,
                    color: AppColors.muted,
                    size: 20.r,
                  ),
                ),
              ),
            ),
          ),
        ],
        body: entries.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedBuilding01,
                      color: AppColors.muted,
                      size: 64.r,
                    ),
                    SizedBox(height: 16.h),
                    Text(l10n.noResultsFound, style: AppText.heading3),
                  ],
                ),
              )
            : ListView.separated(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                itemCount: entries.length + 1,
                separatorBuilder: (_, i) =>
                    i == 0 ? const SizedBox.shrink() : SizedBox(height: 12.h),
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Text(
                        l10n.companiesFoundCount(entries.length),
                        style: AppText.bodyMedium.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                    );
                  }
                  final company = entries[i - 1].value;
                  final jobCount = jobCountMap[entries[i - 1].key] ?? 0;
                  return _CompanyCard(
                    company: company,
                    jobCount: jobCount,
                    onTap: () => context.push(
                      '/seeker/company',
                      extra: {'company': company},
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _CompanyCard extends StatelessWidget {
  final Company company;
  final int jobCount;
  final VoidCallback onTap;

  const _CompanyCard({
    required this.company,
    required this.jobCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppShadow.card(),
      ),
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.md,
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: AppRadius.sm,
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Center(
                  child: Text(
                    company.name.isNotEmpty
                        ? company.name[0].toUpperCase()
                        : '?',
                    style: AppText.titleMd.copyWith(color: AppColors.primary),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(company.name, style: AppText.titleMd),
                    if (company.location != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        company.location!,
                        style: AppText.small.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (company.industry != null || company.isVerified == true) ...[
            SizedBox(height: 10.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 6.h,
              children: [
                if (company.industry != null)
                  _Tag(label: company.industry!),
                if (company.isVerified == true)
                  _Tag(
                    label: '✓ ${l10n.verified}',
                    bgColor: AppColors.successBg,
                    textColor: AppColors.success,
                  ),
              ],
            ),
          ],
          if (company.size != null) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedUserGroup,
                  color: AppColors.muted,
                  size: 14.r,
                ),
                SizedBox(width: 4.w),
                Text(
                  company.size!,
                  style: AppText.small.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ],
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedBriefcase01,
                    color: AppColors.muted,
                    size: 14.r,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    l10n.openJobsCount(jobCount),
                    style: AppText.small.copyWith(color: AppColors.muted),
                  ),
                ],
              ),
              HugeIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                color: AppColors.primary,
                size: 16.r,
              ),
            ],
          ),
        ],
      ),
        ),
      ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color? bgColor;
  final Color? textColor;

  const _Tag({required this.label, this.bgColor, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor ?? AppColors.primaryLight,
        borderRadius: AppRadius.pill,
      ),
      child: Text(
        label,
        style: AppText.small.copyWith(
          color: textColor ?? AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
