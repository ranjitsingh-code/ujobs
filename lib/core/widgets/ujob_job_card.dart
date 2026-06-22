import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/job.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'ujob_image.dart';

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
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadius.xl,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.xl,
          child: Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: AppRadius.xl,
              boxShadow: AppShadow.card(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showCompany && job.company?.logo != null)
                      UJobImage(
                        path: job.company!.logo!,
                        width: 48.r,
                        height: 48.r,
                        fit: BoxFit.cover,
                        borderRadius: AppRadius.md,
                      )
                    else if (showCompany)
                      Container(
                        width: 48.r,
                        height: 48.r,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.seekSurface,
                          borderRadius: AppRadius.md,
                        ),
                        child: HugeIcon(icon: HugeIcons.strokeRoundedBuilding03, color: AppColors.seekPrimary, size: 24.r),
                      ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            style: AppText.heading3.copyWith(fontSize: 16.sp),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              if (showCompany)
                                Flexible(
                                  child: Text(
                                    job.company?.name ?? 'TechCorp Solutions',
                                    style: AppText.bodyMedium.copyWith(color: AppColors.muted2),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              if (job.location != null && job.location!.isNotEmpty) ...[
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                                  child: Container(width: 4.r, height: 4.r, decoration: const BoxDecoration(color: AppColors.border, shape: BoxShape.circle)),
                                ),
                                Flexible(
                                  child: Text(
                                    job.location!,
                                    style: AppText.bodyMedium.copyWith(color: AppColors.muted2),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (onSaveTap != null)
                      IconButton(
                        onPressed: onSaveTap,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        icon: HugeIcon(
                          icon: job.isSaved ? HugeIcons.strokeRoundedBookmark01 : HugeIcons.strokeRoundedBookmark02,
                          color: job.isSaved ? AppColors.seekPrimary : AppColors.muted,
                          size: 24.r,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 16.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _Badge(label: job.employmentType.replaceAll('_', ' ').toUpperCase()),
                    _Badge(label: job.workplaceType.toUpperCase()),
                    if (job.category != null && job.category!.isNotEmpty)
                      _Badge(label: job.category!.toUpperCase()),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (job.createdAt != null)
                            Row(
                              children: [
                                Text(
                                  timeago.format(job.createdAt!),
                                  style: AppText.bodySmall.copyWith(color: AppColors.muted),
                                ),
                                if (job.applicantCount > 0) ...[
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                                    child: Container(width: 3.r, height: 3.r, decoration: const BoxDecoration(color: AppColors.border, shape: BoxShape.circle)),
                                  ),
                                  Text(
                                    '${job.applicantCount} applied',
                                    style: AppText.bodySmall.copyWith(color: AppColors.muted),
                                  ),
                                ],
                              ],
                            ),
                          SizedBox(height: 4.h),
                          Text(
                            'View details →',
                            style: AppText.bodyBold.copyWith(color: AppColors.seekPrimary),
                          ),
                        ],
                      ),
                    ),
                    if (job.salaryMin != null)
                      Text(
                        job.salaryMax != null 
                          ? '${job.salaryMin} - ${job.salaryMax}' 
                          : job.salaryMin!,
                        style: AppText.heading3.copyWith(color: AppColors.text, fontSize: 16.sp),
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
