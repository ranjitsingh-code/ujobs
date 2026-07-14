// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:ujobs_app/core/widgets/ujob_toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/api_error_parser.dart';
import '../../../core/utils/l10n_extensions.dart';
import '../../../core/widgets/ujob_alert_dialog.dart';
import '../../../core/widgets/ujob_button.dart';
import '../../../core/widgets/ujob_document_viewer_screen.dart';
import '../../../core/widgets/ujob_loading.dart';
import '../../../core/widgets/ujob_text_field.dart';
import '../../../core/widgets/ujob_dropdown_field.dart';
// import '../../../core/widgets/ujob_skill_autocomplete.dart'; // unused while Skills section hidden
import '../../../core/models/skill.dart';
import '../../../core/widgets/ujob_rich_text_editor.dart';
import '../../../core/models/seeker_profile.dart';
import 'seeker_profile_provider.dart';
import '../dashboard/seeker_dashboard_provider.dart';
// import 'widgets/add_experience_sheet.dart'; // unused while Work Experience section hidden
// import 'widgets/add_education_sheet.dart'; // unused while Education section hidden
// import '../../../core/providers/job_form_options_provider.dart'; // unused while salary section hidden
import '../../../core/providers/skills_provider.dart';
import '../../../core/widgets/ujob_phone_number_field.dart';
import '../../../core/widgets/ujob_profile_setup_prompt.dart';

class SeekerProfileScreen extends ConsumerStatefulWidget {
  const SeekerProfileScreen({super.key});

  @override
  ConsumerState<SeekerProfileScreen> createState() => _SeekerProfileState();
}

class _SeekerProfileState extends ConsumerState<SeekerProfileScreen> {
  // Personal Information
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  String _phoneCode = '+44';
  final _phoneCtrl = TextEditingController();
  bool _showPhone = true;

  // Location
  String? _country;
  final _cityCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();

  // Relocation
  bool _willingToRelocate = false;
  String? _relocationType;
  final _relocationCitiesCtrl = TextEditingController();
  final List<String> _relocationCities = [];

  // Resume
  List<SeekerResume> _resumes = [];

  // Cover Letter
  List<CoverLetter> _coverLetters = [];

  // Professional Info
  final _headlineCtrl = TextEditingController();
  String? _expYears;
  String? _expMonths;
  final _expectedSalaryCtrl = TextEditingController();
  String? _currency;
  String? _salaryPeriod = 'yearly';
  String? _availability;
  String? _profileVisibility = 'private';
  String _about = '';

  // Skills
  final _skillSearchCtrl = TextEditingController();
  List<Skill> _selectedSkills = [];
  List<Skill> _availableSkills = [];

  // Experience & Education
  bool _isFresher = false;
  List<SeekerExperience> _experiences = [];
  List<SeekerEducation> _educations = [];

  // Social URLs
  final _linkedinCtrl = TextEditingController();
  final _githubCtrl = TextEditingController();
  final _portfolioCtrl = TextEditingController();
  final _twitterCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();

  bool _isLoading = false;
  bool _isUpdating = false;
  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();

