import 'package:flutter/material.dart';
import '../../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/ujob_radio_card.dart';
import '../../../../core/widgets/ujob_date_picker_field.dart';
import '../../../../core/widgets/ujob_text_field.dart';
import '../../../../core/widgets/ujob_loading.dart';
import '../../../../core/providers/job_form_options_provider.dart';
import '../post_job_wizard_provider.dart';

class Step4Application extends ConsumerWidget {
  const Step4Application({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postJobWizardProvider);
    final notifier = ref.read(postJobWizardProvider.notifier);
    
    final optionsAsync = ref.watch(jobFormOptionsProvider);
    final options = optionsAsync.valueOrNull;
    
    if (options == null) {
      return UJobLoading(count: 3);
    }
    
    if (state.applyVia.isEmpty && options.applicationMethods.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.updateField(state.copyWith(
          applyVia: options.applicationMethods.first.value,
          resumeRequirement: options.resumeRequirements.isNotEmpty ? options.resumeRequirements.first.value : state.resumeRequirement,
          coverLetterRequirement: options.coverLetterPolicies.isNotEmpty ? options.coverLetterPolicies.first.value : state.coverLetterRequirement,
        ));
      });
    }

    final currentApplyVia = state.applyVia.isEmpty && options.applicationMethods.isNotEmpty 
        ? options.applicationMethods.first.value 
        : state.applyVia;
    final currentResume = state.resumeRequirement.isEmpty && options.resumeRequirements.isNotEmpty 
        ? options.resumeRequirements.first.value 
        : state.resumeRequirement;
    final currentCoverLetter = state.coverLetterRequirement.isEmpty && options.coverLetterPolicies.isNotEmpty 
        ? options.coverLetterPolicies.first.value 
        : state.coverLetterRequirement;


    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How should candidates apply?',
            style: AppText.label.copyWith(color: AppColors.muted),
          ),
          SizedBox(height: 8.h),
          ...options.applicationMethods.map((method) {
            String subtitle = '';
            if (method.value == 'internal') subtitle = 'Candidates apply directly through the platform';
            if (method.value == 'email') subtitle = 'Candidates send their CV to your email address';
            if (method.value == 'external') subtitle = 'Redirect candidates to your careers page';

            return UJobRadioCard<String>(
              title: method.label,
              subtitle: subtitle,
              value: method.value,
              groupValue: currentApplyVia,
              onChanged: (val) {
                notifier.updateField(state.copyWith(applyVia: val));
              },
            );
          }),
          if (currentApplyVia == 'email') ...[
            SizedBox(height: 12.h),
            UJobTextField(
              label: 'Application Email',
              hint: 'e.g. hr@company.com',
              keyboardType: TextInputType.emailAddress,
              controller: TextEditingController(text: state.applicationEmail)
                ..selection = TextSelection.collapsed(offset: state.applicationEmail.length),
              onChanged: (val) => notifier.updateField(state.copyWith(applicationEmail: val)),
            ),
          ],
          if (currentApplyVia == 'external') ...[
            SizedBox(height: 12.h),
            UJobTextField(
              label: 'Application URL',
              hint: 'e.g. https://company.com/careers',
              keyboardType: TextInputType.url,
              controller: TextEditingController(text: state.applicationUrl)
                ..selection = TextSelection.collapsed(offset: state.applicationUrl.length),
              onChanged: (val) => notifier.updateField(state.copyWith(applicationUrl: val)),
            ),
          ],
          SizedBox(height: 24.h),

          Text(
            'Resume / CV Requirement',
            style: AppText.label.copyWith(color: AppColors.muted),
          ),
          SizedBox(height: 8.h),
          ...options.resumeRequirements.map((req) {
            String subtitle = '';
            if (req.value == 'required') subtitle = 'Candidates must attach a CV';
            if (req.value == 'optional') subtitle = 'CV is encouraged but not mandatory';
            if (req.value == 'not_required') subtitle = 'No CV needed';

            return UJobRadioCard<String>(
              title: req.label,
              subtitle: subtitle,
              value: req.value,
              groupValue: currentResume,
              onChanged: (val) {
                notifier.updateField(state.copyWith(resumeRequirement: val));
              },
            );
          }),
          SizedBox(height: 24.h),

          Text(
            'Cover Letter',
            style: AppText.label.copyWith(color: AppColors.muted),
          ),
          SizedBox(height: 8.h),
          ...options.coverLetterPolicies.map((policy) {
            String subtitle = '';
            if (policy.value == 'optional') subtitle = 'Candidates may include a cover letter';
            if (policy.value == 'required') subtitle = 'Candidates must write a cover letter';
            if (policy.value == 'disabled') subtitle = 'Cover letter is hidden from the form';

            return UJobRadioCard<String>(
              title: policy.label,
              subtitle: subtitle,
              value: policy.value,
              groupValue: currentCoverLetter,
              onChanged: (val) {
                notifier.updateField(state.copyWith(coverLetterRequirement: val));
              },
            );
          }),
          SizedBox(height: 24.h),

          UJobDatePickerField(
            label: context.l10n.applicationDeadline,
            hint: context.l10n.selectADate,
            value: state.deadline,
            onChanged: (val) =>
                notifier.updateField(state.copyWith(deadline: val)),
          ),
          SizedBox(height: 60.h),
        ],
      ),
    );
  }
}
