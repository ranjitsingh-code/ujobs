import '../../../core/providers/job_form_options_provider.dart';
import '../../../core/providers/categories_provider.dart';
import '../../../core/providers/feature_flags_provider.dart';
import 'dart:convert';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../core/api/api_endpoints.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/job.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/api_error_parser.dart';
import '../../../core/utils/l10n_extensions.dart';
import '../../../core/widgets/ujob_button.dart';
import '../../../core/widgets/ujob_app_bar.dart';
import '../../../core/widgets/ujob_loading.dart';
import '../../../core/widgets/ujob_wizard_stepper.dart';
import '../../../core/widgets/ujob_toast.dart';
import '../../../core/widgets/ujob_rich_text_editor.dart';
import 'post_job_wizard_provider.dart';
import '../../../core/providers/auth_provider.dart';
import 'employer_job_provider.dart';
import '../dashboard/employer_dashboard_provider.dart';

// Import step views (these will be created next)
import 'post_job_steps/step1_job_details.dart';
import 'post_job_steps/step2_requirements.dart';
import 'post_job_steps/step3_benefits.dart';
import 'post_job_steps/step4_application.dart';
import 'post_job_steps/step5_screening.dart';
import 'post_job_steps/step6_review.dart';

class PostJobScreen extends ConsumerStatefulWidget {
  final Job? job;

  const PostJobScreen({this.job, super.key});

  @override
  ConsumerState<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends ConsumerState<PostJobScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 6;

  bool _isLoadingJobDetail = false;

  bool get _isEditing => widget.job != null;

