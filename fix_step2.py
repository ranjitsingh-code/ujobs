import re

with open('lib/features/employer/jobs/post_job_steps/step2_requirements.dart', 'r') as f:
    text = f.read()

# Add import
imports = """import 'package:flutter/material.dart';
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
import '../../../../core/providers/job_form_options_provider.dart';
import '../post_job_wizard_provider.dart';"""
text = re.sub(r'import.*?post_job_wizard_provider\.dart\';', imports, text, flags=re.DOTALL)

# Build method changes
build_start = """  @override
  Widget build(BuildContext context, WidgetRef ref) {"""
build_replacement = """  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postJobWizardProvider);
    final notifier = ref.read(postJobWizardProvider.notifier);
    
    final optionsAsync = ref.watch(jobFormOptionsProvider);
    final options = optionsAsync.valueOrNull;
    
    if (options == null) {
      return Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
"""
text = text.replace("  @override\n  Widget build(BuildContext context, WidgetRef ref) {\n    final state = ref.watch(postJobWizardProvider);\n    final notifier = ref.read(postJobWizardProvider.notifier);", build_replacement)

# Minimum Education
edu_target = """          UJobDropdownField<String>.simple(
            label: context.l10n.minimumEducation,
            value: state.education,
            options: const [
              ('No requirement', 'No requirement'),
              ('High School', 'High School'),
              ('Bachelor\\'s Degree', 'Bachelor\\'s Degree'),
              ('Master\\'s Degree', 'Master\\'s Degree'),
              ('PhD', 'PhD'),
            ],
            onChanged: (val) {
              if (val != null)
                notifier.updateField(state.copyWith(education: val));
            },
          ),"""
edu_replacement = """          UJobDropdownField<String>.simple(
            label: context.l10n.minimumEducation,
            value: state.education.isEmpty && options.minimumEducationLevels.isNotEmpty ? options.minimumEducationLevels.first.value : state.education,
            options: options.minimumEducationLevels.map((e) => (e.label, e.value)).toList(),
            onChanged: (val) {
              if (val != null)
                notifier.updateField(state.copyWith(education: val));
            },
          ),"""
text = text.replace(edu_target, edu_replacement)

# Required Skills -> Requirements
req_skills_target = """            onTap: () => showUJobRichTextEditor(
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
            ),"""
req_skills_replacement = """            onTap: () => showUJobRichTextEditor(
              context: context,
              title: 'Requirements',
              initialValue: state.requirements,
              onSave: (val) =>
                  notifier.updateField(state.copyWith(requirements: val)),
            ),
            child: UJobTextField(
              label: 'Requirements',
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
                text: getPlainTextFromQuillJson(state.requirements),
              ),
              onTap: () => showUJobRichTextEditor(
                context: context,
                title: 'Requirements',
                initialValue: state.requirements,
                onSave: (val) =>
                    notifier.updateField(state.copyWith(requirements: val)),
              ),
            ),"""
text = text.replace(req_skills_target, req_skills_replacement)

# Preferred Skills
pref_skills_target = """          UJobAutocompleteTagInput(
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
          ),"""
pref_skills_replacement = """          UJobAutocompleteTagInput(
            label: context.l10n.preferredSkills,
            hint: context.l10n.typeToSearchOrAddASkill,
            tags: state.preferredSkills,
            suggestions: options.preferredSkillsList.map((s) => s.name).toList(),
            onChanged: (tags) =>
                notifier.updateField(state.copyWith(preferredSkills: tags)),
          ),"""
text = text.replace(pref_skills_target, pref_skills_replacement)

with open('lib/features/employer/jobs/post_job_steps/step2_requirements.dart', 'w') as f:
    f.write(text)

