import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/job.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/l10n_extensions.dart';
import '../../../core/widgets/ujob_button.dart';
import '../../../core/widgets/ujob_app_bar.dart';
import '../../../core/widgets/ujob_wizard_stepper.dart';
import '../../../core/widgets/ujob_toast.dart';
import 'post_job_wizard_provider.dart';
import 'employer_job_provider.dart';

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

  bool get _isEditing => widget.job != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.job != null) {
        final job = widget.job!;
        ref.read(postJobWizardProvider.notifier).updateField(
          PostJobState(
            title: job.title,
            description: job.description,
            city: job.location ?? '',
            employmentType: job.employmentType,
            workplaceType: job.workplaceType,
            salaryMin: job.salaryMin ?? '',
            salaryMax: job.salaryMax ?? '',
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
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

  void _submitJob(JobStatus targetStatus) {
    final state = ref.read(postJobWizardProvider);
    final data = {
      'title': state.title,
      'description': state.description,
      'category': state.category == 'Other' && state.customCategory.isNotEmpty ? '${state.category} (${state.customCategory})' : state.category,
      'employment_type': state.employmentType,
      'workplace_type': state.workplaceType,
      'city': state.city,
      'salary_min': state.salaryMin,
      'salary_max': state.salaryMax,
      'responsibilities': state.responsibilities,
      'required_skills': state.requiredSkills,
      'preferred_skills': state.preferredSkills,
      'benefits': state.benefits,
      'education': state.education,
      'openings': state.openings,
      'apply_via': state.applyVia,
      'resume_requirement': state.resumeRequirement,
      'cover_letter_requirement': state.coverLetterRequirement,
      'experience_level': state.experience,
      'languages': state.languages,
      'certifications': state.certifications,
      'age_min': state.ageMin,
      'age_max': state.ageMax,
      'screening_questions': state.screeningQuestions.map((q) => {
        'text': q.text,
        'is_required': q.isRequired,
      }).toList(),
    };
    
    final notifier = ref.read(demoEmployerJobsProvider.notifier);
    
    if (_isEditing) {
      notifier.updateFromForm(widget.job!.id, data);
      notifier.updateStatus(widget.job!.id, targetStatus);
    } else {
      final newJob = notifier.addFromForm(data);
      notifier.updateStatus(newJob.id, targetStatus);
    }
    
    UJobToast.success(
      context, 
      targetStatus == JobStatus.draft 
          ? 'Job saved to drafts' 
          : (_isEditing ? 'Job updated successfully' : 'Job published successfully'),
    );
    
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    
    // Create translation labels manually if they don't exist yet, 
    // to avoid breaking build before arb update.
    final stepLabels = [
      'Job Details',
      'Requirements',
      'Benefits',
      'Application',
      'Screening',
      'Review'
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: UJobAppBar(title: _isEditing ? l10n.editJob : l10n.postJob),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: AppColors.surface,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
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
                  Step6Review(onPublish: () {
                    // TODO: call API
                    context.pop();
                  }),
                ],
              ),
            ),
            Container(
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
                                icon: HugeIcon(icon: HugeIcons.strokeRoundedBookmark02, color: AppColors.primary, size: 20.r),
                                onTap: () => _submitJob(JobStatus.draft),
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              flex: 1,
                              child: UJobButton(
                                label: _isEditing ? 'Update Job' : 'Publish Job',
                                icon: HugeIcon(
                                  icon: _isEditing ? HugeIcons.strokeRoundedRefresh : HugeIcons.strokeRoundedSent,
                                  color: AppColors.surface,
                                  size: 20.r,
                                ),
                                onTap: () => _submitJob(JobStatus.pending),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        UJobButton(
                          label: l10n.back,
                          outlined: true,
                          color: AppColors.muted,
                          icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: AppColors.muted, size: 20.r),
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
                            icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, color: AppColors.surface, size: 20.r),
                            onTap: _nextStep,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
