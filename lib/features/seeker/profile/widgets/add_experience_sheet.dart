import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/ujob_button.dart';
import '../../../../core/widgets/ujob_text_field.dart';
import '../../../../core/models/seeker_profile.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/ujob_toast.dart';

class AddExperienceSheet extends StatefulWidget {
  final SeekerExperience? initialData;

  const AddExperienceSheet({super.key, this.initialData});

  @override
  State<AddExperienceSheet> createState() => _AddExperienceSheetState();
}

class _AddExperienceSheetState extends State<AddExperienceSheet> {
  final _titleCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCurrent = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _titleCtrl.text = widget.initialData!.jobTitle;
      _companyCtrl.text = widget.initialData!.companyName;
      _locationCtrl.text = widget.initialData!.location ?? '';
      _descCtrl.text = widget.initialData!.description ?? '';
      _startDate = widget.initialData!.startDate;
      _endDate = widget.initialData!.endDate;
      _isCurrent = widget.initialData!.isCurrent;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _companyCtrl.dispose();
    _locationCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
        } else {
          _endDate = date;
        }
      });
    }
  }

  void _save() {
    if (_titleCtrl.text.isEmpty ||
        _companyCtrl.text.isEmpty ||
        _locationCtrl.text.isEmpty ||
        _startDate == null ||
        _descCtrl.text.isEmpty) {
      UJobToast.error(context, 'Validation Error', sub: 'Please fill out Job Title, Company, Location, Start Date, and Description');
      return;
    }

    final newExp = SeekerExperience(
      id: widget.initialData?.id ?? '', // Local ID mapping
      jobTitle: _titleCtrl.text,
      companyName: _companyCtrl.text,
      location: _locationCtrl.text,
      startDate: _startDate,
      endDate: _isCurrent ? null : _endDate,
      isCurrent: _isCurrent,
      description: _descCtrl.text,
    );
    Navigator.pop(context, newExp);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, MediaQuery.of(context).viewInsets.bottom + 20.h),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.initialData == null ? 'Add Experience' : 'Edit Experience',
                  style: AppText.heading3,
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            UJobTextField(
              label: 'Job Title',
              isRequired: true,
              hint: 'e.g. Flutter Developer',
              controller: _titleCtrl,
            ),
            SizedBox(height: 16.h),
            UJobTextField(
              label: 'Company Name',
              isRequired: true,
              hint: 'e.g. Google',
              controller: _companyCtrl,
            ),
            SizedBox(height: 16.h),
            UJobTextField(
              label: 'Location',
              isRequired: true,
              hint: 'e.g. London',
              controller: _locationCtrl,
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _pickDate(true),
                    child: IgnorePointer(
                      child: UJobTextField(
                        label: 'Start Date',
                        isRequired: true,
                        hint: 'MM/DD/YYYY',
                        controller: TextEditingController(
                          text: _startDate != null ? DateFormat('MM/dd/yyyy').format(_startDate!) : '',
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: InkWell(
                    onTap: _isCurrent ? null : () => _pickDate(false),
                    child: IgnorePointer(
                      child: UJobTextField(
                        label: 'End Date',
                        hint: _isCurrent ? 'Present' : 'MM/DD/YYYY',
                        controller: TextEditingController(
                          text: _endDate != null && !_isCurrent ? DateFormat('MM/dd/yyyy').format(_endDate!) : '',
                        ),
                        readOnly: _isCurrent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                SizedBox(
                  width: 24.r,
                  height: 24.r,
                  child: Checkbox(
                    value: _isCurrent,
                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          _isCurrent = v;
                          if (v) _endDate = null;
                        });
                      }
                    },
                    activeColor: AppColors.seekPrimary,
                  ),
                ),
                SizedBox(width: 12.w),
                Text('I currently work here', style: AppText.body),
              ],
            ),
            SizedBox(height: 16.h),
            UJobTextField(
              label: 'Description',
              isRequired: true,
              hint: 'Describe your responsibilities and achievements',
              controller: _descCtrl,
              maxLines: 4,
            ),
            SizedBox(height: 24.h),
            UJobButton(
              label: 'Save Experience',
              color: AppColors.seekPrimary,
              onTap: _save,
            ),
          ],
        ),
      ),
    );
  }
}
