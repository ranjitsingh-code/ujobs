import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/ujob_button.dart';
import '../../../../core/widgets/ujob_text_field.dart';
import '../../../../core/models/seeker_profile.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/ujob_toast.dart';

class AddEducationSheet extends StatefulWidget {
  final SeekerEducation? initialData;

  const AddEducationSheet({super.key, this.initialData});

  @override
  State<AddEducationSheet> createState() => _AddEducationSheetState();
}

class _AddEducationSheetState extends State<AddEducationSheet> {
  final _institutionCtrl = TextEditingController();
  final _degreeCtrl = TextEditingController();
  final _fieldCtrl = TextEditingController();
  final _gradeCtrl = TextEditingController();
  
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _institutionCtrl.text = widget.initialData!.institution;
      _degreeCtrl.text = widget.initialData!.degree;
      _fieldCtrl.text = widget.initialData!.fieldOfStudy;
      _gradeCtrl.text = widget.initialData!.grade ?? '';
      _startDate = widget.initialData!.startDate;
      _endDate = widget.initialData!.endDate;
    }
  }

  @override
  void dispose() {
    _institutionCtrl.dispose();
    _degreeCtrl.dispose();
    _fieldCtrl.dispose();
    _gradeCtrl.dispose();
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
    if (_institutionCtrl.text.isEmpty || _degreeCtrl.text.isEmpty || _startDate == null) {
      UJobToast.error(context, 'Validation Error', sub: 'Please fill out Institution, Degree, and Start Date');
      return;
    }

    final newEdu = SeekerEducation(
      id: widget.initialData?.id ?? '', // Local ID mapping
      institution: _institutionCtrl.text,
      degree: _degreeCtrl.text,
      fieldOfStudy: _fieldCtrl.text,
      grade: _gradeCtrl.text,
      startDate: _startDate,
      endDate: _endDate,
    );
    Navigator.pop(context, newEdu);
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
                  widget.initialData == null ? 'Add Education' : 'Edit Education',
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
              label: 'Institution *',
              hint: 'e.g. University of London',
              controller: _institutionCtrl,
            ),
            SizedBox(height: 16.h),
            UJobTextField(
              label: 'Degree *',
              hint: 'e.g. BSc Computer Science',
              controller: _degreeCtrl,
            ),
            SizedBox(height: 16.h),
            UJobTextField(
              label: 'Field of Study',
              hint: 'e.g. Computer Science',
              controller: _fieldCtrl,
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _pickDate(true),
                    child: IgnorePointer(
                      child: UJobTextField(
                        label: 'Start Date *',
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
                    onTap: () => _pickDate(false),
                    child: IgnorePointer(
                      child: UJobTextField(
                        label: 'End Date',
                        hint: 'MM/DD/YYYY',
                        controller: TextEditingController(
                          text: _endDate != null ? DateFormat('MM/dd/yyyy').format(_endDate!) : '',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            UJobTextField(
              label: 'Grade / Result',
              hint: 'e.g. First Class, 3.8 GPA',
              controller: _gradeCtrl,
            ),
            SizedBox(height: 24.h),
            UJobButton(
              label: 'Save Education',
              color: AppColors.seekPrimary,
              onTap: _save,
            ),
          ],
        ),
      ),
    );
  }
}
