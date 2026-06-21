import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/app_colors.dart';
import 'ujob_text_field.dart';
import 'ujob_rich_text_editor.dart';

class UJobRichTextField extends StatelessWidget {
  final String label;
  final String hint;
  final String initialValue;
  final ValueChanged<String> onSave;
  final int minLines;
  final int maxLines;

  const UJobRichTextField({
    required this.label,
    required this.hint,
    required this.initialValue,
    required this.onSave,
    this.minLines = 5,
    this.maxLines = 10,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showUJobRichTextEditor(
        context: context,
        title: label,
        initialValue: initialValue,
        onSave: onSave,
      ),
      child: UJobTextField(
        label: label,
        hint: hint,
        minLines: minLines,
        maxLines: maxLines,
        readOnly: true,
        labelTrailing: HugeIcon(
          icon: HugeIcons.strokeRoundedMaximize01,
          color: AppColors.primary,
          size: 20.r,
        ),
        controller: TextEditingController(
          text: getPlainTextFromQuillJson(initialValue),
        ),
        onTap: () => showUJobRichTextEditor(
          context: context,
          title: label,
          initialValue: initialValue,
          onSave: onSave,
        ),
      ),
    );
  }
}
