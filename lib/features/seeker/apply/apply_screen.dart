import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/providers/auth_provider.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ujob_button.dart';
import '../../../core/widgets/ujob_text_field.dart';
import '../../../core/widgets/ujob_app_bar.dart';
import '../../../core/widgets/ujob_alert_dialog.dart';
import '../../../core/widgets/ujob_rich_text_editor.dart';
import '../../../core/widgets/ujob_wizard_stepper.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/widgets/ujob_result_screen.dart';

import '../jobs/seeker_job_provider.dart';

class ApplyScreen extends ConsumerStatefulWidget {
  final int jobId;
  final String jobTitle;
  final String? companyName;
  final String? location;

  const ApplyScreen({
    required this.jobId,
    required this.jobTitle,
    this.companyName,
    this.location,
    super.key,
  });

  @override
  ConsumerState<ApplyScreen> createState() => _ApplyScreenState();
}

enum ApplyStep { coverLetter, questions }

class _ApplyScreenState extends ConsumerState<ApplyScreen> {
  int _stepIndex = 0;
  final _coverCtrl = TextEditingController();
  final Map<int, String> _questionAnswers = {};
  bool _submitting = false;
  bool _submitted = false;

  @override
  void dispose() {
    _coverCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => UJobAlertDialog(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedBriefcase01,
          color: AppColors.seekPrimary,
          size: 32.r,
        ),
        iconBgColor: AppColors.seekPrimary,
        title: 'Apply for this Job?',
        description:
            'Are you sure you want to submit your application for ${widget.jobTitle} at ${widget.companyName ?? 'Company'}?',
        confirmText: 'Apply',
        confirmColor: AppColors.seekPrimary,
        onConfirm: () => Navigator.pop(context, true),
      ),
    );

    if (confirmed != true) return;

    setState(() => _submitting = true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      setState(() => _submitted = true);
    } catch (_) {
      setState(() => _submitted = true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return UJobResultScreen(
        type: ResultType.success,
        title: 'Application Submitted!',
        subtitle:
            'Your application has been sent. We\'ll notify you when the employer responds.',
        buttonLabel: 'Back to Job',
        onTap: () {
          Navigator.pop(context, true);
        },
      );
    }

    final jobAsync = ref.watch(seekerJobDetailProvider(widget.jobId));
    final job = jobAsync.valueOrNull;

    if (job == null)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final steps = <ApplyStep>[];
    if (job.coverLetterRequirement != 'Disabled') {
      steps.add(ApplyStep.coverLetter);
    }
    if (job.screeningQuestions != null && job.screeningQuestions!.isNotEmpty) {
      steps.add(ApplyStep.questions);
    }

    if (steps.isEmpty) {
      return Scaffold(
        body: Center(child: Text('No application steps required.')),
      );
    }

    final currentStep = steps[_stepIndex];
    final totalSteps = steps.length;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const UJobAppBar(
        title: 'Job Application',
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: UJobWizardStepper(
              currentStep: _stepIndex,
              steps: steps
                  .map(
                    (s) => s == ApplyStep.coverLetter
                        ? 'Cover Letter'
                        : 'Questions',
                  )
                  .toList(),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.pagePad,
              child: currentStep == ApplyStep.coverLetter
                  ? _StepCoverLetter(controller: _coverCtrl)
                  : _StepScreeningQuestions(
                      questions: job.screeningQuestions ?? [],
                      answers: _questionAnswers,
                      onAnswerChanged: (index, value) {
                        setState(() {
                          _questionAnswers[index] = value;
                        });
                      },
                    ),
            ),
          ),
          _BottomBar(
            step: _stepIndex,
            totalSteps: totalSteps,
            submitting: _submitting,
            onBack: _stepIndex > 0 ? () => setState(() => _stepIndex--) : null,
            onNext: _stepIndex < totalSteps - 1
                ? () => setState(() => _stepIndex++)
                : _submit,
          ),
        ],
      ),
    );
  }
}

