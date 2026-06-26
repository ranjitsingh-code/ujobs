import 'package:flutter/material.dart';
import '../../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/ujob_text_field.dart';
import '../../../../core/widgets/ujob_loading.dart';
import '../../../../core/widgets/ujob_chip_group.dart';
import '../../../../core/widgets/ujob_dropdown_field.dart';
import '../../../../core/widgets/ujob_rich_text_editor.dart';
import '../../../../core/providers/job_form_options_provider.dart';
import '../../../../core/providers/categories_provider.dart';
import '../post_job_wizard_provider.dart';

class Step1JobDetails extends ConsumerWidget {
  const Step1JobDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postJobWizardProvider);
    final notifier = ref.read(postJobWizardProvider.notifier);
    
    final optionsAsync = ref.watch(jobFormOptionsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    
    final options = optionsAsync.valueOrNull;
    final categories = categoriesAsync.valueOrNull;
    
    if (options == null || categories == null) {
      return UJobLoading(count: 3);
    }


    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UJobTextField(
            label: context.l10n.jobTitle,
            hint: context.l10n.egSeniorUxDesigner,
            controller: TextEditingController(text: state.title)
              ..selection = TextSelection.collapsed(offset: state.title.length),
            onChanged: (val) =>
                notifier.updateField(state.copyWith(title: val)),
          ),
          SizedBox(height: 16.h),

          UJobDropdownField<String>.simple(
            label: context.l10n.jobCategory,
            value: state.category.isEmpty 
                ? (categories.isNotEmpty ? categories.first.id : '') 
                : state.category,
            options: [
              ...categories.map((c) => (c.name, c.id)),
              ('Other', 'Other'),
            ],
            onChanged: (val) {
              if (val != null) {
                notifier.updateField(state.copyWith(category: val));
              }
            },
          ),
          SizedBox(height: 16.h),

          if (state.category == 'Other') ...[
            UJobTextField(
              label: context.l10n.specifyCategory,
              hint: context.l10n.egSpaceExploration,
              controller: TextEditingController(text: state.customCategory)
                ..selection = TextSelection.collapsed(
                  offset: state.customCategory.length,
                ),
              onChanged: (val) =>
                  notifier.updateField(state.copyWith(customCategory: val)),
            ),
            SizedBox(height: 16.h),
          ],

          UJobTextField(
            label: context.l10n.numberOfOpenings,
            hint: context.l10n.eg1,
            keyboardType: TextInputType.number,
            controller: TextEditingController(text: state.openings)
              ..selection = TextSelection.collapsed(
                offset: state.openings.length,
              ),
            onChanged: (val) =>
                notifier.updateField(state.copyWith(openings: val)),
          ),
          SizedBox(height: 16.h),

          Text(
            'Employment Type',
            style: AppText.label.copyWith(color: AppColors.muted),
          ),
          SizedBox(height: 8.h),
          UJobChipGroup<String>(
            options: options.employmentTypes.map((e) => e.value).toList(),
            selectedValue: state.employmentType.isEmpty && options.employmentTypes.isNotEmpty
                ? options.employmentTypes.first.value
                : state.employmentType,
            labelBuilder: (val) => options.employmentTypes.firstWhere((e) => e.value == val, orElse: () => options.employmentTypes.first).label,
            onChanged: (val) =>
                notifier.updateField(state.copyWith(employmentType: val)),
          ),
          SizedBox(height: 20.h),

          Text(
            'Workplace Type',
            style: AppText.label.copyWith(color: AppColors.muted),
          ),
          SizedBox(height: 8.h),
          UJobChipGroup<String>(
            options: options.workplaceTypes.map((e) => e.value).toList(),
            selectedValue: state.workplaceType.isEmpty && options.workplaceTypes.isNotEmpty
                ? options.workplaceTypes.first.value
                : state.workplaceType,
            labelBuilder: (val) => options.workplaceTypes.firstWhere((e) => e.value == val, orElse: () => options.workplaceTypes.first).label,
            onChanged: (val) =>
                notifier.updateField(state.copyWith(workplaceType: val)),
          ),
          SizedBox(height: 20.h),

          UJobTextField(
            label: context.l10n.city,
            hint: context.l10n.cityHint,
            controller: TextEditingController(text: state.city)
              ..selection = TextSelection.collapsed(offset: state.city.length),
            onChanged: (val) => notifier.updateField(state.copyWith(city: val)),
          ),
          SizedBox(height: 16.h),

          UJobCountryDropdown(
            value: state.country.isEmpty ? 'United Kingdom' : state.country,
            onChanged: (val) {
              if (val != null)
                notifier.updateField(state.copyWith(country: val));
            },
          ),
          SizedBox(height: 16.h),

          Text(
            'Salary Details (Optional)',
            style: AppText.label.copyWith(color: AppColors.muted),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: UJobDropdownField<String>.simple(
                        label: context.l10n.currency,
                        value: state.currency.isEmpty && options.currencies.isNotEmpty ? options.currencies.first.value : state.currency,
                        options: options.currencies.map((c) => (c.label, c.value)).toList(),
                        onChanged: (val) {
                          if (val != null)
                            notifier.updateField(state.copyWith(currency: val));
                        },
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: UJobDropdownField<String>.simple(
                        label: context.l10n.period,
                        value: state.salaryPeriod.isEmpty && options.salaryPeriods.isNotEmpty
                            ? options.salaryPeriods.first.value
                            : state.salaryPeriod,
                        options: options.salaryPeriods.map((p) => (p.label, p.value)).toList(),
                        onChanged: (val) {
                          if (val != null)
                            notifier.updateField(
                              state.copyWith(salaryPeriod: val),
                            );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: UJobTextField(
                        label: context.l10n.minimum,
                        hint: context.l10n.eg50000,
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(text: state.salaryMin)
                          ..selection = TextSelection.collapsed(
                            offset: state.salaryMin.length,
                          ),
                        onChanged: (val) => notifier.updateField(
                          state.copyWith(salaryMin: val),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: UJobTextField(
                        label: context.l10n.maximum,
                        hint: context.l10n.eg70000,
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(text: state.salaryMax)
                          ..selection = TextSelection.collapsed(
                            offset: state.salaryMax.length,
                          ),
                        onChanged: (val) => notifier.updateField(
                          state.copyWith(salaryMax: val),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          GestureDetector(
            onTap: () => showUJobRichTextEditor(
              context: context,
              title: 'Job Description',
              initialValue: state.description,
              onSave: (val) =>
                  notifier.updateField(state.copyWith(description: val)),
            ),
            child: UJobTextField(
              label: context.l10n.jobDescription1,
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
                text: getPlainTextFromQuillJson(state.description),
              ),
              onTap: () => showUJobRichTextEditor(
                context: context,
                title: 'Job Description',
                initialValue: state.description,
                onSave: (val) =>
                    notifier.updateField(state.copyWith(description: val)),
              ),
            ),
          ),
          SizedBox(height: 20.h),

          GestureDetector(
            onTap: () => showUJobRichTextEditor(
              context: context,
              title: 'Responsibilities',
              initialValue: state.responsibilities,
              onSave: (val) =>
                  notifier.updateField(state.copyWith(responsibilities: val)),
            ),
            child: UJobTextField(
              label: context.l10n.responsibilities,
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
                text: getPlainTextFromQuillJson(state.responsibilities),
              ),
              onTap: () => showUJobRichTextEditor(
                context: context,
                title: 'Responsibilities',
                initialValue: state.responsibilities,
                onSave: (val) =>
                    notifier.updateField(state.copyWith(responsibilities: val)),
              ),
            ),
          ),
          SizedBox(height: 60.h), // Padding for bottom action bar
        ],
      ),
    );
  }
}
