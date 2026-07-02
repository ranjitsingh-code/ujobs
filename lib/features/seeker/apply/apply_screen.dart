// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/l10n_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/api_error_parser.dart';
import '../../../core/widgets/ujob_alert_dialog.dart';
import '../../../core/widgets/ujob_app_bar.dart';
import '../../../core/widgets/ujob_button.dart';
import '../../../core/widgets/ujob_document_viewer_screen.dart';
import '../../../core/widgets/ujob_loading.dart';
import '../../../core/widgets/ujob_result_screen.dart';
import '../../../core/widgets/ujob_rich_text_editor.dart';
import '../../../core/widgets/ujob_text_field.dart';
import '../../../core/widgets/ujob_toast.dart';
import '../../../core/widgets/ujob_wizard_stepper.dart';
import '../../seeker/profile/seeker_profile_provider.dart';
import '../jobs/seeker_job_provider.dart';
import '../applications/seeker_application_provider.dart';
import '../../../core/models/seeker_profile.dart';

class ApplyScreen extends ConsumerStatefulWidget {
  final int jobId;
  final String jobTitle;
  final String? companyName;
  final String? location;
  final String? source;

  const ApplyScreen({
    required this.jobId,
    required this.jobTitle,
    this.companyName,
    this.location,
    this.source,
    super.key,
  });

  @override
  ConsumerState<ApplyScreen> createState() => _ApplyScreenState();
}

enum ApplyStep { resumeAndCoverLetter, questions }

class _ApplyScreenState extends ConsumerState<ApplyScreen> {
  int _stepIndex = 0;
  final _coverCtrl = TextEditingController();
  final Map<int, String> _questionAnswers = {};

  List<SeekerResume> _resumes = [];
  String? _selectedResumeId;
  bool _loadingResumes = true;
  bool _uploadingResume = false;
  bool _submitting = false;
  bool _submitted = false;

  String get _source => widget.source ?? 'jobs';

  bool _showsResume(dynamic job) {
    final value = job.resumeRequirement?.toLowerCase();
    return value != null &&
        value != 'disabled' &&
        value != 'false' &&
        value != 'no';
  }

  bool _requiresResume(dynamic job) {
    final value = job.resumeRequirement?.toLowerCase();
    return value != null &&
        value != 'optional' &&
        value != 'disabled' &&
        value != 'false' &&
        value != 'no';
  }

  bool _showsCoverLetter(dynamic job) {
    final value = job.coverLetterRequirement?.toLowerCase();
    return value != null &&
        value != 'disabled' &&
        value != 'false' &&
        value != 'no';
  }

  bool _requiresCoverLetter(dynamic job) {
    final value = job.coverLetterRequirement?.toLowerCase();
    return value != null &&
        value != 'optional' &&
        value != 'disabled' &&
        value != 'false' &&
        value != 'no';
  }

  String _resultButtonLabel(BuildContext context) {
    switch (_source) {
      case 'dashboard':
        return '${context.l10n.back} to ${context.l10n.dashboard}';
      case 'applications':
        return '${context.l10n.back} to ${context.l10n.applications}';
      case 'jobs':
      default:
        return '${context.l10n.back} to ${context.l10n.jobs}';
    }
  }

  void _goBackToSource(BuildContext context) {
    switch (_source) {
      case 'dashboard':
        context.go('/seeker');
        return;
      case 'applications':
        context.go('/seeker/applied');
        return;
      case 'jobs':
      default:
        context.go('/seeker/jobs');
        return;
    }
  }

  @override
  void initState() {
    super.initState();
    _coverCtrl.addListener(() {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadResumes();
    });
  }

