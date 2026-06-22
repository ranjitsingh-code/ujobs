import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ujob_app_bar.dart';
import '../../../core/widgets/ujob_button.dart';
import '../../../core/widgets/ujob_text_field.dart';
import '../../../core/widgets/ujob_dropdown.dart';
import '../../../core/widgets/ujob_rich_text_field.dart';
import '../../../core/widgets/ujob_rich_text_editor.dart';

class SeekerProfileScreen extends ConsumerStatefulWidget {
  const SeekerProfileScreen({super.key});

  @override
  ConsumerState<SeekerProfileScreen> createState() => _SeekerProfileState();
}

class _SeekerProfileState extends ConsumerState<SeekerProfileScreen> {
  // Personal Information
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _showNumber = false;
  
  // Location
  final _countryCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  bool _willingToRelocate = false;

  // Professional Info
  final _headlineCtrl = TextEditingController();
  final _skillsCtrl = TextEditingController();
  String? _expYears;
  String? _expMonths;
  String? _expectedSalary;
  String? _currency;
  String? _availability;
  String? _profileVisibility;

  // Rich Text
  String _about = '';

  @override
  void initState() {
    super.initState();
    // Pre-fill mock data
    _firstNameCtrl.text = 'Azad';
    _lastNameCtrl.text = 'Hossain';
    _phoneCtrl.text = '+1 234 567 890';
    _headlineCtrl.text = 'Senior Flutter Developer';
    _countryCtrl.text = 'United States';
    _cityCtrl.text = 'San Francisco';
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _countryCtrl.dispose();
    _cityCtrl.dispose();
    _addressCtrl.dispose();
    _zipCtrl.dispose();
    _headlineCtrl.dispose();
    _skillsCtrl.dispose();
    super.dispose();
  }