  @override
  void initState() {
    super.initState();
    if (widget.job != null) {
      _isLoadingJobDetail = true;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.job == null) return;

      // The Job passed via route `extra` may come from a list endpoint
      // (My Jobs / Dashboard) that only returns summary fields. Always
      // re-fetch the full job detail so every entry point prefills correctly.
      Job job = widget.job!;
      try {
        job = await ref.read(employerJobDetailProvider(job.id).future);
      } catch (_) {
        // Fall back to whatever was passed via extra if the refetch fails.
      }

      if (!mounted) return;

      ref
          .read(postJobWizardProvider.notifier)
          .updateField(
            PostJobState(
              title: job.title,
              description: job.description,
              category: job.categoryId ?? job.category ?? '',
              openings: job.openings ?? '1',
              employmentType: job.employmentType,
              workplaceType: job.workplaceType,
              city: job.location ?? '',
              country: job.country ?? '',
              salaryMin: job.salaryMin ?? '',
              salaryMax: job.salaryMax ?? '',
              currency: job.salaryCurrency ?? 'GBP',
              salaryPeriod: job.salaryPeriod ?? 'monthly',
              experience: job.experienceLevel ?? '',
              requirements: job.requiredSkills ?? '',
              responsibilities: job.responsibilities ?? '',
              education: job.education ?? '',
              preferredSkills: job.preferredSkills ?? [],
              languages: job.languages ?? [],
              certifications: job.certifications ?? [],
              benefits: job.benefits ?? [],
              applyVia: job.applyVia ?? 'internal',
              resumeRequirement: job.resumeRequirement ?? 'required',
              coverLetterRequirement:
                  job.coverLetterRequirement ?? 'optional',
              deadline: job.closesAt != null
                  ? job.closesAt!.toIso8601String().split('T').first
                  : '',
              screeningQuestions: (job.screeningQuestions ?? [])
                  .map(
                    (q) => ScreeningQuestion(
                      text:
                          q['question_text'] ??
                          q['text'] ??
                          q['question'] ??
                          '',
                      isRequired: q['is_required'] ?? true,
                    ),
                  )
                  .toList(),
            ),
          );

      setState(() => _isLoadingJobDetail = false);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0 && !_validateStepOne()) {
      return;
    }

    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Final Submit happens in Step 6
    }
  }

  bool _validateStepOne() {
    final state = ref.read(postJobWizardProvider);
    final title = state.title.trim();
    final description = getPlainTextFromQuillJson(state.description).trim();

    if (title.isEmpty) {
      UJobToast.error(
        context,
        'Validation Error',
        sub: 'Job Title is required',
      );
      return false;
    }

    if (description.length < 20) {
      UJobToast.error(
        context,
        'Validation Error',
        sub: 'Description is required (min 20 chars)',
      );
      return false;
    }

    return true;
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.pop();
    }
  }

  String _deltaToHtml(String deltaJson) {
    if (deltaJson.isEmpty) return '';
    try {
      final List<dynamic> ops = jsonDecode(deltaJson);
      final converter = QuillDeltaToHtmlConverter(
        List.castFrom(ops).map((op) => Map<String, dynamic>.from(op)).toList(),
      );
      return converter.convert();
    } catch (e) {
      return deltaJson;
    }
  }

  Future<void> _submitJob(String targetStatus) async {
    final state = ref.read(postJobWizardProvider);
    final dio = ref.read(dioClientProvider).dio;

    final options = ref.read(jobFormOptionsProvider).valueOrNull;
    final categories = ref.read(categoriesProvider).valueOrNull;

    final fallbackApplyVia = options?.applicationMethods.isNotEmpty == true
        ? options!.applicationMethods.first.value
        : 'internal';
    final fallbackResume = options?.resumeRequirements.isNotEmpty == true
        ? options!.resumeRequirements.first.value
        : 'required';
    final fallbackCover = options?.coverLetterPolicies.isNotEmpty == true
        ? options!.coverLetterPolicies.first.value
        : 'optional';
    final fallbackCategory = categories?.isNotEmpty == true
        ? categories!.first.id
        : '1';
    final fallbackEmpType = options?.employmentTypes.isNotEmpty == true
        ? options!.employmentTypes.first.value
        : 'full_time';
    final fallbackWorkplace = options?.workplaceTypes.isNotEmpty == true
        ? options!.workplaceTypes.first.value
        : 'on_site';
    final fallbackCurrency = options?.currencies.isNotEmpty == true
        ? options!.currencies.first.value
        : 'GBP';
    final fallbackSalaryPeriod = options?.salaryPeriods.isNotEmpty == true
        ? options!.salaryPeriods.first.value
        : 'monthly';
    final fallbackEducation = options?.minimumEducationLevels.isNotEmpty == true
        ? options!.minimumEducationLevels.first.value
        : 'high_school';

    // Minimal validation
    if (!_validateStepOne()) {
      return;
    }

    EasyLoading.show(status: 'Saving...');

    try {
      final payload = {
        'title': state.title,
        'employment_type': state.employmentType.isNotEmpty
            ? state.employmentType
            : fallbackEmpType,
        'workplace_type': state.workplaceType.isNotEmpty
            ? state.workplaceType
            : fallbackWorkplace,
        'category_id': state.category.isNotEmpty
            ? state.category
            : fallbackCategory,
        'city': state.city,
        'country': state.country.isNotEmpty ? state.country : 'GB',
        'vacancies': int.tryParse(state.openings) ?? 1,
        if (state.deadline.isNotEmpty) 'application_deadline': state.deadline,
        if (state.salaryMin.isNotEmpty)
          'salary_min': int.tryParse(state.salaryMin),
        if (state.salaryMax.isNotEmpty)
          'salary_max': int.tryParse(state.salaryMax),
        'salary_currency': state.currency.isNotEmpty
            ? state.currency
            : fallbackCurrency,
        'salary_period': state.salaryPeriod.isNotEmpty
            ? state.salaryPeriod
            : fallbackSalaryPeriod,
        'description': _deltaToHtml(state.description),
        'responsibilities': _deltaToHtml(state.responsibilities),
        'requirements': _deltaToHtml(state.requirements),
        if (state.experience.isNotEmpty)
          'experience_min_years': int.tryParse(state.experience),
        'min_education': state.education.isNotEmpty
            ? state.education
            : fallbackEducation,
        'preferred_skills': state.preferredSkills
            .where((e) => e.trim().isNotEmpty)
            .map((e) => e.trim())
            .join(', '),
        'languages_required': state.languages
            .where((e) => e.trim().isNotEmpty)
            .map((e) => e.trim())
            .join(', '),
        'certifications_required': state.certifications
            .where((e) => e.trim().isNotEmpty)
            .map((e) => e.trim())
            .join(', '),
        if (state.ageMin.isNotEmpty) 'age_min': int.tryParse(state.ageMin),
        if (state.ageMax.isNotEmpty) 'age_max': int.tryParse(state.ageMax),
        'benefits': jsonEncode(state.benefits),
        'application_method': state.applyVia.isNotEmpty
            ? state.applyVia
            : fallbackApplyVia,
        if (state.applyVia == 'email' && state.applicationEmail.isNotEmpty)
          'application_email': state.applicationEmail,
        if (state.applyVia == 'external' && state.applicationUrl.isNotEmpty)
          'application_url': state.applicationUrl,
        'resume_required': state.resumeRequirement.isNotEmpty
            ? state.resumeRequirement
            : fallbackResume,
        'cover_letter_policy': state.coverLetterRequirement.isNotEmpty
            ? state.coverLetterRequirement
            : fallbackCover,
        'screening_questions': state.screeningQuestions
            .asMap()
            .entries
            .map(
              (e) => {
                'question_text': e.value.text,
                'is_required': e.value.isRequired,
                'order_index': e.key,
              },
            )
            .toList(),
        'status': targetStatus,
      };

      final res = _isEditing
          ? await dio.put('${Ep.employerJobs}/${widget.job!.id}', data: payload)
          : await dio.post(Ep.employerJobs, data: payload);

      EasyLoading.dismiss();

      // Reload Dashboard & Jobs lists
      ref.invalidate(employerDashboardProvider);
      ref.invalidate(employerJobsProvider);
      if (widget.job != null) {
        ref.invalidate(employerJobDetailProvider(widget.job!.id));
      }

      // Clear wizard state for next time
      ref.invalidate(postJobWizardProvider);

      if (mounted) {
        final featureFlags = ref.read(featureFlagsProvider).valueOrNull;
        final jobApprovalRequired = featureFlags?.jobApprovalRequired ?? false;
        final successSub = targetStatus == 'draft'
            ? 'Job saved to drafts'
            : (_isEditing
                  ? 'Job updated successfully'
                  : (jobApprovalRequired
                        ? 'Job submitted for review'
                        : 'Job published successfully'));
        UJobToast.success(
          context,
          'Success',
          sub: extractApiMessage(res.data) ?? successSub,
        );
        context.pop();
      }
    } catch (e) {
      EasyLoading.dismiss();
      String errorMsg = 'Failed to save job. Please try again.';
      if (e is DioException && e.response != null) {
        final data = e.response?.data;
        if (data is Map && data['message'] != null) {
          errorMsg = data['message'];
        }
      }
      debugPrint('Post Job Error: $e');
      if (mounted) UJobToast.error(context, 'Error', sub: errorMsg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final featureFlags = ref.watch(featureFlagsProvider).valueOrNull;
    final jobApprovalRequired = featureFlags?.jobApprovalRequired ?? false;
    final publishStatus = jobApprovalRequired ? 'pending' : 'active';
    final publishLabel = _isEditing
        ? 'Update Job'
        : (jobApprovalRequired ? 'Send for Review' : 'Publish Job');

    // Create translation labels manually if they don't exist yet,
    // to avoid breaking build before arb update.
    final stepLabels = [
      'Job Details',
      'Requirements',
      'Benefits',
      'Application',
      'Screening',
      'Review',
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: UJobAppBar(
        title: _isEditing ? l10n.editJob : l10n.postJob,
        rightWidget: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            padding: EdgeInsets.all(8.r),
            color: Colors.transparent,
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedCancel01,
              size: 24.r,
              color: AppColors.text,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Container(
                  color: AppColors.surface,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 16.h,
                  ),
                  child: UJobWizardStepper(
                    currentStep: _currentStep,
                    steps: stepLabels,
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      Step1JobDetails(),
                      Step2Requirements(),
                      Step3Benefits(),
                      Step4Application(),
                      Step5Screening(),
                      Step6Review(
                        onPublish: () {
                          context.pop();
                        },
                      ),
                    ],
                  ),
                ),
                _buildBottomBar(l10n, publishLabel, publishStatus),
              ],
            ),
          ),
          if (_isLoadingJobDetail)
            Positioned.fill(
              child: Container(
                color: AppColors.bg,
                child: const UJobLoading(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    AppLocalizations l10n,
    String publishLabel,
    String publishStatus,
  ) {
    return Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.borderLight)),
              ),
              child: _currentStep == _totalSteps - 1
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: UJobButton(
                                label: context.l10n.saveToDraft,
                                outlined: true,
                                color: AppColors.primary,
                                icon: HugeIcon(
                                  icon: HugeIcons.strokeRoundedBookmark02,
                                  color: AppColors.primary,
                                  size: 20.r,
                                ),
                                onTap: () => _submitJob('draft'),
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              flex: 1,
                              child: UJobButton(
                                label: publishLabel,
                                icon: HugeIcon(
                                  icon: _isEditing
                                      ? HugeIcons.strokeRoundedRefresh
                                      : HugeIcons.strokeRoundedSent,
                                  color: AppColors.surface,
                                  size: 20.r,
                                ),
                                onTap: () => _submitJob(publishStatus),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        UJobButton(
                          label: l10n.back,
                          outlined: true,
                          color: AppColors.muted,
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedArrowLeft01,
                            color: AppColors.muted,
                            size: 20.r,
                          ),
                          onTap: _prevStep,
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: UJobButton(
                            label: l10n.back,
                            outlined: true,
                            color: AppColors.muted,
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedArrowLeft01,
                              color: AppColors.muted,
                              size: 20.r,
                            ),
                            onTap: _prevStep,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          flex: 2,
                          child: UJobButton(
                            label: l10n.next,
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedArrowRight01,
                              color: AppColors.surface,
                              size: 20.r,
                            ),
                            onTap: _nextStep,
                          ),
                        ),
                      ],
                    ),
    );
  }
}