  @override
  void dispose() {
    _coverCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadResumes({String? preferredResumeId}) async {
    try {
      final resumes = await ref.read(seekerProfileServiceProvider).listResumes();
      if (!mounted) return;
      setState(() {
        _resumes = resumes;
        _selectedResumeId = _resolveSelectedResumeId(
          resumes,
          preferredResumeId: preferredResumeId,
        );
        _loadingResumes = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingResumes = false);
      UJobToast.error(
        context,
        'Could not load resumes',
        sub: 'Please try again.',
      );
    }
  }

  String? _resolveSelectedResumeId(
    List<SeekerResume> resumes, {
    String? preferredResumeId,
  }) {
    if (preferredResumeId != null &&
        resumes.any((resume) => resume.id == preferredResumeId)) {
      return preferredResumeId;
    }
    if (_selectedResumeId != null &&
        resumes.any((resume) => resume.id == _selectedResumeId)) {
      return _selectedResumeId;
    }
    final primary = resumes.where((resume) => resume.isPrimary).toList();
    if (primary.isNotEmpty) return primary.first.id;
    if (resumes.isNotEmpty) return resumes.first.id;
    return null;
  }

  Future<void> _uploadNewResume() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result == null || result.files.single.path == null) return;

      final path = result.files.single.path!;
      final file = File(path);
      if (file.lengthSync() > 3 * 1024 * 1024) {
        if (!mounted) return;
        UJobToast.error(
          context,
          'Upload failed',
          sub: 'File must be smaller than 3 MB.',
        );
        return;
      }

      setState(() => _uploadingResume = true);
      final uploadedResume =
          await ref.read(seekerProfileServiceProvider).uploadResume(path);
      await _loadResumes(preferredResumeId: uploadedResume.id);
      if (!mounted) return;
      UJobToast.success(
        context,
        'Success',
        sub: 'Resume uploaded successfully!',
      );
    } on DioException catch (e) {
      if (!mounted) return;
      final apiError = parseApiErrorDetail(e);
      UJobToast.error(
        context,
        'Upload failed',
        sub: apiError.message,
      );
    } catch (e) {
      if (!mounted) return;
      UJobToast.error(
        context,
        'Upload failed',
        sub: 'Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() => _uploadingResume = false);
      }
    }
  }

  String _formatResumeUpdatedAt(DateTime? date) {
    if (date == null) return 'Last updated recently';
    return 'Last updated ${DateFormat('d MMM yyyy').format(date)}';
  }

  bool _canProceed(ApplyStep step, dynamic job) {
    if (step == ApplyStep.resumeAndCoverLetter) {
      if (_requiresResume(job) && _selectedResumeId == null) {
        return false;
      }
      if (_requiresCoverLetter(job)) {
        final text = getPlainTextFromQuillJson(_coverCtrl.text).trim();
        return text.isNotEmpty;
      }
      return true;
    }

    if (step == ApplyStep.questions) {
      final questions = job.screeningQuestions ?? [];
      for (int i = 0; i < questions.length; i++) {
        final question = questions[i];
        final isRequired = question['required'] == true;
        if (isRequired && (_questionAnswers[i] ?? '').trim().isEmpty) {
          return false;
        }
      }
      return true;
    }
    return true;
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
      final job = ref.read(seekerJobDetailProvider(widget.jobId)).valueOrNull;
      final answers = <Map<String, dynamic>>[];
      if (job?.screeningQuestions != null) {
        for (var entry in _questionAnswers.entries) {
          if (entry.value.trim().isNotEmpty) {
            final q = job!.screeningQuestions![entry.key];
            answers.add({
              'questionId': q['id'],
              'answer': entry.value.trim(),
            });
          }
        }
      }

      await ref.read(seekerJobServiceProvider).applyJob(
            widget.jobId,
            resumeId: _selectedResumeId,
            coverLetter: _coverCtrl.text.trim(),
            answers: answers,
          );
      ref.invalidate(seekerJobDetailProvider(widget.jobId));
      ref.invalidate(seekerApplicationsProvider(null));
      setState(() => _submitted = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to apply: $e')),
        );
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
        subtitle:
            'Your application has been sent. We\'ll notify you when the employer responds.',
        buttonLabel: _resultButtonLabel(context),
        onTap: () => _goBackToSource(context),
      );
    }

    final jobAsync = ref.watch(seekerJobDetailProvider(widget.jobId));
    final job = jobAsync.valueOrNull;

    if (job == null || _loadingResumes) {
      return const Scaffold(body: UJobLoading(count: 1));
    }

    final steps = <ApplyStep>[];
    final showResume = _showsResume(job);
    final showCoverLetter = _showsCoverLetter(job);
    final showQuestions =
        job.screeningQuestions != null && job.screeningQuestions!.isNotEmpty;

    if (showResume || showCoverLetter) {
      steps.add(ApplyStep.resumeAndCoverLetter);
    }
    if (showQuestions) {
      steps.add(ApplyStep.questions);
    }

    if (steps.isEmpty) {
      return Scaffold(
        body: Center(child: Text('No application steps required.')),
      );
    }

    final currentStep = steps[_stepIndex];
    final totalSteps = steps.length;
    final canProceed = _canProceed(currentStep, job);

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
                    (s) => s == ApplyStep.resumeAndCoverLetter
                        ? 'Resume & Cover Letter'
                        : 'Questions',
                  )
                  .toList(),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.pagePad,
              child: currentStep == ApplyStep.resumeAndCoverLetter
                  ? _StepResumeAndCoverLetter(
                      showResume: showResume,
                      resumeRequired: _requiresResume(job),
                      resumes: _resumes,
                      selectedResumeId: _selectedResumeId,
                      onResumeSelected: (resumeId) {
                        setState(() => _selectedResumeId = resumeId);
                      },
                      onUploadResume: _uploadNewResume,
                      uploadingResume: _uploadingResume,
                      formatResumeUpdatedAt: _formatResumeUpdatedAt,
                      showCoverLetter: showCoverLetter,
                      coverLetterRequired: _requiresCoverLetter(job),
                      coverController: _coverCtrl,
                    )
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
            canProceed: canProceed,
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

class _StepResumeAndCoverLetter extends StatelessWidget {
  final bool showResume;
  final bool resumeRequired;
  final List<SeekerResume> resumes;
  final String? selectedResumeId;
  final ValueChanged<String> onResumeSelected;
  final VoidCallback onUploadResume;
  final bool uploadingResume;
  final String Function(DateTime?) formatResumeUpdatedAt;
  final bool showCoverLetter;
  final bool coverLetterRequired;
  final TextEditingController coverController;