  void _showBottomSheet(BuildContext context, String title, Widget child) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(24.w, 20.h, 16.w, 16.h),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.borderLight)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: AppText.heading2),
                    IconButton(
                      icon: HugeIcon(icon: HugeIcons.strokeRoundedCancel01, color: AppColors.muted, size: 24.r),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }

  void _showEditPersonalInfo() {
    _showBottomSheet(
      context,
      'Personal Information',
      Padding(
        padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: UJobTextField(label: 'First Name', hint: 'John', controller: _firstNameCtrl)),
                SizedBox(width: 12.w),
                Expanded(child: UJobTextField(label: 'Last Name', hint: 'Doe', controller: _lastNameCtrl)),
              ],
            ),
            SizedBox(height: 16.h),
            UJobTextField(label: 'Phone Number', hint: '+1 234 567 890', controller: _phoneCtrl, keyboardType: TextInputType.phone),
            _CheckboxTile(
              label: 'Show my number to employers',
              value: _showNumber,
              onChanged: (v) { if (v != null) setState(() => _showNumber = v); },
            ),
            SizedBox(height: 32.h),
            UJobButton(
              label: 'Save Changes',
              color: AppColors.seekPrimary,
              onTap: () {
                setState(() {});
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditLocation() {
    _showBottomSheet(
      context,
      'Location & Relocation',
      Padding(
        padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: UJobTextField(label: 'Country', hint: 'United States', controller: _countryCtrl)),
                SizedBox(width: 12.w),
                Expanded(child: UJobTextField(label: 'City', hint: 'San Francisco', controller: _cityCtrl)),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(child: UJobTextField(label: 'Address', hint: '123 Tech Lane', controller: _addressCtrl)),
                SizedBox(width: 12.w),
                Expanded(child: UJobTextField(label: 'Zip/Post Code', hint: '94105', controller: _zipCtrl)),
              ],
            ),
            _CheckboxTile(
              label: "Yes, I'm willing to relocate",
              value: _willingToRelocate,
              onChanged: (v) { if (v != null) setState(() => _willingToRelocate = v); },
            ),
            SizedBox(height: 32.h),
            UJobButton(
              label: 'Save Changes',
              color: AppColors.seekPrimary,
              onTap: () {
                setState(() {});
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfessionalInfo() {
    _showBottomSheet(
      context,
      'Professional Info',
      Padding(
        padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UJobTextField(label: 'Professional Headline', hint: 'e.g. Senior Flutter Developer', controller: _headlineCtrl),
            SizedBox(height: 16.h),
            Text('About / Summary', style: AppText.bodyBold.copyWith(color: AppColors.text)),
            SizedBox(height: 8.h),
            UJobRichTextField(
              label: 'About',
              hint: 'Write a short bio about yourself...',
              initialValue: _about,
              onSave: (v) => setState(() => _about = v),
            ),
            SizedBox(height: 16.h),
            UJobTextField(label: 'Skills', hint: 'Type and press enter...', controller: _skillsCtrl),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: UJobDropdown(
                    label: 'Experience (Years)',
                    value: _expYears ?? '0',
                    items: List.generate(10, (i) => i.toString()),
                    onChanged: (v) { if (v != null) setState(() => _expYears = v); },
                    ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: UJobDropdown(
                    label: 'Months',
                    value: _expMonths ?? '0',
                    items: List.generate(11, (i) => i.toString()),
                    onChanged: (v) { if (v != null) setState(() => _expMonths = v); },
                    ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: UJobDropdown(
                    label: 'Expected Salary',
                    value: _expectedSalary ?? '\$30k-\$50k',
                    items: const ['\$30k-\$50k', '\$50k-\$80k', '\$80k-\$120k', '\$120k+'],
                    onChanged: (v) { if (v != null) setState(() => _expectedSalary = v); },
                    ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: UJobDropdown(
                    label: 'Currency',
                    value: _currency ?? 'USD',
                    items: const ['USD', 'EUR', 'GBP'],
                    onChanged: (v) { if (v != null) setState(() => _currency = v); },
                    ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            UJobDropdown(
              label: 'Availability',
              value: _availability ?? 'Immediately',
              items: const ['Immediately', '1 Week', '2 Weeks', '1 Month', 'More than 1 Month'],
              onChanged: (v) { if (v != null) setState(() => _availability = v); },
              ),
            SizedBox(height: 16.h),
            UJobDropdown(
              label: 'Profile Visibility',
              value: _profileVisibility ?? 'Public',
              items: const ['Public', 'Private', 'Only to Employers I Apply To'],
              onChanged: (v) { if (v != null) setState(() => _profileVisibility = v); },
              ),
            SizedBox(height: 32.h),
            UJobButton(
              label: 'Save Changes',
              color: AppColors.seekPrimary,
              onTap: () {
                setState(() {});
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditResume() {
    _showBottomSheet(
      context,
      'Resume',
      Padding(
        padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.borderLight, style: BorderStyle.solid),
              ),
              child: Column(
                children: [
                  HugeIcon(icon: HugeIcons.strokeRoundedCloudUpload, color: AppColors.seekPrimary, size: 40.r),
                  SizedBox(height: 12.h),
                  Text('Upload your latest resume', style: AppText.bodyBold),
                  SizedBox(height: 4.h),
                  Text('PDF, DOC, DOCX (Max 5MB)', style: AppText.small.copyWith(color: AppColors.muted)),
                  SizedBox(height: 16.h),
                  UJobButton(
                    label: 'Browse File',
                    onTap: () {},
                    color: AppColors.seekPrimary,
                    outlined: true,
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            UJobButton(
              label: 'Done',
              color: AppColors.seekPrimary,
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String fullName = '${_firstNameCtrl.text} ${_lastNameCtrl.text}'.trim();
    if (fullName.isEmpty) fullName = 'User';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SeekerProfileHeader(
              name: fullName,
              headline: _headlineCtrl.text,
              email: 'azad@example.com',
              completeness: 0.8,
              onEditImage: () {},
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SectionCard(
                    title: 'Personal Information',
                    subtitle: [fullName, _phoneCtrl.text].where((e) => e.isNotEmpty).join(' · '),
                    icon: HugeIcons.strokeRoundedUser,
                    onEdit: _showEditPersonalInfo,
                    child: Column(
                      children: [
                        _DetailRow(label: 'First Name', value: _firstNameCtrl.text),
                        _DetailRow(label: 'Last Name', value: _lastNameCtrl.text),
                        _DetailRow(label: 'Phone', value: _phoneCtrl.text),
                        _DetailRow(label: 'Phone Visibility', value: _showNumber ? 'Visible to employers' : 'Hidden'),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _SectionCard(
                    title: 'Professional Info',
                    subtitle: [_headlineCtrl.text, _expYears != null ? '$_expYears years exp' : null].whereType<String>().where((e) => e.isNotEmpty).join(' · '),
                    icon: HugeIcons.strokeRoundedBriefcase01,
                    onEdit: _showEditProfessionalInfo,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DetailRow(label: 'Headline', value: _headlineCtrl.text),
                        _DetailRow(label: 'Skills', value: _skillsCtrl.text),
                        _DetailRow(label: 'Experience', value: (_expYears != null && _expMonths != null) ? '$_expYears yrs $_expMonths mos' : null),
                        _DetailRow(label: 'Expected Salary', value: (_expectedSalary != null && _currency != null) ? '$_expectedSalary $_currency' : null),
                        _DetailRow(label: 'Availability', value: _availability),
                        _DetailRow(label: 'Visibility', value: _profileVisibility),
                        SizedBox(height: 8.h),
                        Text('About Me', style: AppText.bodyMd.copyWith(color: AppColors.muted)),
                        SizedBox(height: 4.h),
                        Text(
                          _about.isNotEmpty ? getPlainTextFromQuillJson(_about) : 'Not set',
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.bodyMd.copyWith(
                            color: _about.isNotEmpty ? AppColors.text2 : AppColors.muted2,
                            fontStyle: _about.isNotEmpty ? FontStyle.normal : FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _SectionCard(
                    title: 'Location & Relocation',
                    subtitle: [_cityCtrl.text, _countryCtrl.text].where((e) => e.isNotEmpty).join(' · '),
                    icon: HugeIcons.strokeRoundedLocation01,
                    onEdit: _showEditLocation,
                    child: Column(
                      children: [
                        _DetailRow(label: 'Country', value: _countryCtrl.text),
                        _DetailRow(label: 'City', value: _cityCtrl.text),
                        _DetailRow(label: 'Address', value: _addressCtrl.text),
                        _DetailRow(label: 'Zip/Post Code', value: _zipCtrl.text),
                        _DetailRow(label: 'Relocation', value: _willingToRelocate ? 'Willing to relocate' : 'Not willing to relocate'),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _SectionCard(
                    title: 'Resume',
                    subtitle: 'Resume.pdf',
                    icon: HugeIcons.strokeRoundedDocumentAttachment,
                    onEdit: _showEditResume,
                    child: Column(
                      children: [
                        _DetailRow(label: 'Current Resume', value: 'Resume.pdf (2.4 MB)'),
                      ],
                    ),
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeekerProfileHeader extends StatelessWidget {
  final String name;
  final String headline;
  final String email;
  final double completeness;
  final VoidCallback onEditImage;

  const _SeekerProfileHeader({
    required this.name,
    required this.headline,
    required this.email,
    required this.completeness,
    required this.onEditImage,
  });

  @override
  Widget build(BuildContext context) {
    int percentCompleted = (completeness * 100).toInt();

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 32.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32.r),
          bottomRight: Radius.circular(32.r),
        ),
        boxShadow: AppShadow.card(),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              IconButton(
                onPressed: () => context.pop(),
                tooltip: 'Back',
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  fixedSize: Size(44.r, 44.r),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.md,
                    side: BorderSide(color: AppColors.border),
                  ),
                ),
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowLeft01,
                  color: AppColors.text,
                  size: 20.r,
                ),
              ),
              // Avatar Info
              Expanded(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 88.r,
                          height: 88.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.seekPrimary.withValues(alpha: 0.1),
                            border: Border.all(color: AppColors.seekPrimary.withValues(alpha: 0.2), width: 4),
                          ),
                          child: Center(
                            child: HugeIcon(icon: HugeIcons.strokeRoundedUser, color: AppColors.seekPrimary, size: 40.r),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: onEditImage,
                            child: Container(
                              padding: EdgeInsets.all(6.r),
                              decoration: BoxDecoration(
                                color: AppColors.seekPrimary,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.surface, width: 2),
                              ),
                              child: HugeIcon(icon: HugeIcons.strokeRoundedCamera02, color: AppColors.surface, size: 14.r),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      name,
                      style: AppText.heading2.copyWith(color: AppColors.text2),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      headline.isNotEmpty ? headline : 'Add a headline',
                      style: AppText.bodyMd.copyWith(color: AppColors.muted),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      email,
                      style: AppText.caption.copyWith(color: AppColors.muted2),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // Settings Button
              IconButton(
                onPressed: () => context.push('/seeker/settings'),
                tooltip: 'Settings',
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  fixedSize: Size(44.r, 44.r),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.md,
                    side: BorderSide(color: AppColors.border),
                  ),
                ),
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedSettings01,
                  color: AppColors.text,
                  size: 20.r,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          // Progress Section
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppColors.seekPrimary.withValues(alpha: 0.05),
              borderRadius: AppRadius.lg,
              border: Border.all(color: AppColors.seekPrimary.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile Completeness',
                      style: AppText.bodyMd.copyWith(color: AppColors.seekPrimary),
                    ),
                    Text(
                      '${percentCompleted}%',
                      style: AppText.bodyBold.copyWith(color: AppColors.seekPrimary),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                ClipRRect(
                  borderRadius: AppRadius.pill,
                  child: LinearProgressIndicator(
                    value: completeness,
                    backgroundColor: AppColors.seekPrimary.withValues(alpha: 0.2),
                    color: AppColors.seekPrimary,
                    minHeight: 6.h,
                  ),
                ),
                if (completeness < 1.0) ...[
                  SizedBox(height: 12.h),
                  Text(
                    'Complete your profile to unlock all features',
                    style: AppText.caption.copyWith(color: AppColors.seekPrimary.withValues(alpha: 0.8)),
                  ),
                ],
              ],
            ),
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
  final VoidCallback onEdit;

  const _SectionCard({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.child,
    required this.onEdit,
  });

  @override
  State<_SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<_SectionCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.xl,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.seekPrimary.withValues(alpha: _isExpanded ? 0.08 : 0.02),
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
            borderRadius: _isExpanded 
                ? BorderRadius.vertical(top: Radius.circular(AppRadius.xl.topLeft.x))
                : AppRadius.xl,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.r, 20.r, 20.r, _isExpanded ? 0 : 20.r),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: AppColors.seekPrimary.withValues(alpha: 0.1),
                      borderRadius: AppRadius.md,
                    ),
                    child: HugeIcon(icon: widget.icon, color: AppColors.seekPrimary, size: 20.r),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(widget.title, style: AppText.bodyBold.copyWith(color: AppColors.text2)),
                        if (!_isExpanded && widget.subtitle != null && widget.subtitle!.isNotEmpty) ...[
                          SizedBox(height: 2.h),
                          Text(
                            widget.subtitle!,
                            style: AppText.caption.copyWith(color: AppColors.muted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ] else if (!_isExpanded) ...[
                          SizedBox(height: 2.h),
                          Text(
                            'Not set',
                            style: AppText.caption.copyWith(color: AppColors.muted2, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: widget.onEdit,
                    icon: HugeIcon(icon: HugeIcons.strokeRoundedEdit02, color: AppColors.seekPrimary, size: 14.r),
                    label: Text('Edit', style: AppText.caption.copyWith(color: AppColors.seekPrimary, fontWeight: FontWeight.w600)),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.125 : 0.0, // Rotates + to x
                    duration: const Duration(milliseconds: 300),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedAdd01,
                      color: AppColors.muted,
                      size: 20.r,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: EdgeInsets.fromLTRB(20.r, 0, 20.r, 20.r),
              child: widget.child,
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String? value;

  const _DetailRow({required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = value == null || value!.isEmpty;
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(label, style: AppText.bodyMd.copyWith(color: AppColors.muted)),
          ),
          Expanded(
            child: Text(
              isEmpty ? 'Not set' : value!,
              style: AppText.bodyMd.copyWith(
                color: isEmpty ? AppColors.muted2 : AppColors.text2,
                fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckboxTile extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CheckboxTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 12.h),
      child: Row(
        children: [
          SizedBox(
            width: 24.r,
            height: 24.r,
            child: Checkbox(
              value: value,
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
              activeColor: AppColors.seekPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(label, style: AppText.body.copyWith(color: AppColors.text)),
          ),
        ],
      ),
    );
  }
}
