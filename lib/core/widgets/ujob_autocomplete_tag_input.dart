import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class UJobAutocompleteTagInput extends StatefulWidget {
  final String label;
  final String hint;
  final List<String> tags;
  final ValueChanged<List<String>> onChanged;
  final List<String> suggestions;
  final Future<String?> Function(String value)? onCreateTag;

  const UJobAutocompleteTagInput({
    required this.label,
    required this.hint,
    required this.tags,
    required this.onChanged,
    required this.suggestions,
    this.onCreateTag,
    super.key,
  });

  @override
  State<UJobAutocompleteTagInput> createState() =>
      _UJobAutocompleteTagInputState();
}

class _UJobAutocompleteTagInputState extends State<UJobAutocompleteTagInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isCreatingTag = false;

  String _normalizeTagValue(String value) {
    return value
        .replaceFirst('__ADD_CUSTOM__', '')
        .replaceFirst('__NO_RESULTS__', '')
        .trim();
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  void _addTag(String value) {
    final text = _normalizeTagValue(value);
    if (text.isNotEmpty && !widget.tags.contains(text)) {
      final newTags = List<String>.from(widget.tags)..add(text);
      widget.onChanged(newTags);
    }
    _controller.clear();
  }

  Future<void> _handleCreateTag(String value) async {
    final text = _normalizeTagValue(value);
    if (text.isEmpty || _isCreatingTag) return;

    _controller.clear();

    if (widget.onCreateTag == null) {
      _addTag(text);
      return;
    }

    setState(() => _isCreatingTag = true);
    try {
      final createdTag = await widget.onCreateTag!(text);
      if (!mounted) return;
      if (createdTag != null && createdTag.trim().isNotEmpty) {
        _addTag(createdTag);
      }
    } finally {
      if (mounted) {
        setState(() => _isCreatingTag = false);
      }
    }
  }

  void _removeTag(String tag) {
    final newTags = List<String>.from(widget.tags)..remove(tag);
    widget.onChanged(newTags);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
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
        SizedBox(height: 6.h),
        InputDecorator(
          isFocused: _focusNode.hasFocus,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            border: OutlineInputBorder(
              borderRadius: AppRadius.md,
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.md,
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.md,
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.tags.isNotEmpty) ...[
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: widget.tags.map((tag) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tag,
                            style: AppText.small.copyWith(
                              color: AppColors.primary,
                            ),
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
              LayoutBuilder(
                builder: (context, constraints) {
                  return RawAutocomplete<String>(
                    textEditingController: _controller,
                    focusNode: _focusNode,
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      final query = textEditingValue.text.toLowerCase();
                      if (query.isEmpty) {
                        return const Iterable<String>.empty();
                      }

                      final matches = widget.suggestions
                          .where((item) => item.toLowerCase().contains(query))
                          .toList();

                      // If no exact match exists in suggestions, we'll append a "custom" option
                      final exactMatch = matches.any(
                        (item) => item.toLowerCase() == query,
                      );
                      if (matches.isEmpty && query.trim().isNotEmpty) {
                        matches.add('__NO_RESULTS__');
                      }

                      if (!exactMatch && query.trim().isNotEmpty) {
                        // We use a special prefix to identify the custom option
                        matches.add(
                          '__ADD_CUSTOM__${textEditingValue.text.trim()}',
                        );
                      }

                      return matches;
                    },
                    onSelected: (String selection) {
                      if (selection == '__NO_RESULTS__') {
                        return;
                      }
                      if (selection.startsWith('__ADD_CUSTOM__')) {
                        _handleCreateTag(
                          selection.replaceFirst('__ADD_CUSTOM__', ''),
                        );
                      } else {
                        _addTag(selection);
                      }
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onFieldSubmitted) {
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            style: AppText.bodyMedium.copyWith(
                              color: AppColors.text,
                            ),
                            decoration: InputDecoration(
                              hintText: widget.hint,
                              hintStyle: AppText.bodyMedium.copyWith(
                                color: AppColors.muted2,
                              ),
                              suffixIcon: _isCreatingTag
                                  ? Padding(
                                      padding: EdgeInsets.all(10.r),
                                      child: SizedBox(
                                        width: 16.r,
                                        height: 16.r,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              const AlwaysStoppedAnimation<Color>(
                                            AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    )
                                  : null,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onSubmitted: (value) {
                              if (value.trim().isNotEmpty) {
                                _handleCreateTag(value);
                              }
                            },
                            textInputAction: TextInputAction.done,
                          );
                        },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          margin: EdgeInsets.only(top: 8.h),
                          width: constraints.maxWidth,
                          constraints: BoxConstraints(maxHeight: 200.h),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColors.borderLight),
                            boxShadow: AppShadow.card(),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Material(
                            color: Colors.transparent,
                            child: ListView.separated(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              separatorBuilder: (context, index) => Divider(
                                height: 1,
                                color: AppColors.borderLight,
                              ),
                              itemBuilder: (context, index) {
                                final option = options.elementAt(index);
                                final isNoResults = option == '__NO_RESULTS__';
                                final isCustom = option.startsWith(
                                  '__ADD_CUSTOM__',
                                );

                                if (isNoResults) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 12.h,
                                    ),
                                    child: Text(
                                      'Skills not found',
                                      style: AppText.bodyMedium.copyWith(
                                        color: AppColors.muted,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  );
                                }

                                if (isCustom) {
                                  final customText = option.replaceFirst(
                                    '__ADD_CUSTOM__',
                                    '',
                                  );
                                  return InkWell(
                                    onTap: _isCreatingTag
                                        ? null
                                        : () => onSelected(option),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 12.h,
                                      ),
                                      child: Row(
                                        children: [
                                          HugeIcon(
                                            icon: HugeIcons.strokeRoundedAdd01,
                                            color: AppColors.primary,
                                            size: 18.r,
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            'Add "$customText"',
                                            style: AppText.bodyMedium.copyWith(
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          const Spacer(),
                                          if (_isCreatingTag)
                                            SizedBox(
                                              width: 16.r,
                                              height: 16.r,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    const AlwaysStoppedAnimation<Color>(
                                                  AppColors.primary,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                return InkWell(
                                  onTap: () => onSelected(option),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 12.h,
                                    ),
                                    child: Text(
                                      option,
                                      style: AppText.bodyMedium,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
