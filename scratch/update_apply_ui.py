import re

with open('lib/features/seeker/apply/apply_screen.dart', 'r') as f:
    content = f.read()

if "import '../../../core/widgets/ujob_wizard_stepper.dart';" not in content:
    content = content.replace(
        "import '../../../core/widgets/ujob_rich_text_editor.dart';",
        "import '../../../core/widgets/ujob_rich_text_editor.dart';\nimport '../../../core/widgets/ujob_wizard_stepper.dart';"
    )

old_ui = """      body: Column(
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
      ),"""

new_ui = """      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: UJobWizardStepper(
              currentStep: _stepIndex,
              steps: steps.map((s) => s == ApplyStep.coverLetter ? 'Cover Letter' : 'Questions').toList(),
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
      ),"""

content = content.replace(old_ui, new_ui)

old_indicator = """class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;
  const _StepIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) => Row(
    children: List.generate(total, (i) {
      return Expanded(
        child: Container(
          height: 3.h,
          margin: EdgeInsets.only(right: i < total - 1 ? 2.w : 0),
          color: i <= current ? AppColors.primary : AppColors.borderLight,
        ),
      );
    }),
  );
}"""

content = content.replace(old_indicator, "")

old_bottom_bar = """class _BottomBar extends StatelessWidget {
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
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
    decoration: const BoxDecoration(
      color: AppColors.surface,
      border: Border(top: BorderSide(color: AppColors.borderLight)),
    ),
    child: SafeArea(
      top: false,
      child: Row(
        children: [
          if (onBack != null) ...[
            Expanded(
              child: UJobButton(
                label: context.l10n.back,
                onTap: onBack,
                outlined: true,
              ),
            ),
            SizedBox(width: 12.w),
          ],
          Expanded(
            flex: 2,
            child: UJobButton(
              label: step < totalSteps - 1
                  ? 'Next: Questions'
                  : 'Submit Application',
              onTap: submitting ? null : onNext,
              isLoading: submitting,
            ),
          ),
        ],
      ),
    ),
  );
}"""

new_bottom_bar = """class _BottomBar extends StatelessWidget {
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
                      label: step < totalSteps - 1
                          ? l10n.next
                          : 'Submit',
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
                      label: step < totalSteps - 1
                          ? l10n.next
                          : 'Submit',
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
}"""

content = content.replace(old_bottom_bar, new_bottom_bar)

with open('lib/features/seeker/apply/apply_screen.dart', 'w') as f:
    f.write(content)