  const _StepResumeAndCoverLetter({
    required this.showResume,
    required this.resumeRequired,
    required this.resumes,
    required this.selectedResumeId,
    required this.onResumeSelected,
    required this.onUploadResume,
    required this.uploadingResume,
    required this.formatResumeUpdatedAt,
    required this.showCoverLetter,
    required this.coverLetterRequired,
    required this.coverController,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showResume) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Text('Resume', style: AppText.heading2),
                if (!resumeRequired) ...[
                  SizedBox(width: 8.w),
                  Text(
                    '(Optional)',
                    style: AppText.body.copyWith(color: AppColors.muted),
                  ),
                ],
              ],
            ),
            SizedBox(height: 16.h),
            if (resumes.isNotEmpty) ...[
              ...resumes.map(
                (resume) => Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _ResumeOptionCard(
                    resume: resume,
                    selectedResumeId: selectedResumeId,
                    lastUpdated: formatResumeUpdatedAt(resume.createdAt),
                    onSelect: () => onResumeSelected(resume.id),
                  ),
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  resumeRequired
                      ? 'No resume found. Please upload one to continue.'
                      : 'No resume uploaded yet. You can continue without one.',
                  style: AppText.body.copyWith(color: AppColors.muted),
                ),
              ),
              SizedBox(height: 12.h),
            ],
            UJobButton(
              label: 'Upload New Resume',
              onTap: onUploadResume,
              color: AppColors.seekPrimary,
              outlined: true,
              isLoading: uploadingResume,
            ),
            SizedBox(height: 8.h),
            Text(
              'PDF, DOC or DOCX — max 3 MB',
              style: AppText.small.copyWith(color: AppColors.muted),
            ),
          ],
          if (showResume && showCoverLetter) SizedBox(height: 32.h),
          if (showCoverLetter) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Text('Cover Letter', style: AppText.heading2),
                if (!coverLetterRequired) ...[
                  SizedBox(width: 8.w),
                  Text(
                    '(Optional)',
                    style: AppText.body.copyWith(color: AppColors.muted),
                  ),
                ],
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              'Introduce yourself and explain why you\'re a great fit.',
              style: AppText.body.copyWith(color: AppColors.muted),
            ),
            SizedBox(height: 24.h),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: coverController,
              builder: (context, value, child) {
                final displayCtrl = TextEditingController(
                  text: getPlainTextFromQuillJson(value.text),
                );
                return GestureDetector(
                  onTap: () => showUJobRichTextEditor(
                    context: context,
                    title: 'Cover Letter',
                    initialValue: coverController.text,
                    returnHtml: true,
                    onSave: (val) {
                      coverController.text = val;
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
                      initialValue: coverController.text,
                      returnHtml: true,
                      onSave: (val) {
                        coverController.text = val;
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      );
}

class _ResumeOptionCard extends StatelessWidget {
  final SeekerResume resume;
  final String? selectedResumeId;
  final String lastUpdated;
  final VoidCallback onSelect;

  const _ResumeOptionCard({
    required this.resume,
    required this.selectedResumeId,
    required this.lastUpdated,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final selected = selectedResumeId == resume.id;
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: selected ? AppColors.seekPrimary : AppColors.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onSelect,
              borderRadius: BorderRadius.circular(12.r),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: Row(
                  children: [
                    Radio<String>(
                      value: resume.id,
                      groupValue: selectedResumeId,
                      onChanged: (_) => onSelect(),
                      activeColor: AppColors.seekPrimary,
                    ),
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedPdf01,
                      color: AppColors.error,
                      size: 28.r,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            resume.fileName,
                            style: AppText.bodyBold,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            lastUpdated,
                            style: AppText.small.copyWith(color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UJobDocumentViewerScreen(
                    title: 'My Resume',
                    fileUrl: resume.fileUrl,
                    fileName: resume.fileName,
                  ),
                ),
              );
            },
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedEye,
              color: AppColors.seekPrimary,
              size: 20.r,
            ),
          ),
        ],
      ),
    );
  }
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
            final isRequired = q['required'] == true;
            return Padding(
              padding: EdgeInsets.only(bottom: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: q['question'] ?? 'Question',
                      style: AppText.titleSm.copyWith(color: AppColors.text),
                      children: [
                        if (isRequired)
                          TextSpan(
                            text: ' *',
                            style: AppText.titleSm.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                      ],
                    ),
                  ),
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
  final bool canProceed;
  final VoidCallback? onBack;
  final VoidCallback onNext;

  const _BottomBar({
    required this.step,
    required this.totalSteps,
    required this.submitting,
    this.canProceed = true,
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
                      onTap: (!canProceed || submitting) ? null : onNext,
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
                      onTap: (!canProceed || submitting) ? null : onNext,
                      isLoading: submitting,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
