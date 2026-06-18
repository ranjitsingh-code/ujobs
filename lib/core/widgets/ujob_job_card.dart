import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/job.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class UJobJobCard extends StatelessWidget {
  final Job job;
  final VoidCallback? onTap;
  final VoidCallback? onSaveTap;
  final bool showCompany;

  const UJobJobCard({
    required this.job,
    this.onTap,
    this.onSaveTap,
    this.showCompany = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.xl,
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showCompany && job.company?.logo != null)
                    Container(
                      width: 48.r,
                      height: 48.r,
                      decoration: BoxDecoration(
                        color: AppColors.borderLight,
                        borderRadius: AppRadius.md,
                      ),
                      child: ClipRRect(
                        borderRadius: AppRadius.md,
                        child: Image.network(
                          job.company!.logo!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => HugeIcon(icon: HugeIcons.strokeRoundedBuilding04, color: AppColors.muted, size: 20.r),
                        ),
                      ),
                    )
                  else if (showCompany)
                    Container(
                      width: 48.r,
                      height: 48.r,
                      decoration: BoxDecoration(
                        color: AppColors.borderLight,
                        borderRadius: AppRadius.md,
                      ),
                      child: HugeIcon(icon: HugeIcons.strokeRoundedBuilding04, color: AppColors.muted, size: 20.r),
                    ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: AppText.h3.copyWith(fontSize: 16.sp),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (showCompany && job.company != null)
                          Text(
                            job.company!.name,
                            style: AppText.bodyMedium.copyWith(color: AppColors.muted),
                          ),
                      ],
                    ),
                  ),
                  if (onSaveTap != null)
                    IconButton(
                      onPressed: onSaveTap,
                      icon: HugeIcon(
                        icon: job.isSaved ? HugeIcons.strokeRoundedBookmark01 : HugeIcons.strokeRoundedBookmark02,
                        color: job.isSaved ? AppColors.seekPrimary : AppColors.muted,
                        size: 24.r,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  _Badge(label: job.employmentType.replaceAll('_', ' ').toUpperCase()),
                  SizedBox(width: 8.w),
                  _Badge(label: job.workplaceType.toUpperCase()),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    job.salaryMax != null 
                      ? '${job.salaryMin} - ${job.salaryMax}' 
                      : (job.salaryMin ?? 'Negotiable'),
                    style: AppText.bodySemiBold.copyWith(color: AppColors.empPrimary),
                  ),
                  if (job.createdAt != null)
                    Text(
                      timeago.format(job.createdAt!),
                      style: AppText.bodySmall.copyWith(color: AppColors.muted),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: AppRadius.pill,
      ),
      child: Text(
        label,
        style: AppText.bodySemiBold.copyWith(
          fontSize: 10.sp,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
