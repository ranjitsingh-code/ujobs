import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class UJobTagInput extends StatefulWidget {
  final String label;
  final String hint;
  final List<String> tags;
  final ValueChanged<List<String>> onChanged;

  const UJobTagInput({
    required this.label,
    required this.hint,
    required this.tags,
    required this.onChanged,
    super.key,
  });

  @override
  State<UJobTagInput> createState() => _UJobTagInputState();
}

class _UJobTagInputState extends State<UJobTagInput> {
  final _controller = TextEditingController();

  void _addTag(String value) {
    final text = value.trim();
    if (text.isNotEmpty && !widget.tags.contains(text)) {
      final newTags = List<String>.from(widget.tags)..add(text);
      widget.onChanged(newTags);
    }
    _controller.clear();
  }

  void _removeTag(String tag) {
    final newTags = List<String>.from(widget.tags)..remove(tag);
    widget.onChanged(newTags);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppText.label.copyWith(color: AppColors.muted),
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.tags.isNotEmpty) ...[
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: widget.tags.map((tag) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tag,
                            style: AppText.small.copyWith(color: AppColors.primary),
                          ),
                          SizedBox(width: 6.w),
                          GestureDetector(
                            onTap: () => _removeTag(tag),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedCancel01,
                              color: AppColors.primary,
                              size: 14.r,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 12.h),
              ],
              TextField(
                controller: _controller,
                style: AppText.bodyMedium.copyWith(color: AppColors.text),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: AppText.bodyMedium.copyWith(color: AppColors.muted2),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onSubmitted: _addTag,
                textInputAction: TextInputAction.done,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
