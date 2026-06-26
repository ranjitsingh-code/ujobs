import re

with open('lib/features/employer/jobs/post_job_steps/step3_benefits.dart', 'r') as f:
    text = f.read()

# Add import
imports = """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/ujob_multi_chip_group.dart';
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
    
    final availableBenefits = options.benefitsList;
"""
text = text.replace("  @override\n  Widget build(BuildContext context, WidgetRef ref) {\n    final state = ref.watch(postJobWizardProvider);\n    final notifier = ref.read(postJobWizardProvider.notifier);", build_replacement)

# Remove the static list
static_list = """  final List<String> availableBenefits = const [
    'Flexible Schedule',
    'Work From Home',
    'Flexible Working Hours',
    'Paternity Leave',
    'Maternity Leave',
    'Training & Certifications',
    'Food Provided',
    'Health Insurance',
    'Life Insurance',
    'Provident Fund (PF)',
    'Paid Time Off (PTO)',
    'Paid Sick Leave',
    'Leave Encashment',
    'Internet Reimbursement',
    'Cell Phone Reimbursement',
    'Annual Bonus',
    'Commuter Assistance',
    'Transportation Allowance',
    'Performance Bonus',
    'Company Laptop',
  ];"""
text = text.replace(static_list, "")

with open('lib/features/employer/jobs/post_job_steps/step3_benefits.dart', 'w') as f:
    f.write(text)

