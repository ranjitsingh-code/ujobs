import re

with open('lib/features/employer/jobs/post_job_steps/step1_job_details.dart', 'r') as f:
    text = f.read()

# Add imports
imports = """import 'package:flutter/material.dart';
import '../../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/ujob_text_field.dart';
import '../../../../core/widgets/ujob_chip_group.dart';
import '../../../../core/widgets/ujob_dropdown_field.dart';
import '../../../../core/widgets/ujob_country_dropdown.dart';
import '../../../../core/widgets/ujob_rich_text_editor.dart';
import '../../../../core/providers/job_form_options_provider.dart';
import '../../../../core/providers/categories_provider.dart';
import '../post_job_wizard_provider.dart';"""

text = re.sub(r'import.*?post_job_wizard_provider\.dart\';', imports, text, flags=re.DOTALL)

# In build method, watch the providers
build_start = """  @override
  Widget build(BuildContext context, WidgetRef ref) {"""
build_replacement = """  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postJobWizardProvider);
    final notifier = ref.read(postJobWizardProvider.notifier);
    
    final optionsAsync = ref.watch(jobFormOptionsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    
    final options = optionsAsync.valueOrNull;
    final categories = categoriesAsync.valueOrNull;
    
    if (options == null || categories == null) {
      return Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
"""
text = text.replace("  @override\n  Widget build(BuildContext context, WidgetRef ref) {\n    final state = ref.watch(postJobWizardProvider);\n    final notifier = ref.read(postJobWizardProvider.notifier);", build_replacement)

# Replace Category dropdown
category_target = """          UJobDropdownField<String>.simple(
            label: context.l10n.jobCategory,
            value: state.category.isEmpty ? 'Technology' : state.category,
            options: const [
              ('Technology', 'Technology'),
              ('Healthcare', 'Healthcare'),
              ('Finance', 'Finance'),
              ('Education', 'Education'),
              ('Other', 'Other (Please specify)'),
            ],
            onChanged: (val) {
              if (val != null) {
                notifier.updateField(state.copyWith(category: val));
              }
            },
          ),
          if (state.category == 'Other') ...[
            SizedBox(height: 12.h),
            UJobTextField(
              label: 'Custom Category',
              hint: 'e.g. Aerospace Engineering',
              controller: TextEditingController(text: state.customCategory)
                ..selection = TextSelection.collapsed(
                  offset: state.customCategory.length,
                ),
              onChanged: (val) =>
                  notifier.updateField(state.copyWith(customCategory: val)),
            ),
          ],"""
category_replacement = """          UJobDropdownField<String>.simple(
            label: context.l10n.jobCategory,
            value: state.category.isEmpty && categories.isNotEmpty ? categories.first.id.toString() : state.category,
            options: categories.map((c) => (c.name, c.id.toString())).toList(),
            onChanged: (val) {
              if (val != null) {
                notifier.updateField(state.copyWith(category: val));
              }
            },
          ),"""
text = text.replace(category_target, category_replacement)

# Replace Employment Type
employment_target = """          UJobChipGroup<String>(
            options: const [
              'Full-Time',
              'Part-Time',
              'Contract',
              'Internship',
              'Temporary',
              'Freelance',
            ],
            selectedValue: state.employmentType.isEmpty
                ? 'Full-Time'
                : state.employmentType,
            labelBuilder: (val) => val,
            onChanged: (val) =>
                notifier.updateField(state.copyWith(employmentType: val)),
          ),"""
employment_replacement = """          UJobChipGroup<String>(
            options: options.employmentTypes.map((e) => e.value).toList(),
            selectedValue: state.employmentType.isEmpty && options.employmentTypes.isNotEmpty
                ? options.employmentTypes.first.value
                : state.employmentType,
            labelBuilder: (val) => options.employmentTypes.firstWhere((e) => e.value == val, orElse: () => options.employmentTypes.first).label,
            onChanged: (val) =>
                notifier.updateField(state.copyWith(employmentType: val)),
          ),"""
text = text.replace(employment_target, employment_replacement)

# Replace Workplace Type
workplace_target = """          UJobChipGroup<String>(
            options: const ['On-site', 'Remote', 'Hybrid'],
            selectedValue: state.workplaceType.isEmpty
                ? 'On-site'
                : state.workplaceType,
            labelBuilder: (val) => val,
            onChanged: (val) =>
                notifier.updateField(state.copyWith(workplaceType: val)),
          ),"""
workplace_replacement = """          UJobChipGroup<String>(
            options: options.workplaceTypes.map((e) => e.value).toList(),
            selectedValue: state.workplaceType.isEmpty && options.workplaceTypes.isNotEmpty
                ? options.workplaceTypes.first.value
                : state.workplaceType,
            labelBuilder: (val) => options.workplaceTypes.firstWhere((e) => e.value == val, orElse: () => options.workplaceTypes.first).label,
            onChanged: (val) =>
                notifier.updateField(state.copyWith(workplaceType: val)),
          ),"""
text = text.replace(workplace_target, workplace_replacement)

# Replace Currency and Period
currency_target = """                    Expanded(
                      child: UJobDropdownField<String>.simple(
                        label: context.l10n.currency,
                        value: state.currency.isEmpty ? 'USD' : state.currency,
                        options: const [
                          ('USD', 'USD'),
                          ('EUR', 'EUR'),
                          ('GBP', 'GBP'),
                          ('AED', 'AED'),
                          ('SAR', 'SAR'),
                        ],
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
                        value: state.salaryPeriod.isEmpty
                            ? 'Yearly'
                            : state.salaryPeriod,
                        options: const [
                          ('Hourly', 'Hourly'),
                          ('Monthly', 'Monthly'),
                          ('Yearly', 'Yearly'),
                        ],
                        onChanged: (val) {
                          if (val != null)
                            notifier.updateField(
                              state.copyWith(salaryPeriod: val),
                            );
                        },
                      ),
                    ),"""
currency_replacement = """                    Expanded(
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
                    ),"""
text = text.replace(currency_target, currency_replacement)

with open('lib/features/employer/jobs/post_job_steps/step1_job_details.dart', 'w') as f:
    f.write(text)

