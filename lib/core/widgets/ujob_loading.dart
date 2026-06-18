import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class UJobLoading extends StatelessWidget {
  final int count;
  final double? itemHeight;

  const UJobLoading({this.count = 4, this.itemHeight, super.key});

  @override
  Widget build(BuildContext context) => ListView.builder(
    padding: AppSpacing.pagePad,
    itemCount: count,
    physics: const NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    itemBuilder: (_, _) => Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Shimmer.fromColors(
        baseColor: AppColors.grey100,
        highlightColor: AppColors.white,
        child: Container(
          height: itemHeight?.h ?? 80.h,
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: AppRadius.md,
          ),
        ),
      ),
    ),
  );
}

class UJobLoadingCard extends StatelessWidget {
  const UJobLoadingCard({super.key});

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: AppColors.grey100,
    highlightColor: AppColors.white,
    child: Container(
      height: 80.h,
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: AppRadius.md,
      ),
    ),
  );
}
