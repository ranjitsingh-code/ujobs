import re

with open('lib/features/seeker/apply/apply_screen.dart', 'r') as f:
    content = f.read()

# Imports
if "import '../../../core/widgets/ujob_alert_dialog.dart';" not in content:
    content = content.replace("import '../../../core/widgets/ujob_app_bar.dart';", "import '../../../core/widgets/ujob_app_bar.dart';\nimport '../../../core/widgets/ujob_alert_dialog.dart';\nimport '../../../core/widgets/ujob_rich_text_editor.dart';\nimport 'package:hugeicons/hugeicons.dart';")


orig_state = """class _ApplyScreenState extends ConsumerState<ApplyScreen> {
  int _step = 0; // 0 = Cover Letter, 1 = Screening Questions
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
    setState(() => _submitting = true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      setState(() => _submitted = true);
    } catch (_) {
      // Mock success for testing purposes as backend may not be ready
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
            'Your application has been sent. We\\'ll notify you when the employer responds.',
        buttonLabel: 'Back to Job',
        onTap: () {
          Navigator.pop(context, true); // Pop true to update state
        },
      );
    }

    final jobAsync = ref.watch(seekerJobDetailProvider(widget.jobId));
    final hasQuestions =
        jobAsync.valueOrNull?.screeningQuestions?.isNotEmpty ?? false;
    final totalSteps = hasQuestions ? 2 : 1;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: UJobAppBar(
        title: _step == 0 ? 'Cover Letter' : 'Screening Questions',
        rightWidget: Padding(
          padding: EdgeInsets.only(right: 8.w),
          child: Text(
            '${_step + 1} / $totalSteps',
            style: AppText.bodyBold.copyWith(color: AppColors.muted),
          ),
        ),
      ),
      body: Column(
        children: [
          _StepIndicator(current: _step, total: totalSteps),
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.pagePad,
              child: _step == 0
                  ? _StepCoverLetter(controller: _coverCtrl)
                  : _StepScreeningQuestions(
                      questions: jobAsync.valueOrNull?.screeningQuestions ?? [],
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
            step: _step,
            totalSteps: totalSteps,
            submitting: _submitting,
            onBack: _step > 0 ? () => setState(() => _step--) : null,
            onNext: _step < totalSteps - 1
                ? () => setState(() => _step++)
                : _submit,
          ),
        ],
      ),
    );
  }
}"""

new_state = """enum ApplyStep { coverLetter, questions }

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
        description: 'Are you sure you want to submit your application for ${widget.jobTitle} at ${widget.companyName ?? 'Company'}?',
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
            'Your application has been sent. We\\'ll notify you when the employer responds.',
        buttonLabel: 'Back to Job',
        onTap: () {
          Navigator.pop(context, true); 
        },
      );
    }

    final jobAsync = ref.watch(seekerJobDetailProvider(widget.jobId));
    final job = jobAsync.valueOrNull;

    if (job == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

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
      appBar: UJobAppBar(
        title: currentStep == ApplyStep.coverLetter ? 'Cover Letter' : 'Screening Questions',
        rightWidget: Padding(
          padding: EdgeInsets.only(right: 8.w),
          child: Text(
            '${_stepIndex + 1} / $totalSteps',
            style: AppText.bodyBold.copyWith(color: AppColors.muted),
          ),
        ),
      ),
      body: Column(
        children: [
          _StepIndicator(current: _stepIndex, total: totalSteps),
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
}"""

content = content.replace(orig_state, new_state)


orig_cover_letter = """class _StepCoverLetter extends StatelessWidget {
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
        'Optional — introduce yourself and explain why you\\'re a great fit.',
        style: AppText.body.copyWith(color: AppColors.muted),
      ),
      SizedBox(height: 24.h),
      UJobTextField(
        label: context.l10n.coverLetterTitle,
        hint: "Hi, I'm excited to apply for this role because...",
        controller: controller,
        maxLines: 8,
        keyboardType: TextInputType.multiline,
      ),
    ],
  );
}"""

new_cover_letter = """class _StepCoverLetter extends StatelessWidget {
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
        'Introduce yourself and explain why you\\'re a great fit.',
        style: AppText.body.copyWith(color: AppColors.muted),
      ),
      SizedBox(height: 24.h),
      GestureDetector(
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
          controller: TextEditingController(
            text: getPlainTextFromQuillJson(controller.text),
          ),
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
      ),
    ],
  );
}"""

content = content.replace(orig_cover_letter, new_cover_letter)

with open('lib/features/seeker/apply/apply_screen.dart', 'w') as f:
    f.write(content)

