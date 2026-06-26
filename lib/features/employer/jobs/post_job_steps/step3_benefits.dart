import '../../../../core/widgets/ujob_loading.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/ujob_multi_chip_group.dart';
import '../../../../core/providers/job_form_options_provider.dart';
import '../post_job_wizard_provider.dart';

class Step3Benefits extends ConsumerWidget {
  const Step3Benefits({super.key});



  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postJobWizardProvider);
    final notifier = ref.read(postJobWizardProvider.notifier);
    
    final optionsAsync = ref.watch(jobFormOptionsProvider);
    final options = optionsAsync.valueOrNull;
    
    if (options == null) {
      return UJobLoading(count: 3);
    }
    
    final availableBenefits = options.benefitsList;


    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${state.benefits.length}',
                style: AppText.heading3.copyWith(color: AppColors.primary),
              ),
              Text(
                ' benefits selected',
                style: AppText.bodyMedium.copyWith(color: AppColors.muted2),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          UJobMultiChipGroup<String>(
            options: availableBenefits,
            selectedValues: state.benefits,
            labelBuilder: (val) => val,
            onChanged: (values) =>
                notifier.updateField(state.copyWith(benefits: values)),
          ),
          SizedBox(height: 60.h), // Padding for bottom action bar
        ],
      ),
    );
  }
}
