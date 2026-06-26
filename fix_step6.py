import re

with open('lib/features/employer/jobs/post_job_steps/step6_review.dart', 'r') as f:
    text = f.read()

# Replace requiredSkills with requirements
text = text.replace('state.requiredSkills', 'state.requirements')
text = text.replace('Required Skills', 'Requirements')

# Update providers to map values to labels
imports = """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/ujob_rich_text_editor.dart';
import '../../../../core/providers/job_form_options_provider.dart';
import '../../../../core/providers/categories_provider.dart';
import '../post_job_wizard_provider.dart';"""
text = re.sub(r'import.*?post_job_wizard_provider\.dart\';', imports, text, flags=re.DOTALL)

build_start = """  @override
  Widget build(BuildContext context, WidgetRef ref) {"""
build_replacement = """  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postJobWizardProvider);
    final optionsAsync = ref.watch(jobFormOptionsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final options = optionsAsync.valueOrNull;
    final categories = categoriesAsync.valueOrNull;
    
    if (options == null || categories == null) return const SizedBox();

    String getLabel(List list, String value) {
      try {
        return list.firstWhere((e) => e.value == value).label;
      } catch (_) {
        return value;
      }
    }
    
    final categoryName = state.category == 'Other' ? state.customCategory : 
        (categories.where((c) => c.id.toString() == state.category).firstOrNull?.name ?? state.category);
"""
text = text.replace("  @override\n  Widget build(BuildContext context, WidgetRef ref) {\n    final state = ref.watch(postJobWizardProvider);", build_replacement)

# Replace summary rows to use getLabel
text = text.replace("_buildSummaryRow('Category', state.category == 'Other' ? state.customCategory : state.category),", "_buildSummaryRow('Category', categoryName),")
text = text.replace("_buildSummaryRow('Employment', state.employmentType),", "_buildSummaryRow('Employment', getLabel(options.employmentTypes, state.employmentType)),")
text = text.replace("_buildSummaryRow('Workplace', state.workplaceType),", "_buildSummaryRow('Workplace', getLabel(options.workplaceTypes, state.workplaceType)),")
text = text.replace("_buildSummaryRow('Min Education', state.education),", "_buildSummaryRow('Min Education', getLabel(options.minimumEducationLevels, state.education)),")
text = text.replace("_buildSummaryRow('Apply Via', state.applyVia),", "_buildSummaryRow('Apply Via', getLabel(options.applicationMethods, state.applyVia)),")
text = text.replace("_buildSummaryRow('Resume', state.resumeRequirement),", "_buildSummaryRow('Resume', getLabel(options.resumeRequirements, state.resumeRequirement)),")
text = text.replace("_buildSummaryRow('Cover Letter', state.coverLetterRequirement),", "_buildSummaryRow('Cover Letter', getLabel(options.coverLetterPolicies, state.coverLetterRequirement)),")

# Add application email/url to summary
apply_via_target = "_buildSummaryRow('Apply Via', getLabel(options.applicationMethods, state.applyVia)),"
apply_via_replacement = """_buildSummaryRow('Apply Via', getLabel(options.applicationMethods, state.applyVia)),
                if (state.applyVia == 'email') _buildSummaryRow('Email', state.applicationEmail),
                if (state.applyVia == 'external') _buildSummaryRow('URL', state.applicationUrl),"""
text = text.replace(apply_via_target, apply_via_replacement)

with open('lib/features/employer/jobs/post_job_steps/step6_review.dart', 'w') as f:
    f.write(text)

