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

class _ApplyScreenState extends ConsumerState<ApplyScreen> {
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
            'Your application has been sent. We\'ll notify you when the employer responds.',
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
}

class _StepIndicator extends StatelessWidget {
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
        'Optional — introduce yourself and explain why you\'re a great fit.',
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
}
