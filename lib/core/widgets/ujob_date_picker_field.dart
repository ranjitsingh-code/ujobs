import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import 'ujob_text_field.dart';

class UJobDatePickerField extends StatelessWidget {
  final String label;
  final String hint;
  final String value;
  final ValueChanged<String> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const UJobDatePickerField({
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    super.key,
  });

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now().add(const Duration(days: 30));
    if (value.isNotEmpty) {
      try {
        initialDate = DateFormat('MM/dd/yyyy').parse(value);
      } catch (_) {}
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime.now(),
      lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.text,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted = DateFormat('MM/dd/yyyy').format(picked);
      onChanged(formatted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: UJobTextField(
          label: label,
          hint: hint,
          readOnly: true,
          controller: TextEditingController(text: value),
          suffix: Padding(
            padding: EdgeInsets.only(right: 14.w),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedCalendar01,
              color: AppColors.muted2,
              size: 20.r,
            ),
          ),
          onChanged: (_) {},
        ),
      ),
    );
  }
}
