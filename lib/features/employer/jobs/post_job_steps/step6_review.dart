import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/ujob_rich_text_editor.dart';
import '../../../../core/widgets/ujob_rich_text_display.dart';
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
                _buildSummaryRow('Employment Type', state.employmentType),
                _buildSummaryRow('Workplace', state.workplaceType),
                _buildSummaryRow('Vacancies', state.openings),
                _buildSummaryRow(
                  'Salary',
                  state.salaryMin.isNotEmpty
                      ? '${state.currency} ${state.salaryMin} - ${state.salaryMax}'
                      : 'Not specified',
                ),
                _buildSummaryRow('Min Education', state.education),
                if (state.experience.isNotEmpty)
                  _buildSummaryRow('Experience', '${state.experience} years'),
                if (state.languages.isNotEmpty)
                  _buildSummaryRow('Languages', state.languages.join(', ')),
                if (state.certifications.isNotEmpty)
                  _buildSummaryRow(
                    'Certifications',
                    state.certifications.join(', '),
                  ),
                if (state.ageMin.isNotEmpty || state.ageMax.isNotEmpty)
                  _buildSummaryRow(
                    'Age Limit',
                    '${state.ageMin.isNotEmpty ? state.ageMin : 'Any'} - ${state.ageMax.isNotEmpty ? state.ageMax : 'Any'}',
                  ),
                if (state.preferredSkills.isNotEmpty)
                  _buildSummaryRow(
                    'Preferred Skills',
                    state.preferredSkills.join(', '),
                  ),
                _buildSummaryRow('Apply Via', state.applyVia),
                _buildSummaryRow('Resume', state.resumeRequirement),
                _buildSummaryRow('Cover Letter', state.coverLetterRequirement),
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
              state.requiredSkills.isNotEmpty) ...[
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
                        state.requiredSkills.isNotEmpty)
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
                    if (state.requiredSkills.isNotEmpty) SizedBox(height: 16.h),
                  ],
                  if (state.requiredSkills.isNotEmpty) ...[
                    Text(
                      'Required Skills',
                      style: AppText.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    UJobRichTextDisplay(content: state.requiredSkills),
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

          // Ready to publish
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
                Text('Ready to publish?', style: AppText.heading3),
                SizedBox(height: 6.h),
                Text(
                  'Saving will update the job listing immediately.',
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
