import 'package:flutter/material.dart';
import '../../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/ujob_radio_card.dart';
import '../../../../core/widgets/ujob_date_picker_field.dart';
import '../post_job_wizard_provider.dart';

class Step4Application extends ConsumerWidget {
  const Step4Application({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postJobWizardProvider);
    final notifier = ref.read(postJobWizardProvider.notifier);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How should candidates apply?', style: AppText.label.copyWith(color: AppColors.muted)),
          SizedBox(height: 8.h),
          UJobRadioCard<String>(
            title: 'Apply via Job Portal',
            subtitle: 'Candidates apply directly through the platform',
            value: 'Job Portal',
            groupValue: state.applyVia,
            onChanged: (val) => notifier.updateField(state.copyWith(applyVia: val)),
          ),
          UJobRadioCard<String>(
            title: 'Apply via Email',
            subtitle: 'Candidates send their CV to your email address',
            value: 'Email',
            groupValue: state.applyVia,
            onChanged: (val) => notifier.updateField(state.copyWith(applyVia: val)),
          ),
          UJobRadioCard<String>(
            title: 'External Website',
            subtitle: 'Redirect candidates to your careers page',
            value: 'External Website',
            groupValue: state.applyVia,
            onChanged: (val) => notifier.updateField(state.copyWith(applyVia: val)),
          ),
          SizedBox(height: 24.h),

          Text('Resume / CV Requirement', style: AppText.label.copyWith(color: AppColors.muted)),
          SizedBox(height: 8.h),
          UJobRadioCard<String>(
            title: 'Required',
            subtitle: 'Candidates must attach a CV',
            value: 'Required',
            groupValue: state.resumeRequirement,
            onChanged: (val) => notifier.updateField(state.copyWith(resumeRequirement: val)),
          ),
          UJobRadioCard<String>(
            title: 'Optional',
            subtitle: 'CV is encouraged but not mandatory',
            value: 'Optional',
            groupValue: state.resumeRequirement,
            onChanged: (val) => notifier.updateField(state.copyWith(resumeRequirement: val)),
          ),
          UJobRadioCard<String>(
            title: 'Not Required',
            subtitle: 'No CV needed',
            value: 'Not Required',
            groupValue: state.resumeRequirement,
            onChanged: (val) => notifier.updateField(state.copyWith(resumeRequirement: val)),
          ),
          SizedBox(height: 24.h),

          Text('Cover Letter', style: AppText.label.copyWith(color: AppColors.muted)),
          SizedBox(height: 8.h),
          UJobRadioCard<String>(
            title: 'Optional',
            subtitle: 'Candidates may include a cover letter',
            value: 'Optional',
            groupValue: state.coverLetterRequirement,
            onChanged: (val) => notifier.updateField(state.copyWith(coverLetterRequirement: val)),
          ),
          UJobRadioCard<String>(
            title: 'Required',
            subtitle: 'Candidates must write a cover letter',
            value: 'Required',
            groupValue: state.coverLetterRequirement,
            onChanged: (val) => notifier.updateField(state.copyWith(coverLetterRequirement: val)),
          ),
          UJobRadioCard<String>(
            title: 'Disabled',
            subtitle: 'Cover letter is hidden from the form',
            value: 'Disabled',
            groupValue: state.coverLetterRequirement,
            onChanged: (val) => notifier.updateField(state.copyWith(coverLetterRequirement: val)),
          ),
          SizedBox(height: 24.h),

          UJobDatePickerField(
            label: context.l10n.applicationDeadline,
            hint: context.l10n.selectADate,
            value: state.deadline,
            onChanged: (val) => notifier.updateField(state.copyWith(deadline: val)),
          ),
          SizedBox(height: 60.h),
        ],
      ),
    );
  }
}
