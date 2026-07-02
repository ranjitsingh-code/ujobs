import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/ujob_rich_text_display.dart';
import '../../../../core/providers/job_form_options_provider.dart';
import '../../../../core/providers/categories_provider.dart';
import '../../../../core/providers/feature_flags_provider.dart';
import '../post_job_wizard_provider.dart';

class Step6Review extends ConsumerWidget {
  final VoidCallback onPublish;

  const Step6Review({required this.onPublish, super.key});

  Widget _buildSummaryRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppText.small.copyWith(color: AppColors.muted),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppText.bodyMedium.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postJobWizardProvider);
    final optionsAsync = ref.watch(jobFormOptionsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final featureFlagsAsync = ref.watch(featureFlagsProvider);
    final options = optionsAsync.valueOrNull;
    final categories = categoriesAsync.valueOrNull;
    final jobApprovalRequired =
        featureFlagsAsync.valueOrNull?.jobApprovalRequired ?? false;

    if (options == null || categories == null) return const SizedBox();

    String getLabel(List list, String value) {
      try {
        return list.firstWhere((e) => e.value == value).label;
      } catch (_) {
        return value;
      }
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Job Summary Block
          Text('Job Summary', style: AppText.heading3),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: [
                _buildSummaryRow('Job Title', state.title),
                _buildSummaryRow(
                  'Job Category',
                  state.category == 'Other' && state.customCategory.isNotEmpty
                      ? '${state.category} (${state.customCategory})'
                      : state.category,
                ),
                _buildSummaryRow(
                  'Location',
                  '${state.city}${state.city.isNotEmpty && state.country.isNotEmpty ? ', ' : ''}${state.country}',
                ),
                _buildSummaryRow(
                  'Employment Type',
                  getLabel(options.employmentTypes, state.employmentType),
                ),
                _buildSummaryRow(
                  'Workplace',
                  getLabel(options.workplaceTypes, state.workplaceType),
                ),
                _buildSummaryRow('Vacancies', state.openings),
                _buildSummaryRow(
                  'Salary',
                  state.salaryMin.isNotEmpty
                      ? '${state.currency} ${state.salaryMin} - ${state.salaryMax}'
                      : 'Not specified',
                ),
                _buildSummaryRow(
                  'Min Education',
                  getLabel(options.minimumEducationLevels, state.education),
                ),
                if (state.experience.isNotEmpty)
                  _buildSummaryRow('Experience', '${state.experience} years'),
                if (state.languages.isNotEmpty)
                  _buildSummaryRow(
                    'Languages',
                    state.languages
                        .where((e) => e.trim().isNotEmpty)
                        .map((e) => e.trim())
                        .join(', '),
                  ),
                if (state.certifications.isNotEmpty)
                  _buildSummaryRow(
                    'Certifications',
                    state.certifications
                        .where((e) => e.trim().isNotEmpty)
                        .map((e) => e.trim())
                        .join(', '),
                  ),
                if (state.ageMin.isNotEmpty || state.ageMax.isNotEmpty)
                  _buildSummaryRow(
                    'Age Limit',
                    '${state.ageMin.isNotEmpty ? state.ageMin : 'Any'} - ${state.ageMax.isNotEmpty ? state.ageMax : 'Any'}',
                  ),
                if (state.preferredSkills.isNotEmpty)
                  _buildSummaryRow(
                    'Preferred Skills',
                    state.preferredSkills
                        .where((e) => e.trim().isNotEmpty)
                        .map((e) => e.trim())
                        .join(', '),
                  ),
                _buildSummaryRow(
                  'Apply Via',
                  getLabel(options.applicationMethods, state.applyVia),
                ),
                if (state.applyVia == 'email')
                  _buildSummaryRow('Email', state.applicationEmail),
                if (state.applyVia == 'external')
                  _buildSummaryRow('URL', state.applicationUrl),
                _buildSummaryRow(
                  'Resume',
                  getLabel(options.resumeRequirements, state.resumeRequirement),
                ),
                _buildSummaryRow(
                  'Cover Letter',
                  getLabel(
                    options.coverLetterPolicies,
                    state.coverLetterRequirement,
                  ),
                ),
                _buildSummaryRow('Deadline', state.deadline),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Benefits Block
          if (state.benefits.isNotEmpty) ...[
            Text(
              'Benefits (${state.benefits.length})',
              style: AppText.heading3,
            ),
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: state.benefits
                    .map(
                      (benefit) => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          benefit,
                          style: AppText.small.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            SizedBox(height: 24.h),
          ],

          // Description Preview
          if (state.description.isNotEmpty ||
              state.responsibilities.isNotEmpty ||
              state.requirements.isNotEmpty) ...[
            Text('Description Preview', style: AppText.heading3),
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.description.isNotEmpty) ...[
                    Text(
                      'Job Description',
                      style: AppText.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    UJobRichTextDisplay(content: state.description),
                    if (state.responsibilities.isNotEmpty ||
                        state.requirements.isNotEmpty)
                      SizedBox(height: 16.h),
                  ],
                  if (state.responsibilities.isNotEmpty) ...[
                    Text(
                      'Responsibilities',
                      style: AppText.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    UJobRichTextDisplay(content: state.responsibilities),
                    if (state.requirements.isNotEmpty) SizedBox(height: 16.h),
                  ],
                  if (state.requirements.isNotEmpty) ...[
                    Text(
                      'Requirements',
                      style: AppText.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    UJobRichTextDisplay(content: state.requirements),
                  ],
                ],
              ),
            ),
            SizedBox(height: 24.h),
          ],

          // Screening Questions
          if (state.screeningQuestions.isNotEmpty) ...[
            Text(
              'Screening Questions (${state.screeningQuestions.length})',
              style: AppText.heading3,
            ),
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: state.screeningQuestions.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final q = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: idx == state.screeningQuestions.length - 1
                          ? 0
                          : 12.h,
                    ),
                    child: Text(
                      '${idx + 1}. ${q.text}',
                      style: AppText.bodyMedium.copyWith(color: AppColors.text),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 24.h),
          ],

          // Ready to publish / review
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
                Text(
                  jobApprovalRequired
                      ? 'Ready to send for review?'
                      : 'Ready to publish?',
                  style: AppText.heading3,
                ),
                SizedBox(height: 6.h),
                Text(
                  jobApprovalRequired
                      ? 'Submitting will send the job to admin review before it goes live.'
                      : 'Publishing will make the job listing live immediately.',
                  style: AppText.bodyMedium.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),

          SizedBox(height: 60.h), // Padding for bottom action bar
        ],
      ),
    );
  }
}
