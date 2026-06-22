import 'package:flutter/material.dart';
import '../../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/ujob_text_field.dart';
import '../../../../core/widgets/ujob_dropdown_field.dart';
import '../../../../core/widgets/ujob_autocomplete_tag_input.dart';
import '../../../../core/widgets/ujob_rich_text_editor.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../post_job_wizard_provider.dart';

class Step2Requirements extends ConsumerWidget {
  const Step2Requirements({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postJobWizardProvider);
    final notifier = ref.read(postJobWizardProvider.notifier);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UJobDropdownField<String>.simple(
            label: context.l10n.minimumEducation,
            value: state.education,
            options: const [
              ('No requirement', 'No requirement'),
              ('High School', 'High School'),
              ('Bachelor\'s Degree', 'Bachelor\'s Degree'),
              ('Master\'s Degree', 'Master\'s Degree'),
              ('PhD', 'PhD'),
            ],
            onChanged: (val) {
              if (val != null)
                notifier.updateField(state.copyWith(education: val));
            },
          ),
          SizedBox(height: 20.h),

          UJobTextField(
            label: context.l10n.experienceRequiredYears,
            hint: context.l10n.eg2,
            keyboardType: TextInputType.number,
            controller: TextEditingController(text: state.experience)
              ..selection = TextSelection.collapsed(
                offset: state.experience.length,
              ),
            onChanged: (val) =>
                notifier.updateField(state.copyWith(experience: val)),
          ),
          SizedBox(height: 20.h),

          GestureDetector(
            onTap: () => showUJobRichTextEditor(
              context: context,
              title: 'Required Skills',
              initialValue: state.requiredSkills,
              onSave: (val) =>
                  notifier.updateField(state.copyWith(requiredSkills: val)),
            ),
            child: UJobTextField(
              label: context.l10n.requiredSkills,
              hint: context.l10n.tapToOpenEditor,
              minLines: 5,
              maxLines: 10,
              readOnly: true,
              labelTrailing: HugeIcon(
                icon: HugeIcons.strokeRoundedMaximize01,
                color: AppColors.primary,
                size: 20.r,
              ),
              controller: TextEditingController(
                text: getPlainTextFromQuillJson(state.requiredSkills),
              ),
              onTap: () => showUJobRichTextEditor(
                context: context,
                title: 'Required Skills',
                initialValue: state.requiredSkills,
                onSave: (val) =>
                    notifier.updateField(state.copyWith(requiredSkills: val)),
              ),
            ),
          ),
          SizedBox(height: 20.h),

          UJobAutocompleteTagInput(
            label: context.l10n.preferredSkills,
            hint: context.l10n.typeToSearchOrAddASkill,
            tags: state.preferredSkills,
            suggestions: const [
              'Flutter',
              'Dart',
              'Python',
              'Data Analysis',
              'React',
              'Node.js',
              'UI/UX Design',
              'Java',
              'Swift',
              'Kotlin',
              'Go',
              'C++',
            ],
            onChanged: (tags) =>
                notifier.updateField(state.copyWith(preferredSkills: tags)),
          ),
          SizedBox(height: 8.h),
          Text(
            'Select from the list or type a custom skill and tap done.',
            style: AppText.small.copyWith(color: AppColors.muted),
          ),
          SizedBox(height: 2.h),
          Text(
            'Nice to have — not mandatory',
            style: AppText.small.copyWith(color: AppColors.muted),
          ),
          SizedBox(height: 20.h),

          UJobTextField(
            label: context.l10n.languagesRequired,
            hint: context.l10n.egEnglishHindi,
            controller: TextEditingController(text: state.languages.join(', '))
              ..selection = TextSelection.collapsed(
                offset: state.languages.join(', ').length,
              ),
            onChanged: (val) {
              final list = val
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
              notifier.updateField(state.copyWith(languages: list));
            },
          ),
          SizedBox(height: 20.h),

          UJobTextField(
            label: context.l10n.certifications,
            hint: context.l10n.egAwsPmpCfa,
            controller:
                TextEditingController(text: state.certifications.join(', '))
                  ..selection = TextSelection.collapsed(
                    offset: state.certifications.join(', ').length,
                  ),
            onChanged: (val) {
              final list = val
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
              notifier.updateField(state.copyWith(certifications: list));
            },
          ),
          SizedBox(height: 20.h),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: UJobTextField(
                  label: context.l10n.ageMinOptional,
                  hint: context.l10n.eg22,
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: state.ageMin)
                    ..selection = TextSelection.collapsed(
                      offset: state.ageMin.length,
                    ),
                  onChanged: (val) =>
                      notifier.updateField(state.copyWith(ageMin: val)),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: UJobTextField(
                  label: context.l10n.ageMaxOptional,
                  hint: context.l10n.eg45,
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: state.ageMax)
                    ..selection = TextSelection.collapsed(
                      offset: state.ageMax.length,
                    ),
                  onChanged: (val) =>
                      notifier.updateField(state.copyWith(ageMax: val)),
                ),
              ),
            ],
          ),
          SizedBox(height: 60.h), // Padding for bottom action bar
        ],
      ),
    );
  }
}
