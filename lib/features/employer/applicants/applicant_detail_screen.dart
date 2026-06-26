import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/widgets/ujob_rich_text_display.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/models/applicant.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ujob_app_bar.dart';
import '../../../core/widgets/ujob_avatar.dart';
import '../../../core/widgets/ujob_stage_stepper.dart';
import '../../../core/widgets/ujob_pdf_viewer_screen.dart';
import '../../../core/widgets/ujob_button.dart';
import '../../../core/widgets/ujob_loading.dart';
import '../../../core/widgets/ujob_alert_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'employer_applicant_provider.dart';
import '../../../core/providers/feature_flags_provider.dart';

class ApplicantDetailScreen extends ConsumerStatefulWidget {
  final Applicant? applicant;
  final String? applicantId;

  const ApplicantDetailScreen({super.key, this.applicant, this.applicantId})
      : assert(applicant != null || applicantId != null);

  @override
  ConsumerState<ApplicantDetailScreen> createState() =>
      _ApplicantDetailScreenState();
}

class _ApplicantDetailScreenState extends ConsumerState<ApplicantDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final featureFlags = ref.watch(featureFlagsProvider);
    final bool isChatEnabled = featureFlags.maybeWhen(
      data: (flags) => flags.chat,
      orElse: () => false,
    );

    Applicant initialApplicant;
    if (widget.applicant != null) {
      initialApplicant = widget.applicant!;
    } else {
      final asyncApplicants = ref.watch(employerApplicantsProvider);
      final applicants = asyncApplicants.value ?? [];
      if (applicants.isEmpty) {
        return const Scaffold(body: UJobLoading(count: 1));
      }
      initialApplicant = applicants.firstWhere(
        (a) => a.id == widget.applicantId,
        orElse: () => applicants.first,
      );
    }

    final asyncApplicant = ref.watch(singleApplicantProvider(initialApplicant));
    
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const UJobAppBar(title: 'Applicant Profile'),
      body: asyncApplicant.when(
        loading: () => UJobLoading(count: 1),
        error: (err, stack) => Center(child: Text('Failed to load applicant details')),
        data: (applicant) => Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                ref.invalidate(singleApplicantProvider(initialApplicant));
                try {
                  await ref.read(singleApplicantProvider(initialApplicant).future);
                } catch (_) {}
              },
              child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        // Header Section
                        Container(
                          color: AppColors.surface,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 16.h,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              UJobAvatar(
                                initials: applicant.initials,
                                imageUrl: applicant.avatarUrl,
                                size: 56.r,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      applicant.name,
                                      style: AppText.titleMd,
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      applicant.targetJobTitle != null
                                          ? 'Applied for: ${applicant.targetJobTitle}'
                                          : applicant.role,
                                      style: AppText.small.copyWith(
                                        color: AppColors.muted2,
                                      ),
                                    ),
                                    SizedBox(height: 6.h),
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8.w,
                                            vertical: 2.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: applicant.statusColor
                                                .withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              12.r,
                                            ),
                                          ),
                                          child: Text(
                                            applicant.status,
                                            style: AppText.small.copyWith(
                                              color: applicant.statusColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        HugeIcon(
                                          icon: HugeIcons.strokeRoundedClock01,
                                          color: AppColors.muted,
                                          size: 12.r,
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          applicant.appliedAgo,
                                          style: AppText.small.copyWith(
                                            color: AppColors.muted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: HugeIcon(
                                      icon: HugeIcons
                                          .strokeRoundedInformationCircle,
                                      color: AppColors.primary,
                                      size: 28.r,
                                    ),
                                    onPressed: () {
                                      _showApplicantInfoSheet(
                                        context,
                                        applicant,
                                      );
                                    },
                                  ),
                                  if (isChatEnabled) ...[
                                    SizedBox(height: 12.h),
                                    InkWell(
                                      borderRadius: BorderRadius.circular(20.r),
                                      onTap: () {
                                        void handleMessage() {
                                          if (!applicant.hasMessaged) {
                                            ref
                                                .read(
                                                  employerApplicantsProvider
                                                      .notifier,
                                                )
                                                .markAsMessaged(applicant.id);
                                          }
                                          context.push(
                                            '/conversations/conv-${applicant.id}',
                                            extra: {
                                              'name': applicant.name,
                                              'initials': applicant.initials,
                                              'avatar': null,
                                            },
                                          );
                                        }

                                        if (applicant.hasMessaged) {
                                          handleMessage();
                                        } else {
                                          _showConfirmationDialog(
                                            context: context,
                                            title: 'Message Applicant',
                                            description:
                                                'Do you want to send a message to ${applicant.name}?',
                                            confirmText: 'Message',
                                            color: AppColors.primary,
                                            icon: HugeIcon(
                                              icon: HugeIcons
                                                  .strokeRoundedMessage01,
                                              color: AppColors.primary,
                                              size: 28.r,
                                            ),
                                            onConfirm: handleMessage,
                                          );
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12.w,
                                          vertical: 6.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20.r,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            HugeIcon(
                                              icon: HugeIcons
                                                  .strokeRoundedMessage01,
                                              color: AppColors.primary,
                                              size: 16.r,
                                            ),
                                            SizedBox(width: 6.w),
                                            Text(
                                              'Message',
                                              style: AppText.small.copyWith(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Application Stage
                        if (applicant.status.toLowerCase() != 'rejected' &&
                            applicant.status.toLowerCase() != 'hired')
                          Container(
                            color: AppColors.surface,
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: UJobStageStepper(
                              currentStage: applicant.status,
                            ),
                          ),
                      ],
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.muted,
                        indicatorColor: AppColors.primary,
                        labelStyle: AppText.bodyBold,
                        unselectedLabelStyle: AppText.body,
                        tabs: const [
                          Tab(text: 'Profile'),
                          Tab(text: 'Cover Letter'),
                          Tab(text: 'Screening Questions'),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildProfileTab(applicant),
                  _buildCoverLetterTab(applicant),
                  _buildAnswersTab(applicant),
                ],
              ),
            ),
            ),
          ),

          // Sticky Bottom Bar
          _buildStickyBottomBar(applicant),
        ],
      ),
      ),
    );
  }

  Widget _buildProfileTab(Applicant applicant) {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
      children: [
        if (applicant.resumeUrl != null)
          _buildSectionCard(
            'Resume',
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedPdf01,
                    color: AppColors.error,
                    size: 28.r,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        applicant.resumeUrl!.split('/').last,
                        style: AppText.bodyBold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'PDF Document',
                        style: AppText.small.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedEye,
                    color: AppColors.primary,
                    size: 24.r,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UJobPdfViewerScreen(
                          title: '${applicant.name} - Resume',
                          pdfUrl: applicant.resumeUrl!,
                          isAsset: false,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(width: 8.w),
                IconButton(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedDownload04,
                    color: AppColors.primary,
                    size: 24.r,
                  ),
                  onPressed: () async {
                    final url = Uri.parse(applicant.resumeUrl!);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Could not launch download URL.',
                            style: AppText.body.copyWith(color: Colors.white),
                          ),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
                if (applicant.about != null)
          _buildSectionCard(
            'About',
            UJobRichTextDisplay(content: applicant.about!),
          ),

        _buildSectionCard(
          'Job Preferences',
          Column(
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        'Experience',
                        applicant.experienceYears,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _buildInfoCard(
                        'Expected Salary',
                        applicant.expectedSalary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        'Availability',
                        applicant.availability,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    const Expanded(child: SizedBox()), // Empty placeholder
                  ],
                ),
              ),
            ],
          ),
        ),

        if (applicant.skills.isNotEmpty)
          _buildSectionCard(
            'Skills',
            Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: applicant.skills
                  .map(
                    (s) => Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.bg,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Text(
                        s,
                        style: AppText.bodyBold.copyWith(color: AppColors.text),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

        if (applicant.workExperience.isNotEmpty)
          _buildSectionCard(
            'Experience',
            Column(
              children: applicant.workExperience
                  .map(
                    (we) => Padding(
                      padding: EdgeInsets.only(
                        bottom: we == applicant.workExperience.last ? 0 : 24.h,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48.r,
                            height: 48.r,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedBriefcase02,
                                color: AppColors.primary,
                                size: 24.r,
                              ),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(we['title'] ?? '', style: AppText.titleMd),
                                SizedBox(height: 4.h),
                                Text(
                                  '${we['company']} • ${we['location'] ?? ''}',
                                  style: AppText.bodyBold.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  '${we['period']}',
                                  style: AppText.small.copyWith(
                                    color: AppColors.muted,
                                  ),
                                ),
                                if (we['description'] != null) ...[
                                  SizedBox(height: 12.h),
                                  Text(
                                    we['description']!,
                                    style: AppText.body.copyWith(
                                      color: AppColors.text2,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

        if (applicant.education.isNotEmpty)
          _buildSectionCard(
            'Education',
            Column(
              children: applicant.education
                  .map(
                    (ed) => Padding(
                      padding: EdgeInsets.only(
                        bottom: ed == applicant.education.last ? 0 : 24.h,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48.r,
                            height: 48.r,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedBook02,
                                color: AppColors.primary,
                                size: 24.r,
                              ),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ed['school'] ?? '',
                                  style: AppText.titleMd,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  '${ed['degree']} • ${ed['field']}',
                                  style: AppText.bodyBold.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Grade: ${ed['grade']}',
                                  style: AppText.small.copyWith(
                                    color: AppColors.muted,
                                  ),
                                ),
                                if (ed['period']?.isNotEmpty == true) ...[
                                  SizedBox(height: 4.h),
                                  Text(
                                    ed['period'] ?? '',
                                    style: AppText.small.copyWith(
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildSectionCard(String title, Widget child) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.heading3),
          SizedBox(height: 20.h),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    if (value.isEmpty) return const SizedBox();
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.small.copyWith(color: AppColors.muted)),
          SizedBox(height: 8.h),
          Text(
            value,
            style: AppText.bodyBold.copyWith(
              color: AppColors.text,
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverLetterTab(Applicant applicant) {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
      children: [
        if (applicant.coverLetter != null) ...[
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.md,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: UJobRichTextDisplay(content: applicant.coverLetter!),
          ),
        ] else
          Center(
            child: Text(
              'No Cover Letter provided.',
              style: AppText.body.copyWith(color: AppColors.muted),
            ),
          ),
      ],
    );
  }

  Widget _buildAnswersTab(Applicant applicant) {
    if (applicant.screeningAnswers == null ||
        applicant.screeningAnswers!.isEmpty) {
      return Center(
        child: Text(
          'No screening answers provided.',
          style: AppText.body.copyWith(color: AppColors.muted),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
      children: applicant.screeningAnswers!.entries
          .map(
            (e) => Container(
              margin: EdgeInsets.only(bottom: 20.h),
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.lg,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.key,
                    style: AppText.bodyBold.copyWith(
                      color: AppColors.text,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: AppColors.bg,
                      borderRadius: AppRadius.md,
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Text(
                      e.value,
                      style: AppText.body.copyWith(
                        color: AppColors.text2,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildStickyBottomBar(Applicant applicant) {
    final status = applicant.status.toLowerCase();

    String? nextStageLabel;
    String? nextStageValue;

    if (status == 'applied') {
      nextStageLabel = 'Shortlist';
      nextStageValue = 'Shortlisted';
    } else if (status == 'shortlisted') {
      nextStageLabel = 'Interview';
      nextStageValue = 'Interview';
    } else if (status == 'interview') {
      nextStageLabel = 'Offer Job';
      nextStageValue = 'Offered';
    } else if (status == 'offered') {
      nextStageLabel = 'Hire Applicant';
      nextStageValue = 'Hired';
    }

    final bool isCompleted = status == 'hired' || status == 'rejected';

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        children: [
          if (!isCompleted) ...[
            Expanded(
              flex: 1,
              child: UJobButton(
                label: context.l10n.reject,
                outlined: true,
                height: 48,
                color: AppColors.error,
                onTap: () {
                  _showConfirmationDialog(
                    context: context,
                    title: 'Reject Applicant',
                    description:
                        'Are you sure you want to reject ${applicant.name}? This action cannot be undone.',
                    confirmText: 'Reject',
                    color: AppColors.error,
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedCancel01,
                      color: AppColors.error,
                      size: 28.r,
                    ),
                    onConfirm: () async {
                      try {
                        await ref
                            .read(employerApplicantsProvider.notifier)
                            .updateStatus(applicant.id, 'Rejected');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Applicant rejected.')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to update stage.')),
                          );
                        }
                      }
                    },
                  );
                },
              ),
            ),
            SizedBox(width: 12.w),
          ],
          if (nextStageLabel != null) ...[
            Expanded(
              flex: 1,
              child: UJobButton(
                label: nextStageLabel,
                height: 48,
                onTap: () {
                  _showConfirmationDialog(
                    context: context,
                    title: 'Update Stage',
                    description:
                        'Are you sure you want to advance this application to the $nextStageValue stage?',
                    confirmText: 'Confirm',
                    color: AppColors.primary,
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedCheckmarkBadge01,
                      color: AppColors.primary,
                      size: 28.r,
                    ),
                    onConfirm: () async {
                      try {
                        await ref
                            .read(employerApplicantsProvider.notifier)
                            .updateStatus(applicant.id, nextStageValue!);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Applicant moved to $nextStageValue!')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to update stage.')),
                          );
                        }
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showApplicantInfoSheet(BuildContext context, Applicant applicant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 40.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 32.r), // spacer for centering
                  Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  IconButton(
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedCancel01,
                      color: AppColors.text,
                      size: 24.r,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              UJobAvatar(
                initials: applicant.initials,
                imageUrl: applicant.avatarUrl,
                size: 80.r,
              ),
              SizedBox(height: 12.h),
              Text(applicant.name, style: AppText.heading3),
              SizedBox(height: 4.h),
              Text(
                applicant.targetJobTitle != null
                    ? 'Applied for: ${applicant.targetJobTitle}'
                    : applicant.role,
                style: AppText.body.copyWith(color: AppColors.muted2),
              ),
              SizedBox(height: 32.h),
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: AppRadius.md,
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(HugeIcons.strokeRoundedCall, applicant.phone),
                    Divider(height: 24.h, color: AppColors.borderLight),
                    _buildInfoRow(
                      HugeIcons.strokeRoundedMail01,
                      applicant.email,
                    ),
                    Divider(height: 24.h, color: AppColors.borderLight),
                    _buildInfoRow(
                      HugeIcons.strokeRoundedLocation01,
                      applicant.location,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(dynamic icon, String value) {
    return Row(
      children: [
        HugeIcon(icon: icon, color: AppColors.muted, size: 20.r),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            value,
            style: AppText.body.copyWith(color: AppColors.text2),
          ),
        ),
      ],
    );
  }

  void _showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String description,
    required String confirmText,
    required Color color,
    required Widget icon,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => UJobAlertDialog(
        title: title,
        description: description,
        confirmText: confirmText,
        confirmColor: color,
        iconBgColor: color,
        icon: icon,
        onConfirm: () {
          Navigator.pop(context); // Close dialog
          onConfirm(); // Execute action
        },
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: AppColors.surface, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
