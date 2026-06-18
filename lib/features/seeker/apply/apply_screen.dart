import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ujob_button.dart';
import '../../../core/widgets/ujob_text_field.dart';
import '../../../core/widgets/ujob_app_bar.dart';
import '../../../core/widgets/ujob_result_screen.dart';
import '../../../core/widgets/ujob_snack_bar.dart';

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
  int _step = 0; // 0 = Review, 1 = Cover Letter, 2 = Submit
  final _coverCtrl = TextEditingController();
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
      await ref.read(dioClientProvider).dio.post(
        Ep.seekerApplications,
        data: {
          'job_id': widget.jobId,
          if (_coverCtrl.text.trim().isNotEmpty) 'cover_letter': _coverCtrl.text.trim(),
        },
      );
      setState(() => _submitted = true);
    } catch (_) {
      if (mounted) {
        UJobSnackBar.error(context, 'Submission Failed', message: 'Please try again.');
      }
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
        subtitle: 'Your application has been sent. We\'ll notify you when the employer responds.',
        buttonLabel: 'Back to Job',
        onTap: () => Navigator.pop(context),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: UJobAppBar(
        title: _step == 0
            ? 'Review Application'
            : _step == 1
                ? 'Cover Letter'
                : 'Confirm Submission',
        rightWidget: Padding(
          padding: EdgeInsets.only(right: 8),
          child: Text(
            '${_step + 1} / 3',
            style: AppText.bodyBold.copyWith(color: AppColors.muted),
          ),
        ),
      ),
      body: Column(children: [
        _StepIndicator(current: _step),
        Expanded(
          child: SingleChildScrollView(
            padding: AppSpacing.pagePad,
            child: _step == 0
                ? _StepReview(auth: ref.watch(authProvider), job: widget)
                : _step == 1
                    ? _StepCoverLetter(controller: _coverCtrl)
                    : _StepConfirm(jobTitle: widget.jobTitle, companyName: widget.companyName),
          ),
        ),
        _BottomBar(
          step: _step,
          submitting: _submitting,
          onBack: _step > 0 ? () => setState(() => _step--) : null,
          onNext: _step < 2
              ? () => setState(() => _step++)
              : _submit,
        ),
      ]),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int current;
  const _StepIndicator({required this.current});

  @override
  Widget build(BuildContext context) => Row(
        children: List.generate(3, (i) {
          return Expanded(
            child: Container(
              height: 3,
              margin: EdgeInsets.only(right: i < 2 ? 2 : 0),
              color: i <= current ? AppColors.primary : AppColors.borderLight,
            ),
          );
        }),
      );
}

class _StepReview extends StatelessWidget {
  final AsyncValue auth;
  final ApplyScreen job;
  const _StepReview({required this.auth, required this.job});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 8),
        // Applicant header card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppColors.authGradient,
            borderRadius: AppRadius.xl,
          ),
          child: auth.when(
            loading: () => const SizedBox(height: 56),
            error: (_, _) => const SizedBox(),
            data: (user) => Row(children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.2),
                  borderRadius: AppRadius.md,
                ),
                child: Center(
                  child: Text(
                    user?.initials ?? '?',
                    style: AppText.heading3.copyWith(color: AppColors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    user?.fullName ?? '—',
                    style: AppText.titleSm.copyWith(color: AppColors.white),
                  ),
                  if (user?.email != null)
                    Text(user!.email!, style: AppText.small.copyWith(color: AppColors.white.withValues(alpha: 0.8))),
                ]),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        // Resume card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.md,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: AppRadius.sm),
              child: const Icon(Icons.description_outlined, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Resume.pdf', style: AppText.bodyBold),
                Text('Upload to attach your resume', style: AppText.small.copyWith(color: AppColors.muted)),
              ]),
            ),
            GestureDetector(
              onTap: () {},
              child: Text('Upload', style: AppText.label.copyWith(color: AppColors.primary)),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        // Applying for
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.md,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('APPLYING FOR', style: AppText.overline.copyWith(color: AppColors.muted2, letterSpacing: 1.2)),
            const SizedBox(height: 6),
            Text(job.jobTitle, style: AppText.titleMd.copyWith(color: AppColors.primary)),
            if (job.companyName != null || job.location != null)
              Text(
                [job.companyName, job.location].whereType<String>().join(' · '),
                style: AppText.small.copyWith(color: AppColors.muted),
              ),
          ]),
        ),
        const SizedBox(height: 16),
        Text(
          'Your full profile and resume will be shared with the employer upon submission.',
          style: AppText.small.copyWith(color: AppColors.muted),
        ),
      ]);
}

class _StepCoverLetter extends StatelessWidget {
  final TextEditingController controller;
  const _StepCoverLetter({required this.controller});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 8),
        Text('Cover Letter', style: AppText.heading3),
        const SizedBox(height: 4),
        Text(
          'Optional — introduce yourself and explain why you\'re a great fit.',
          style: AppText.small.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: 20),
        UJobTextField(
          label: 'Cover Letter',
          hint: 'Hi, I\'m excited to apply for this role because...',
          controller: controller,
          maxLines: 8,
          keyboardType: TextInputType.multiline,
        ),
      ]);
}

class _StepConfirm extends StatelessWidget {
  final String jobTitle;
  final String? companyName;
  const _StepConfirm({required this.jobTitle, this.companyName});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 8),
        Text('Review & Submit', style: AppText.heading3),
        const SizedBox(height: 4),
        Text(
          'Double-check everything before submitting.',
          style: AppText.small.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: 24),
        _ConfirmRow(label: 'Position', value: jobTitle),
        if (companyName != null) _ConfirmRow(label: 'Company', value: companyName!),
        _ConfirmRow(label: 'Resume', value: 'Attached'),
        const Divider(height: 32),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: AppRadius.md,
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Row(children: [
            const Icon(Icons.info_outline, color: AppColors.primary, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Your profile, skills, and resume will be shared with the employer.',
                style: AppText.small.copyWith(color: AppColors.primaryDark),
              ),
            ),
          ]),
        ),
      ]);
}

class _ConfirmRow extends StatelessWidget {
  final String label;
  final String value;
  const _ConfirmRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          SizedBox(
            width: 80,
            child: Text(label, style: AppText.small.copyWith(color: AppColors.muted)),
          ),
          Expanded(child: Text(value, style: AppText.bodyMd)),
        ]),
      );
}

class _BottomBar extends StatelessWidget {
  final int step;
  final bool submitting;
  final VoidCallback? onBack;
  final VoidCallback onNext;

  const _BottomBar({required this.step, required this.submitting, this.onBack, required this.onNext});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.borderLight)),
        ),
        child: SafeArea(
          top: false,
          child: Row(children: [
            if (onBack != null) ...[
              Expanded(
                child: UJobButton(label: 'Back', onTap: onBack, outlined: true),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: 2,
              child: UJobButton(
                label: step < 2
                    ? (step == 0 ? 'Next: Cover Letter' : 'Next: Review')
                    : 'Submit Application',
                onTap: submitting ? null : onNext,
                isLoading: submitting,
              ),
            ),
          ]),
        ),
      );
}

