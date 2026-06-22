import 'package:flutter/material.dart';
import '../../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/ujob_button.dart';
import '../../../../core/widgets/ujob_text_field.dart';
import '../post_job_wizard_provider.dart';

class Step5Screening extends ConsumerWidget {
  const Step5Screening({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postJobWizardProvider);
    final notifier = ref.read(postJobWizardProvider.notifier);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Screening Questions (optional)', style: AppText.heading3),
                SizedBox(height: 6.h),
                Text(
                  'Add questions that applicants must answer when applying. All questions are mandatory by default.',
                  style: AppText.bodyMedium.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.screeningQuestions.length,
            itemBuilder: (context, index) {
              final q = state.screeningQuestions[index];
              return Container(
                margin: EdgeInsets.only(bottom: 16.h),
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Question ${index + 1}',
                          style: AppText.label.copyWith(color: AppColors.muted),
                        ),
                        GestureDetector(
                          onTap: () {
                            final list = List<ScreeningQuestion>.from(
                              state.screeningQuestions,
                            );
                            list.removeAt(index);
                            notifier.updateField(
                              state.copyWith(screeningQuestions: list),
                            );
                          },
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedDelete02,
                            color: AppColors.error,
                            size: 20.r,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    UJobTextField(
                      label: '',
                      hint: context.l10n.egDoYouKnowSwift,
                      controller: TextEditingController(text: q.text)
                        ..selection = TextSelection.collapsed(
                          offset: q.text.length,
                        ),
                      onChanged: (val) {
                        final list = List<ScreeningQuestion>.from(
                          state.screeningQuestions,
                        );
                        list[index] = q.copyWith(text: val);
                        notifier.updateField(
                          state.copyWith(screeningQuestions: list),
                        );
                      },
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                          color: AppColors.primary,
                          size: 16.r,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Required — applicants must answer',
                          style: AppText.small.copyWith(
                            color: AppColors.muted2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          if (state.screeningQuestions.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Text(
                  'No screening questions added yet.',
                  style: AppText.bodyMedium.copyWith(color: AppColors.muted2),
                ),
              ),
            ),

          SizedBox(height: 12.h),
          UJobButton(
            label: context.l10n.addAnotherQuestion,
            outlined: true,
            color: AppColors.primary,
            onTap: () {
              final list = List<ScreeningQuestion>.from(
                state.screeningQuestions,
              )..add(const ScreeningQuestion(text: ''));
              notifier.updateField(state.copyWith(screeningQuestions: list));
            },
          ),

          SizedBox(height: 60.h),
        ],
      ),
    );
  }
}