    // Show loading indicator only on the very first load
    final existingData = ref.read(seekerProfileProvider);
    if (existingData == null) {
      _isLoading = true;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    try {
      ref.invalidate(seekerDashboardProvider);
      ref.invalidate(fetchSeekerProfileProvider);
      ref.invalidate(publicSkillsProvider);
      await _refreshAvailableSkills();
      await ref.read(fetchSeekerProfileProvider.future);
      final freshData = ref.read(seekerProfileProvider);
      if (freshData != null) {
        _populateFields(freshData);
      }
    } catch (e) {
      // Fallback to whatever is currently in state if fetch fails
      final profileData = ref.read(seekerProfileProvider);
      if (profileData != null) {
        _populateFields(profileData);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _refreshKey++;
        });
      }
    }
  }

  void _populateFields(SeekerProfileData data) {
    final user = data.user;
    final profile = data.profile;

    _firstNameCtrl.text = user.firstName;
    _lastNameCtrl.text = user.lastName;
    _phoneCtrl.text = user.phone ?? '';

    if (profile != null) {
      _phoneCode = user.phoneCode ?? '+44';
      _showPhone = profile.showPhone;

      _country = profile.country;
      _cityCtrl.text = profile.city ?? '';
      _addressCtrl.text = profile.address ?? '';
      _zipCtrl.text = profile.zipCode ?? '';

      _willingToRelocate = profile.openToRelocation;
      _relocationType = profile.relocationType;
      // In the absence of a dedicated cities field, we could parse it from relocationType if needed.
      // But we will just initialize empty for now.

      _resumes = List<SeekerResume>.from(profile.resumes);
      _coverLetters = List<CoverLetter>.from(profile.coverLetters);

      _headlineCtrl.text = profile.headline ?? '';
      if (profile.experienceYearsInt != null) {
        _expYears = profile.experienceYearsInt.toString();
      }
      if (profile.experienceMonths != null) {
        _expMonths = profile.experienceMonths.toString();
      }
      if (profile.expectedSalary != null) {
        _expectedSalaryCtrl.text = profile.expectedSalary!.toInt().toString();
      }
      _currency = profile.salaryCurrency;
      _salaryPeriod = profile.salaryPeriod ?? 'yearly';
      _availability = profile.availability;
      _profileVisibility = 'private';
      _about = profile.about ?? '';

      _selectedSkills = profile.skills
          .map((s) => Skill(id: int.tryParse(s.id) ?? 0, name: s.name))
          .toList();
      _isFresher = profile.isFresher;
      _experiences = List.from(profile.experiences);
      _educations = List.from(profile.educations);

      _linkedinCtrl.text = profile.linkedinUrl ?? '';
      _githubCtrl.text = profile.githubUrl ?? '';
      _portfolioCtrl.text = profile.portfolioUrl ?? '';
      _twitterCtrl.text = profile.twitterUrl ?? '';
      _websiteCtrl.text = profile.websiteUrl ?? '';

      setState(() {});
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _addressCtrl.dispose();
    _zipCtrl.dispose();
    _relocationCitiesCtrl.dispose();
    _headlineCtrl.dispose();
    _expectedSalaryCtrl.dispose();
    _skillSearchCtrl.dispose();
    _linkedinCtrl.dispose();
    _githubCtrl.dispose();
    _portfolioCtrl.dispose();
    _twitterCtrl.dispose();
    _websiteCtrl.dispose();
    super.dispose();
  }

  double _buildExperienceYearsValue() {
    final years = int.tryParse(_expYears ?? '') ?? 0;
    final months = int.tryParse(_expMonths ?? '') ?? 0;
    return years + (months / 12);
  }

  String _formatResumeUpdatedAt(DateTime? date) {
    if (date == null) return 'Last updated recently';
    return 'Last updated ${DateFormat('d MMM yyyy').format(date)}';
  }

  Future<void> _refreshAvailableSkills() async {
    final skills = await ref.read(publicSkillsProvider.future);
    if (!mounted) return;
    setState(() {
      _availableSkills = skills;
    });
  }

  Future<Skill?> _createMissingSkill(String name) async {
    final trimmedName = name.trim();
    if (trimmedName.length < 2) {
      UJobToast.error(context, 'Skill name is too short');
      return null;
    }

    try {
      final skill = await ref
          .read(seekerProfileServiceProvider)
          .createSkill(trimmedName);
      if (mounted &&
          !_availableSkills.any(
            (existingSkill) => existingSkill.id == skill.id,
          )) {
        setState(() {
          _availableSkills = [..._availableSkills, skill];
        });
      }
      return skill;
    } on DioException catch (e) {
      if (!mounted) return null;
      final apiError = parseApiErrorDetail(e);
      final statusCode = e.response?.statusCode;
      String message = 'Please try again.';

      if (statusCode == 404) {
        message = 'Skill add service is not available right now.';
      } else if (statusCode == 422 || apiError.code == 'CONTENT_VIOLATION') {
        message = apiError.message;
      } else if (statusCode == 400) {
        message = apiError.message;
      } else if (apiError.message.isNotEmpty &&
          apiError.message != 'A network error occurred.') {
        message = apiError.message;
      }

      UJobToast.error(context, 'Could not add skill', sub: message);
      return null;
    } catch (e) {
      if (!mounted) return null;
      UJobToast.error(context, 'Could not add skill', sub: 'Please try again.');
      return null;
    }
  }

  Future<void> _deleteResume(String id) async {
    try {
      final service = ref.read(seekerProfileServiceProvider);
      await service.deleteResume(id);
      setState(() {
        _resumes.removeWhere((resume) => resume.id == id);
      });
      ref.invalidate(seekerDashboardProvider);
      if (!mounted) return;
      UJobToast.success(
        context,
        'Success',
        sub: 'Resume deleted successfully!',
      );
    } catch (e) {
      if (!mounted) return;
      UJobToast.error(context, 'Error', sub: 'Error deleting resume: $e');
    }
  }

  void _confirmDeleteResume(SeekerResume resume) {
    showDialog(
      context: context,
      builder: (dialogContext) => UJobAlertDialog(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedDelete01,
          color: AppColors.error,
          size: 32.r,
        ),
        title: 'Delete Resume?',
        description: 'Do you want to delete this resume?',
        confirmText: 'Delete',
        confirmColor: AppColors.error,
        onConfirm: () {
          Navigator.pop(dialogContext);
          _deleteResume(resume.id);
        },
      ),
    );
  }

  Future<void> _pickAndUploadResume() async {
    var loadingShown = false;
    SeekerResume? uploadedResume;
    Object? uploadError;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      final path = result?.files.single.path;
      if (path == null) return;

      final file = File(path);

      // 3MB limit
      if (file.lengthSync() > 3 * 1024 * 1024) {
        if (!mounted) return;
        UJobToast.error(context, 'Error', sub: 'File must be smaller than 3MB');
        return;
      }

      if (!mounted) return;
      loadingShown = true;
      await EasyLoading.show(
        status: context.l10n.loading,
        maskType: EasyLoadingMaskType.black,
      );

      uploadedResume = await ref
          .read(seekerProfileServiceProvider)
          .uploadResume(path);
    } catch (e) {
      uploadError = e;
    } finally {
      if (loadingShown) {
        await EasyLoading.dismiss();
      }
    }

    if (!mounted) return;

    if (uploadError != null) {
      final is413 = uploadError is DioException &&
          uploadError.response?.statusCode == 413;
      UJobToast.error(
        context,
        is413 ? 'File Too Large' : 'Upload Failed',
        sub: is413
            ? 'Resume exceeds server limit. Try a smaller file.'
            : 'Could not upload resume. Please try again.',
      );
      return;
    }

    final resume = uploadedResume;
    if (resume != null) {
      setState(() {
        _resumes = [resume];
      });
      ref.invalidate(seekerDashboardProvider);

      UJobToast.success(
        context,
        'Success',
        sub: 'Resume uploaded successfully!',
      );
    }
  }

  Future<void> _deleteCoverLetter(String id) async {
    try {
      final service = ref.read(seekerProfileServiceProvider);
      await service.deleteCoverLetter(id);
      setState(() {
        _coverLetters.removeWhere((cl) => cl.id == id);
      });
      ref.invalidate(seekerDashboardProvider);
      if (!mounted) return;
      UJobToast.success(
        context,
        context.l10n.successTitle,
        sub: context.l10n.coverLetterDeletedMessage,
      );
    } catch (e) {
      if (!mounted) return;
      UJobToast.error(
        context,
        context.l10n.errorTitle,
        sub: context.l10n.coverLetterDeleteErrorMessage(e.toString()),
      );
    }
  }

  void _confirmDeleteCoverLetter(CoverLetter coverLetter) {
    showDialog(
      context: context,
      builder: (dialogContext) => UJobAlertDialog(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedDelete01,
          color: AppColors.error,
          size: 32.r,
        ),
        title: context.l10n.deleteCoverLetterTitle,
        description: context.l10n.deleteCoverLetterConfirmMessage,
        confirmText: context.l10n.delete,
        confirmColor: AppColors.error,
        onConfirm: () {
          Navigator.pop(dialogContext);
          _deleteCoverLetter(coverLetter.id);
        },
      ),
    );
  }

  Future<void> _pickAndUploadCoverLetter() async {
    var loadingShown = false;
    CoverLetter? uploadedCoverLetter;
    Object? uploadError;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      final path = result?.files.single.path;
      if (path == null) return;

      final file = File(path);

      // 3MB limit
      if (file.lengthSync() > 3 * 1024 * 1024) {
        if (!mounted) return;
        UJobToast.error(
          context,
          context.l10n.errorTitle,
          sub: context.l10n.coverLetterFileSizeLimit,
        );
        return;
      }

      if (!mounted) return;
      loadingShown = true;
      await EasyLoading.show(
        status: context.l10n.loading,
        maskType: EasyLoadingMaskType.black,
      );

      uploadedCoverLetter = await ref
          .read(seekerProfileServiceProvider)
          .uploadCoverLetter(path);
    } catch (e) {
      uploadError = e;
    } finally {
      if (loadingShown) {
        await EasyLoading.dismiss();
      }
    }

    if (!mounted) return;

    if (uploadError != null) {
      final is413 = uploadError is DioException &&
          uploadError.response?.statusCode == 413;
      UJobToast.error(
        context,
        is413 ? context.l10n.fileTooLargeTitle : context.l10n.uploadFailedTitle,
        sub: is413
            ? context.l10n.coverLetterExceedsLimitMessage
            : context.l10n.coverLetterUploadErrorMessage,
      );
      return;
    }

    final coverLetter = uploadedCoverLetter;
    if (coverLetter != null) {
      setState(() {
        _coverLetters = [..._coverLetters, coverLetter];
      });
      ref.invalidate(seekerDashboardProvider);

      UJobToast.success(
        context,
        context.l10n.successTitle,
        sub: context.l10n.coverLetterUploadedMessage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileData = ref.watch(seekerProfileProvider);
    final email = profileData?.user.email ?? '';



    String fullName = '${_firstNameCtrl.text} ${_lastNameCtrl.text}'.trim();
    if (fullName.isEmpty) fullName = 'User';

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: const Center(child: UJobSpinner(color: AppColors.seekPrimary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        color: AppColors.seekPrimary,
        child: SingleChildScrollView(
          key: ValueKey(_refreshKey),
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SeekerProfileHeader(
                name: fullName,
                headline: _headlineCtrl.text,
                email: email,
                isActive: profileData?.user.isVerifiedBadge == true,
                onEditImage: () {},
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (profileData != null && !profileData.isProfileComplete) ...[
                      UJobProfileSetupPrompt(
                        title: context.l10n.completeProfileToApplyTitle,
                        subtitle: context.l10n.completeProfileToApplySubtitle,
                      ),
                      SizedBox(height: 24.h),
                    ],

                    // 1. Personal Information
                    _SectionCard(
                      title: 'Personal Information',
                      subtitle: 'Your name and contact details',
                      icon: HugeIcons.strokeRoundedUser,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: UJobTextField(
                                  label: 'First Name',
                                  isRequired: true,
                                  hint: 'John',
                                  controller: _firstNameCtrl,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: UJobTextField(
                                  label: 'Last Name',
                                  isRequired: true,
                                  hint: 'Doe',
                                  controller: _lastNameCtrl,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          UJobPhoneNumberField(
                            label: "Phone Number",
                            isRequired: true,
                            isCodeEditable: false,
                            controller: _phoneCtrl,
                            initialDialCode: _phoneCode,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // 2. Location
                    _SectionCard(
                      title: 'Location',
                      subtitle: "Where you're based",
                      icon: HugeIcons.strokeRoundedLocation01,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: UJobCountryDropdown(
                                  isRequired: true,
                                  value: _country,
                                  onChanged: (v) {
                                    setState(() {
                                      _country = v;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: UJobTextField(
                                  label: 'City',
                                  isRequired: true,
                                  hint: 'London',
                                  controller: _cityCtrl,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          UJobTextField(
                            label: 'Address',
                            isRequired: true,
                            hint: '123 Oxford Street',
                            controller: _addressCtrl,
                          ),
                          SizedBox(height: 16.h),
                          UJobTextField(
                            label: 'Zip / Post Code',
                            isRequired: true,
                            hint: 'W1D 1BS',
                            controller: _zipCtrl,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // 3. Relocation — hidden for now (client request, will re-add later)
                    /*
                    _SectionCard(
                      title: 'Relocation',
                      subtitle: "Let employers know if you're open to moving",
                      icon: HugeIcons.strokeRoundedAirplane01,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 24.r,
                                height: 24.r,
                                child: Checkbox(
                                  value: _willingToRelocate,
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(() {
                                        _willingToRelocate = v;
                                        if (!v) _relocationType = null;
                                      });
                                    }
                                  },
                                  activeColor: AppColors.seekPrimary,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  "Yes, I'm willing to relocate",
                                  style: AppText.body.copyWith(
                                    color: AppColors.text,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_willingToRelocate) ...[
                            SizedBox(height: 16.h),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                RadioListTile<String>(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('Anywhere'),
                                  value: 'anywhere',
                                  groupValue: _relocationType,
                                  onChanged: (v) =>
                                      setState(() => _relocationType = v),
                                  activeColor: AppColors.seekPrimary,
                                ),
                                RadioListTile<String>(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('Desired Work Location'),
                                  value: 'specific',
                                  groupValue: _relocationType,
                                  onChanged: (v) =>
                                      setState(() => _relocationType = v),
                                  activeColor: AppColors.seekPrimary,
                                ),
                              ],
                            ),
                            if (_relocationType == 'specific') ...[
                              SizedBox(height: 16.h),
                              UJobTextField(
                                label: 'Desired Work Location',
                                hint: _relocationCities.length >= 3
                                    ? 'Maximum 3 cities reached'
                                    : 'Type a city and tap Add',
                                controller: _relocationCitiesCtrl,
                                readOnly: _relocationCities.length >= 3,
                                onChanged: (val) {
                                  if (_relocationCities.length >= 3) return;
                                  if (val.endsWith(',') || val.endsWith(' ')) {
                                    final city = val.replaceAll(',', '').trim();
                                    if (city.isNotEmpty &&
                                        !_relocationCities.contains(city)) {
                                      setState(() {
                                        _relocationCities.add(city);
                                        _relocationCitiesCtrl.clear();
                                      });
                                    } else {
                                      _relocationCitiesCtrl.clear();
                                      setState(() {});
                                    }
                                  } else {
                                    setState(() {});
                                  }
                                },
                                onSubmitted: (val) {
                                  if (_relocationCities.length >= 3) return;
                                  final city = val.trim();
                                  if (city.isNotEmpty &&
                                      !_relocationCities.contains(city)) {
                                    setState(() {
                                      _relocationCities.add(city);
                                      _relocationCitiesCtrl.clear();
                                    });
                                  }
                                },
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                'You can add up to 3 cities. Tap Add to include one.',
                                style: AppText.small.copyWith(
                                  color: AppColors.muted,
                                ),
                              ),
                              if (_relocationCitiesCtrl.text
                                      .trim()
                                      .isNotEmpty &&
                                  _relocationCities.length < 3) ...[
                                SizedBox(height: 8.h),
                                InkWell(
                                  onTap: () {
                                    final city = _relocationCitiesCtrl.text
                                        .trim();
                                    if (city.isNotEmpty &&
                                        !_relocationCities.contains(city)) {
                                      setState(() {
                                        _relocationCities.add(city);
                                        _relocationCitiesCtrl.clear();
                                      });
                                    }
                                  },
                                  borderRadius: AppRadius.md,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 12.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.seekPrimary.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: AppRadius.md,
                                    ),
                                    child: Row(
                                      children: [
                                        HugeIcon(
                                          icon: HugeIcons.strokeRoundedAdd01,
                                          color: AppColors.seekPrimary,
                                          size: 20.r,
                                        ),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: Text(
                                            'Tap to add "${_relocationCitiesCtrl.text.trim()}"',
                                            style: AppText.bodyBold.copyWith(
                                              color: AppColors.seekPrimary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                              if (_relocationCities.isNotEmpty) ...[
                                SizedBox(height: 12.h),
                                Wrap(
                                  spacing: 8.w,
                                  runSpacing: 8.h,
                                  children: _relocationCities.map((city) {
                                    return Chip(
                                      label: Text(
                                        city,
                                        style: AppText.body.copyWith(
                                          color: AppColors.seekPrimary,
                                        ),
                                      ),
                                      onDeleted: () {
                                        setState(() {
                                          _relocationCities.remove(city);
                                        });
                                      },
                                      backgroundColor: AppColors.seekPrimary
                                          .withValues(alpha: 0.15),
                                      deleteIconColor: AppColors.seekPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          100.r,
                                        ),
                                        side: BorderSide.none,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
                          ],
                        ],
                      ),
                    ),
                    */

                    // 4. Resume
                    _SectionCard(
                      title: 'Resume',
                      subtitle: "Upload your CV for employers to review",
                      icon: HugeIcons.strokeRoundedDocumentAttachment,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_resumes.isNotEmpty) ...[
                            ..._resumes.map(
                              (resume) => Padding(
                                padding: EdgeInsets.only(bottom: 12.h),
                                child: Container(
                                  padding: EdgeInsets.all(16.r),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: AppRadius.md,
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    children: [
                                      HugeIcon(
                                        icon: HugeIcons.strokeRoundedPdf01,
                                        color: AppColors.error,
                                        size: 32.r,
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              resume.fileName,
                                              style: AppText.bodyBold,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 4.h),
                                            Text(
                                              _formatResumeUpdatedAt(
                                                resume.createdAt,
                                              ),
                                              style: AppText.small.copyWith(
                                                color: AppColors.muted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  UJobDocumentViewerScreen(
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
                                      IconButton(
                                        onPressed: () =>
                                            _confirmDeleteResume(resume),
                                        icon: HugeIcon(
                                          icon: HugeIcons.strokeRoundedDelete01,
                                          color: AppColors.error,
                                          size: 20.r,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedCloudUpload,
                                  color: AppColors.seekPrimary,
                                  size: 40.r,
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  'Upload your latest resume',
                                  style: AppText.bodyBold,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'PDF, DOC, DOCX (Max 3MB)',
                                  style: AppText.small.copyWith(
                                    color: AppColors.muted,
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                UJobButton(
                                  label: context.l10n.uploadResume,
                                  onTap: _pickAndUploadResume,
                                  color: AppColors.seekPrimary,
                                  outlined: true,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // 4b. Cover Letter
                    _SectionCard(
                      title: context.l10n.coverLetterTitle,
                      subtitle: context.l10n.coverLetterSectionSubtitle,
                      icon: HugeIcons.strokeRoundedNote01,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_coverLetters.isNotEmpty) ...[
                            ..._coverLetters.map(
                              (coverLetter) => Padding(
                                padding: EdgeInsets.only(bottom: 12.h),
                                child: Container(
                                  padding: EdgeInsets.all(16.r),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: AppRadius.md,
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    children: [
                                      HugeIcon(
                                        icon: HugeIcons.strokeRoundedPdf01,
                                        color: AppColors.error,
                                        size: 32.r,
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              coverLetter.fileName,
                                              style: AppText.bodyBold,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 4.h),
                                            Text(
                                              _formatResumeUpdatedAt(
                                                coverLetter.createdAt,
                                              ),
                                              style: AppText.small.copyWith(
                                                color: AppColors.muted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  UJobDocumentViewerScreen(
                                                    title: context
                                                        .l10n.myCoverLetterTitle,
                                                    fileUrl: coverLetter.fileUrl,
                                                    fileName:
                                                        coverLetter.fileName,
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
                                      IconButton(
                                        onPressed: () =>
                                            _confirmDeleteCoverLetter(coverLetter),
                                        icon: HugeIcon(
                                          icon: HugeIcons.strokeRoundedDelete01,
                                          color: AppColors.error,
                                          size: 20.r,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedCloudUpload,
                                  color: AppColors.seekPrimary,
                                  size: 40.r,
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  context.l10n.coverLetterEmptyStateTitle,
                                  style: AppText.bodyBold,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  context.l10n.pdfCoverLetterMaxSizeHint,
                                  style: AppText.small.copyWith(
                                    color: AppColors.muted,
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                UJobButton(
                                  label: context.l10n.uploadCoverLetter,
                                  onTap: _pickAndUploadCoverLetter,
                                  color: AppColors.seekPrimary,
                                  outlined: true,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // 5. Professional Info
                    _SectionCard(
                      title: 'Professional Info',
                      subtitle: "Headline, experience and salary expectations",
                      icon: HugeIcons.strokeRoundedBriefcase01,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          UJobTextField(
                            label: 'Professional Headline',
                            isRequired: true,
                            hint:
                                'e.g. Senior React Developer with 5+ years experience',
                            controller: _headlineCtrl,
                          ),
                          SizedBox(height: 16.h),
                          UJobTextField(
                            label: "About / Summary",
                            isRequired: true,
                            hint: 'Tap to open editor',
                            readOnly: true,
                            maxLines: 4,
                            minLines: 4,
                            controller: TextEditingController(
                              text: getPlainTextFromQuillJson(_about),
                            ),
                            labelTrailing: HugeIcon(
                              icon: HugeIcons.strokeRoundedMaximize01,
                              color: AppColors.seekPrimary,
                              size: 20.r,
                            ),
                            onTap: () => showUJobRichTextEditor(
                              context: context,
                              title: 'About Me',
                              initialValue: _about,
                              returnHtml: true,
                              onSave: (val) {
                                setState(() {
                                  _about = val;
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              Expanded(
                                child: UJobDropdownField<String>(
                                  label: 'Experience - Years',
                                  isRequired: true,
                                  value: _expYears,
                                  options: List.generate(
                                    50,
                                    (i) =>
                                        ('${i + 1} years', (i + 1).toString()),
                                  ),
                                  onChanged: (v) =>
                                      setState(() => _expYears = v),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: UJobDropdownField<String>(
                                  label: 'Months',
                                  isRequired: true,
                                  value: _expMonths,
                                  options: List.generate(
                                    12,
                                    (i) => ('$i months', i.toString()),
                                  ),
                                  onChanged: (v) =>
                                      setState(() => _expMonths = v),
                                ),
                              ),
                            ],
                          ),
                          // Expected Salary / Currency / Salary Period — hidden for now (client request, will re-add later)
                          /*
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              Expanded(
                                child: UJobTextField(
                                  label: 'Expected Salary',
                                  isRequired: true,
                                  hint: 'e.g. 65000',
                                  controller: _expectedSalaryCtrl,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Consumer(
                                  builder: (context, ref, child) {
                                    final optionsAsync = ref.watch(
                                      jobFormOptionsProvider,
                                    );
                                    final currencies =
                                        optionsAsync.valueOrNull?.currencies ??
                                        [];
                                    final currencyOptions = currencies
                                        .map((c) => (c.label, c.value))
                                        .toList();

                                    return UJobDropdownField<String>(
                                      label: 'Currency',
                                      isRequired: true,
                                      value: _currency,
                                      options: currencyOptions.isNotEmpty
                                          ? currencyOptions
                                          : [
                                              ('USD', 'USD'),
                                              ('GBP', 'GBP'),
                                              ('EUR', 'EUR'),
                                            ],
                                      onChanged: (v) =>
                                          setState(() => _currency = v),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          UJobDropdownField<String>(
                            label: 'Salary Period',
                            isRequired: true,
                            value: _salaryPeriod,
                            options: const [
                              ('Yearly', 'yearly'),
                              ('Monthly', 'monthly'),
                            ],
                            onChanged: (v) =>
                                setState(() => _salaryPeriod = v ?? 'yearly'),
                          ),
                          */
                          SizedBox(height: 16.h),
                          UJobDropdownField<String>(
                            label: 'Availability',
                            isRequired: true,
                            value: _availability,
                            options: const [
                              ('Immediately', 'immediately'),
                              ('Within 1 month', 'within_1_month'),
                              ('Within 2 months', 'within_2_months'),
                              ('Within 3 months', 'within_3_months'),
                              ('Not looking', 'not_looking'),
                            ],
                            onChanged: (v) => setState(() => _availability = v),
                          ),
                        ],
                      ),
                    ),

                    // 6. Skills — hidden for now (client request, will re-add later)
                    /*
                    _SectionCard(
                      title: 'Skills',
                      subtitle: "Add skills to improve your job matches",
                      icon: HugeIcons.strokeRoundedAward01,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_selectedSkills.isNotEmpty) ...[
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: _selectedSkills.map((skill) {
                                return Chip(
                                  label: Text(
                                    skill.name,
                                    style: AppText.body.copyWith(
                                      color: AppColors.seekPrimary,
                                    ),
                                  ),
                                  onDeleted: () {
                                    setState(() {
                                      _selectedSkills.remove(skill);
                                    });
                                  },
                                  backgroundColor: AppColors.seekPrimary
                                      .withValues(alpha: 0.15),
                                  deleteIconColor: AppColors.seekPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100.r),
                                    side: BorderSide.none,
                                  ),
                                );
                              }).toList(),
                            ),
                            SizedBox(height: 16.h),
                          ],
                          UJobSkillAutocomplete(
                            controller: _skillSearchCtrl,
                            label: 'Search skills to add...',
                            hint: 'Type a skill...',
                            availableSkills: _availableSkills,
                            allowCreateWhenMissing: true,
                            onCreateSkill: _createMissingSkill,
                            onSkillSelected: (skill) {
                              if (skill != null && skill.id != -1) {
                                if (!_selectedSkills.any(
                                  (s) => s.id == skill.id,
                                )) {
                                  setState(() {
                                    _selectedSkills.add(skill);
                                    _skillSearchCtrl.clear();
                                  });
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    */

                    // 7. Work Experience — hidden for now (client request, will re-add later)
                    /*
                    _SectionCard(
                      title: 'Work Experience',
                      subtitle: "Your work history",
                      isRequired: true,
                      hasContent: _isFresher || _experiences.isNotEmpty,
                      icon: HugeIcons.strokeRoundedBriefcase02,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 24.r,
                                height: 24.r,
                                child: Checkbox(
                                  value: _isFresher,
                                  onChanged: (v) {
                                    setState(() {
                                      _isFresher = v ?? false;
                                    });
                                  },
                                  activeColor: AppColors.seekPrimary,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  "I am a Fresher (I have no work experience)",
                                  style: AppText.body.copyWith(
                                    color: AppColors.text,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (!_isFresher) ...[
                            SizedBox(height: 16.h),
                            if (_experiences.isNotEmpty) ...[
                            ..._experiences.map(
                              (exp) => Container(
                                margin: EdgeInsets.only(bottom: 12.h),
                                padding: EdgeInsets.all(16.r),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: AppRadius.md,
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            exp.jobTitle,
                                            style: AppText.bodyBold,
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            exp.companyName,
                                            style: AppText.body.copyWith(
                                              color: AppColors.seekPrimary,
                                            ),
                                          ),
                                          if (exp.location != null &&
                                              exp.location!.isNotEmpty) ...[
                                            SizedBox(height: 4.h),
                                            Row(
                                              children: [
                                                HugeIcon(
                                                  icon: HugeIcons
                                                      .strokeRoundedLocation01,
                                                  color: AppColors.muted,
                                                  size: 14.r,
                                                ),
                                                SizedBox(width: 4.w),
                                                Expanded(
                                                  child: Text(
                                                    exp.location!,
                                                    style: AppText.small
                                                        .copyWith(
                                                          color:
                                                              AppColors.muted,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                          SizedBox(height: 4.h),
                                          Row(
                                            children: [
                                              HugeIcon(
                                                icon: HugeIcons
                                                    .strokeRoundedCalendar01,
                                                color: AppColors.muted,
                                                size: 14.r,
                                              ),
                                              SizedBox(width: 4.w),
                                              Expanded(
                                                child: Text(
                                                  "${exp.startDate != null ? DateFormat('MMM yyyy').format(exp.startDate!) : 'N/A'} - ${exp.isCurrent ? 'Present' : (exp.endDate != null ? DateFormat('MMM yyyy').format(exp.endDate!) : 'N/A')}",
                                                  style: AppText.small.copyWith(
                                                    color: AppColors.muted,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (exp.description != null &&
                                              exp.description!.isNotEmpty) ...[
                                            SizedBox(height: 8.h),
                                            Text(
                                              getPlainTextFromQuillJson(
                                                exp.description!,
                                              ),
                                              style: AppText.small.copyWith(
                                                color: AppColors.text,
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InkWell(
                                          onTap: () async {
                                            final result =
                                                await showModalBottomSheet<
                                                  SeekerExperience
                                                >(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  builder: (ctx) =>
                                                      AddExperienceSheet(
                                                        initialData: exp,
                                                      ),
                                                );
                                            if (result != null) {
                                              setState(() {
                                                final idx = _experiences
                                                    .indexOf(exp);
                                                if (idx != -1) {
                                                  _experiences[idx] = result;
                                                }
                                              });
                                            }
                                          },
                                          child: HugeIcon(
                                            icon: HugeIcons.strokeRoundedEdit02,
                                            color: AppColors.seekPrimary,
                                            size: 20.r,
                                          ),
                                        ),
                                        SizedBox(width: 12.w),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              _experiences.remove(exp);
                                            });
                                          },
                                          child: HugeIcon(
                                            icon:
                                                HugeIcons.strokeRoundedDelete01,
                                            color: AppColors.error,
                                            size: 20.r,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 16.h),
                          ],
                          UJobButton(
                            label: 'Add Experience',
                            onTap: () async {
                              final result =
                                  await showModalBottomSheet<SeekerExperience>(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (ctx) =>
                                        const AddExperienceSheet(),
                                  );
                              if (result != null) {
                                setState(() {
                                  _experiences.add(result);
                                });
                              }
                            },
                            color: AppColors.seekPrimary,
                            outlined: true,
                          ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // 8. Education
                    _SectionCard(
                      title: 'Education',
                      subtitle: "Your academic background",
                      isRequired: true,
                      hasContent: _educations.isNotEmpty,
                      icon: HugeIcons.strokeRoundedBook01,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_educations.isNotEmpty) ...[
                            ..._educations.map(
                              (edu) => Container(
                                margin: EdgeInsets.only(bottom: 12.h),
                                padding: EdgeInsets.all(16.r),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: AppRadius.md,
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            edu.institution,
                                            style: AppText.bodyBold,
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            '${edu.degree} in ${edu.fieldOfStudy}',
                                            style: AppText.body.copyWith(
                                              color: AppColors.seekPrimary,
                                            ),
                                          ),
                                          if (edu.grade != null &&
                                              edu.grade!.isNotEmpty) ...[
                                            SizedBox(height: 4.h),
                                            Row(
                                              children: [
                                                HugeIcon(
                                                  icon: HugeIcons
                                                      .strokeRoundedAward01,
                                                  color: AppColors.muted,
                                                  size: 14.r,
                                                ),
                                                SizedBox(width: 4.w),
                                                Expanded(
                                                  child: Text(
                                                    'Grade: ${edu.grade}',
                                                    style: AppText.small
                                                        .copyWith(
                                                          color:
                                                              AppColors.muted,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                          SizedBox(height: 4.h),
                                          Row(
                                            children: [
                                              HugeIcon(
                                                icon: HugeIcons
                                                    .strokeRoundedCalendar01,
                                                color: AppColors.muted,
                                                size: 14.r,
                                              ),
                                              SizedBox(width: 4.w),
                                              Expanded(
                                                child: Text(
                                                  "${edu.startDate != null ? DateFormat('MMM yyyy').format(edu.startDate!) : 'N/A'} - ${edu.endDate != null ? DateFormat('MMM yyyy').format(edu.endDate!) : 'N/A'}",
                                                  style: AppText.small.copyWith(
                                                    color: AppColors.muted,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InkWell(
                                          onTap: () async {
                                            final result =
                                                await showModalBottomSheet<
                                                  SeekerEducation
                                                >(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  builder: (ctx) =>
                                                      AddEducationSheet(
                                                        initialData: edu,
                                                      ),
                                                );
                                            if (result != null) {
                                              setState(() {
                                                final idx = _educations.indexOf(
                                                  edu,
                                                );
                                                if (idx != -1) {
                                                  _educations[idx] = result;
                                                }
                                              });
                                            }
                                          },
                                          child: HugeIcon(
                                            icon: HugeIcons.strokeRoundedEdit02,
                                            color: AppColors.seekPrimary,
                                            size: 20.r,
                                          ),
                                        ),
                                        SizedBox(width: 12.w),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              _educations.remove(edu);
                                            });
                                          },
                                          child: HugeIcon(
                                            icon:
                                                HugeIcons.strokeRoundedDelete01,
                                            color: AppColors.error,
                                            size: 20.r,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 16.h),
                          ],
                          UJobButton(
                            label: 'Add Education',
                            onTap: () async {
                              final result =
                                  await showModalBottomSheet<SeekerEducation>(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (ctx) => const AddEducationSheet(),
                                  );
                              if (result != null) {
                                setState(() {
                                  _educations.add(result);
                                });
                              }
                            },
                            color: AppColors.seekPrimary,
                            outlined: true,
                          ),
                        ],
                      ),
                    ),
                    */
                    SizedBox(height: 16.h),

                    // 9. Online Presence
                    _SectionCard(
                      title: 'Online Presence',
                      subtitle: "Add links to your profiles and website",
                      icon: HugeIcons.strokeRoundedLink01,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          UJobTextField(
                            label: 'LinkedIn',
                            hint: 'https://linkedin.com/in/...',
                            controller: _linkedinCtrl,
                          ),
                          SizedBox(height: 12.h),
                          UJobTextField(
                            label: 'GitHub',
                            hint: 'https://github.com/...',
                            controller: _githubCtrl,
                          ),
                          SizedBox(height: 12.h),
                          UJobTextField(
                            label: 'Portfolio',
                            hint: 'https://...',
                            controller: _portfolioCtrl,
                          ),
                          SizedBox(height: 12.h),
                          UJobTextField(
                            label: 'X / Twitter',
                            hint: 'https://x.com/...',
                            controller: _twitterCtrl,
                          ),
                          SizedBox(height: 12.h),
                          UJobTextField(
                            label: 'Website',
                            hint: 'https://...',
                            controller: _websiteCtrl,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),
                    UJobButton(
                      label: "Update Profile",
                      color: AppColors.seekPrimary,
                      isLoading: _isUpdating,
                      onTap: () async {
                        // Work Experience / Education required checks disabled —
                        // those sections are hidden in the UI (client request, will re-add later).
                        final service = ref.read(seekerProfileServiceProvider);
                        setState(() => _isUpdating = true);
                        try {
                          final data = {
                            "first_name": _firstNameCtrl.text,
                            "last_name": _lastNameCtrl.text,
                            "phone_code": _phoneCode,
                            "phone": _phoneCtrl.text,
                            "show_phone": _showPhone,
                            "country": _country ?? '',
                            "city": _cityCtrl.text,
                            "address": _addressCtrl.text,
                            "zip_code": _zipCtrl.text,
                            "open_to_relocation": _willingToRelocate,
                            if (_willingToRelocate && _relocationType != null)
                              "relocation_type": _relocationType,
                            if (_willingToRelocate &&
                                _relocationType == 'specific')
                              "relocation_cities": _relocationCities.join(', '),
                            "headline": _headlineCtrl.text,
                            "experience_years": _buildExperienceYearsValue(),
                            "expected_salary":
                                double.tryParse(_expectedSalaryCtrl.text) ?? 0,
                            "salary_currency": _currency,
                            "salary_period": _salaryPeriod ?? 'yearly',
                            "availability": _availability,
                            "profile_visibility": _profileVisibility,
                            "about":
                                _about, // Note backend uses "summary" in the payload sometimes but about in response, mapping to summary based on user payload
                            "summary": _about,
                            "linkedin_url": _linkedinCtrl.text,
                            "github_url": _githubCtrl.text,
                            "portfolio_url": _portfolioCtrl.text,
                            "twitter_url": _twitterCtrl.text,
                            "website_url": _websiteCtrl.text,
                            "skills": _selectedSkills.map((e) => e.id).toList(),
                            "is_fresher": _isFresher,
                            if (!_isFresher)
                              "seeker_experiences": _experiences
                                  .map(
                                    (e) => {
                                      if (e.id.isNotEmpty) "id": e.id,
                                      "job_title": e.jobTitle,
                                      "company_name": e.companyName,
                                      "location": e.location ?? "",
                                      "start_date": e.startDate != null
                                          ? DateFormat(
                                              'yyyy-MM-dd',
                                            ).format(e.startDate!)
                                          : null,
                                      "end_date": e.endDate != null
                                          ? DateFormat(
                                              'yyyy-MM-dd',
                                            ).format(e.endDate!)
                                          : "",
                                      "is_current": e.isCurrent,
                                      "description": e.description ?? "",
                                    },
                                  )
                                  .toList(),
                            "seeker_educations": _educations
                                .map(
                                  (e) => {
                                    if (e.id.isNotEmpty) "id": e.id,
                                    "institution": e.institution,
                                    "degree": e.degree,
                                    "field_of_study": e.fieldOfStudy,
                                    "grade": e.grade ?? "",
                                    "start_date": e.startDate != null
                                        ? DateFormat(
                                            'yyyy-MM-dd',
                                          ).format(e.startDate!)
                                        : null,
                                    "end_date": e.endDate != null
                                        ? DateFormat(
                                            'yyyy-MM-dd',
                                          ).format(e.endDate!)
                                        : "",
                                  },
                                )
                                .toList(),
                          };

                          await service.updateProfile(data);

                          try {
                            final profileRefresh = ref.refresh(
                              fetchSeekerProfileProvider.future,
                            );
                            final dashboardRefresh = ref.refresh(
                              seekerDashboardProvider.future,
                            );

                            await profileRefresh;
                            await dashboardRefresh;
                          } catch (_) {
                            // Profile was saved. Keep current form values if a
                            // background refresh temporarily fails.
                          }

                          if (context.mounted) {
                            UJobToast.success(
                              context,
                              'Success',
                              sub: 'Profile updated successfully!',
                            );
                            context.go('/seeker');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            UJobToast.error(
                              context,
                              'Update Failed',
                              sub:
                                  'Failed to update profile. Please try again.',
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _isUpdating = false);
                        }
                      },
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeekerProfileHeader extends StatelessWidget {
  final String name;
  final String headline;
  final String email;
  final bool isActive;
  final VoidCallback onEditImage;

  const _SeekerProfileHeader({
    required this.name,
    required this.headline,
    required this.email,
    required this.isActive,
    required this.onEditImage,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.seekPrimary, AppColors.seekSecondary],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        20.w,
        MediaQuery.of(context).padding.top + 24.h,
        20.w,
        32.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 72.r,
                    height: 72.r,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.xl,
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'U',
                        style: AppText.heading1.copyWith(
                          color: AppColors.seekPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: AppText.heading2.copyWith(
                              color: AppColors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isActive) ...[
                          SizedBox(width: 6.w),
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedCheckmarkBadge01,
                            color: AppColors.white,
                            size: 20.r,
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      headline.isNotEmpty ? headline : 'Add a headline',
                      style: AppText.caption.copyWith(
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      email,
                      style: AppText.caption.copyWith(
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              IconButton(
                onPressed: () => context.push('/seeker/settings'),
                tooltip: 'Settings',
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surface.withValues(alpha: 0.12),
                  fixedSize: Size(44.r, 44.r),
                ),
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedSettings01,
                  color: AppColors.surface,
                  size: 23.r,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final dynamic icon;
  final Widget child;
  final bool isRequired;
  final bool? hasContent;

  const _SectionCard({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.child,
    this.isRequired = false,
    this.hasContent,
  });

  @override
  State<_SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<_SectionCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = widget.isRequired && widget.hasContent == false;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.xl,
        border: Border.all(
          color: isEmpty ? AppColors.error.withValues(alpha: 0.4) : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.seekPrimary.withValues(
              alpha: _isExpanded ? 0.08 : 0.02,
            ),
            blurRadius: _isExpanded ? 24 : 10,
            offset: Offset(0, _isExpanded ? 8 : 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: AppRadius.xl,
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: isEmpty
                          ? AppColors.error.withValues(alpha: 0.08)
                          : AppColors.seekPrimary.withValues(alpha: 0.1),
                      borderRadius: AppRadius.md,
                    ),
                    child: HugeIcon(
                      icon: widget.icon,
                      color: isEmpty ? AppColors.error : AppColors.seekPrimary,
                      size: 20.r,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.title,
                              style: AppText.bodyBold.copyWith(
                                color: AppColors.text2,
                              ),
                            ),
                            if (widget.isRequired) ...[
                              SizedBox(width: 4.w),
                              Text(
                                '*',
                                style: AppText.bodyBold.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 2.h),
                        if (isEmpty)
                          Text(
                            'At least 1 required',
                            style: AppText.caption.copyWith(
                              color: AppColors.error,
                            ),
                          )
                        else if (widget.subtitle != null &&
                            widget.subtitle!.isNotEmpty)
                          Text(
                            widget.subtitle!,
                            style: AppText.caption.copyWith(
                              color: AppColors.muted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  HugeIcon(
                    icon: _isExpanded
                        ? HugeIcons.strokeRoundedArrowUp01
                        : HugeIcons.strokeRoundedArrowDown01,
                    color: AppColors.muted,
                    size: 20.r,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: EdgeInsets.fromLTRB(20.r, 16.r, 20.r, 20.r),
              child: widget.child,
            ),
        ],
      ),
    );
  }
}
