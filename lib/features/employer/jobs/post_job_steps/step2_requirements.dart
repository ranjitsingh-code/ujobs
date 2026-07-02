import 'package:flutter/material.dart';
import '../../../../../core/utils/l10n_extensions.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/ujob_text_field.dart';
import '../../../../core/widgets/ujob_loading.dart';
import '../../../../core/widgets/ujob_dropdown_field.dart';
import '../../../../core/widgets/ujob_autocomplete_tag_input.dart';
import '../../../../core/widgets/ujob_rich_text_editor.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/models/skill.dart';
import '../../../../core/providers/job_form_options_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/skills_provider.dart';
import '../../../../core/utils/api_error_parser.dart';
import '../../../../core/widgets/ujob_toast.dart';
import '../post_job_wizard_provider.dart';

class Step2Requirements extends ConsumerStatefulWidget {
  const Step2Requirements({super.key});

  @override
  ConsumerState<Step2Requirements> createState() => _Step2RequirementsState();
}

class _Step2RequirementsState extends ConsumerState<Step2Requirements> {
  List<Skill> _availableSkills = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final initialSkills = ref.read(publicSkillsProvider).valueOrNull;
      if (initialSkills != null && mounted) {
        setState(() {
          _availableSkills = initialSkills;
        });
      }
    });
  }

  Future<String?> _createEmployerSkill(
    BuildContext context,
    WidgetRef ref,
    String value,
  ) async {
    final text = value.trim();
    if (text.length < 2) {
      UJobToast.error(context, 'Skill name is too short');
      return null;
    }

    try {
      final dio = ref.read(dioClientProvider).dio;
      final response = await dio.post(
        Ep.employerSkills,
        data: {'name': text},
      );
      final createdSkill = Skill.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
      if (mounted &&
          !_availableSkills.any((skill) => skill.id == createdSkill.id)) {
        setState(() {
          _availableSkills = [..._availableSkills, createdSkill];
        });
      }
      return createdSkill.name;
    } on DioException catch (e) {
      if (context.mounted) {
        final apiError = parseApiErrorDetail(e);
        final statusCode = e.response?.statusCode;
        String message = 'Please try again.';

        if (statusCode == 404) {
          message = 'Skill add service is not available right now.';
        } else if (statusCode == 422 || apiError.code == 'CONTENT_VIOLATION') {
          message = apiError.message;
        } else if (statusCode == 400) {
          message = apiError.message;
        } else if (apiError.message.isNotEmpty &&
            apiError.message != 'A network error occurred.') {
          message = apiError.message;
        }

        UJobToast.error(
          context,
          'Could not add skill',
          sub: message,
        );
      }
      return null;
    } catch (e) {
      if (context.mounted) {
        UJobToast.error(
          context,
          'Could not add skill',
          sub: 'Please try again.',
        );
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postJobWizardProvider);
    final notifier = ref.read(postJobWizardProvider.notifier);
    
    final optionsAsync = ref.watch(jobFormOptionsProvider);
    final options = optionsAsync.valueOrNull;
    final publicSkills = ref.watch(publicSkillsProvider).valueOrNull ?? [];
    if (_availableSkills.isEmpty && publicSkills.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _availableSkills = publicSkills;
        });
      });
    }
    
    if (options == null) {
      return UJobLoading(count: 3);
    }


    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UJobDropdownField<String>.simple(
            label: context.l10n.minimumEducation,
            value: state.education.isEmpty && options.minimumEducationLevels.isNotEmpty ? options.minimumEducationLevels.first.value : state.education,
            options: options.minimumEducationLevels.map((e) => (e.label, e.value)).toList(),
            onChanged: (val) {
              if (val != null) {
                notifier.updateField(state.copyWith(education: val));
              }
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
            ),
          ),
          SizedBox(height: 20.h),

          UJobAutocompleteTagInput(
            label: context.l10n.preferredSkills,
            hint: context.l10n.typeToSearchOrAddASkill,
            tags: state.preferredSkills,
            suggestions: _availableSkills.map((s) => s.name).toList(),
            onCreateTag: (value) => _createEmployerSkill(context, ref, value),
            onChanged: (tags) =>
                notifier.updateField(state.copyWith(preferredSkills: tags)),
          ),
          SizedBox(height: 8.h),
          Text(
            'Select from the list. If not found, add a new skill.',
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
            controller: TextEditingController(text: state.languages.join(','))
              ..selection = TextSelection.collapsed(
                offset: state.languages.join(',').length,
              ),
            onChanged: (val) {
              final list = val.split(',').toList();
              notifier.updateField(state.copyWith(languages: list));
            },
          ),
          SizedBox(height: 20.h),

          UJobTextField(
            label: context.l10n.certifications,
            hint: context.l10n.egAwsPmpCfa,
            controller:
                TextEditingController(text: state.certifications.join(','))
                  ..selection = TextSelection.collapsed(
                    offset: state.certifications.join(',').length,
                  ),
            onChanged: (val) {
              final list = val.split(',').toList();
              notifier.updateField(state.copyWith(certifications: list));
            },
          ),
          SizedBox(height: 60.h), // Padding for bottom action bar
        ],
      ),
    );
  }
}