class _StepCoverLetter extends StatelessWidget {
  final TextEditingController controller;
  const _StepCoverLetter({required this.controller});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: 8.h),
      Text('Cover Letter', style: AppText.heading2),
      SizedBox(height: 8.h),
      Text(
        'Introduce yourself and explain why you\'re a great fit.',
        style: AppText.body.copyWith(color: AppColors.muted),
      ),
      SizedBox(height: 24.h),
      ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, child) {
          final displayCtrl = TextEditingController(
            text: getPlainTextFromQuillJson(value.text),
          );
          return GestureDetector(
            onTap: () => showUJobRichTextEditor(
              context: context,
              title: 'Cover Letter',
              initialValue: controller.text,
              onSave: (val) {
                controller.text = val;
              },
            ),
            child: UJobTextField(
              label: context.l10n.coverLetterTitle,
              hint: "Tap to write your cover letter in the rich editor...",
              controller: displayCtrl,
              readOnly: true,
              minLines: 5,
              maxLines: 10,
              labelTrailing: HugeIcon(
                icon: HugeIcons.strokeRoundedMaximize01,
                color: AppColors.seekPrimary,
                size: 20.r,
              ),
              onTap: () => showUJobRichTextEditor(
                context: context,
                title: 'Cover Letter',
                initialValue: controller.text,
                onSave: (val) {
                  controller.text = val;
                },
              ),
            ),
          );
        },
      ),
    ],
  );
}

class _StepScreeningQuestions extends StatefulWidget {
  final List<Map<String, dynamic>> questions;
  final Map<int, String> answers;
  final Function(int, String) onAnswerChanged;

  const _StepScreeningQuestions({
    required this.questions,
    required this.answers,
    required this.onAnswerChanged,
  });

  @override
  State<_StepScreeningQuestions> createState() =>
      _StepScreeningQuestionsState();
}

class _StepScreeningQuestionsState extends State<_StepScreeningQuestions> {
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.questions.length,
      (index) => TextEditingController(text: widget.answers[index] ?? ''),
    );
  }

  @override
  void dispose() {
    for (var ctrl in _controllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: 8.h),
      Text('Screening Questions', style: AppText.heading2),
      SizedBox(height: 8.h),
      Text(
        'Please answer the following questions required by the employer.',
        style: AppText.body.copyWith(color: AppColors.muted),
      ),
      SizedBox(height: 24.h),
      ...List.generate(widget.questions.length, (index) {
        final q = widget.questions[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(q['question'] ?? 'Question', style: AppText.titleSm),
              SizedBox(height: 12.h),
              UJobTextField(
                label: '',
                hint: context.l10n.yourAnswer,
                maxLines: 3,
                controller: _controllers[index],
                onChanged: (val) => widget.onAnswerChanged(index, val),
              ),
            ],
          ),
        );
      }),
    ],
  );
}

class _BottomBar extends StatelessWidget {
  final int step;
  final int totalSteps;
  final bool submitting;
  final VoidCallback? onBack;
  final VoidCallback onNext;

  const _BottomBar({
    required this.step,
    required this.totalSteps,
    required this.submitting,
    this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: SafeArea(
        top: false,
        child: onBack == null
            ? Row(
                children: [
                  Expanded(
                    child: UJobButton(
                      label: l10n.cancel,
                      outlined: true,
                      color: AppColors.muted,
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedCancel01,
                        color: AppColors.muted,
                        size: 20.r,
                      ),
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    flex: 2,
                    child: UJobButton(
                      label: step < totalSteps - 1 ? l10n.next : 'Submit',
                      icon: HugeIcon(
                        icon: step < totalSteps - 1
                            ? HugeIcons.strokeRoundedArrowRight01
                            : HugeIcons.strokeRoundedSent,
                        color: AppColors.surface,
                        size: 20.r,
                      ),
                      onTap: submitting ? null : onNext,
                      isLoading: submitting,
                    ),
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
                      onTap: onBack,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    flex: 2,
                    child: UJobButton(
                      label: step < totalSteps - 1 ? l10n.next : 'Submit',
                      icon: HugeIcon(
                        icon: step < totalSteps - 1
                            ? HugeIcons.strokeRoundedArrowRight01
                            : HugeIcons.strokeRoundedSent,
                        color: AppColors.surface,
                        size: 20.r,
                      ),
                      onTap: submitting ? null : onNext,
                      isLoading: submitting,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
