import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ujob_app_bar.dart';
import '../../../core/widgets/ujob_button.dart';
import '../../../core/widgets/ujob_text_field.dart';
import '../../../core/widgets/ujob_dropdown.dart';
import '../../../core/widgets/ujob_rich_text_field.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: UJobAppBar(
        title: 'My Profile',
        showBack: true,
        backgroundColor: AppColors.background,
        rightWidget: IconButton(
          icon: const HugeIcon(icon: HugeIcons.strokeRoundedSettings01, color: AppColors.text, size: 24),
          onPressed: () => context.push('/seeker/settings'),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 100.h),
        children: [
          _buildHeader(),
          SizedBox(height: 24.h),
          
          _FormSection(
            title: 'Personal Information',
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
            ],
          ),
          
          SizedBox(height: 24.h),
          _FormSection(
            title: 'Location & Relocation',
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
            ],
          ),

          SizedBox(height: 24.h),
          _FormSection(
            title: 'Professional Info',
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
            ],
          ),

          SizedBox(height: 24.h),
          _FormSection(
            title: 'Resume',
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
                    HugeIcon(icon: HugeIcons.strokeRoundedCloudUpload, color: AppColors.primary, size: 40.r),
                    SizedBox(height: 12.h),
                    Text('Upload your latest resume', style: AppText.bodyBold),
                    SizedBox(height: 4.h),
                    Text('PDF, DOC, DOCX (Max 5MB)', style: AppText.small.copyWith(color: AppColors.muted)),
                    SizedBox(height: 16.h),
                    UJobButton(
                      label: 'Browse File',
                      onTap: () {},
                      outlined: true,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 32.h),
          UJobButton(
            label: 'Save Profile',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 80.r,
            height: 80.r,
            decoration: BoxDecoration(
              color: AppColors.seekPrimary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              'AH',
              style: AppText.heading1.copyWith(color: AppColors.seekPrimary, fontSize: 32.sp),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Azad Hossain', style: AppText.heading2),
                SizedBox(height: 4.h),
                Text('azad@example.com', style: AppText.body.copyWith(color: AppColors.muted)),
                SizedBox(height: 8.h),
                Text('Your profile is 80% complete', style: AppText.bodyBold.copyWith(color: AppColors.success)),
              ],
            ),
          ),
          IconButton(
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedCamera02, color: AppColors.seekPrimary),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _FormSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
          child: Text(
            title.toUpperCase(),
            style: AppText.small.copyWith(color: AppColors.muted, letterSpacing: 1, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
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
              activeColor: AppColors.primary,
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
