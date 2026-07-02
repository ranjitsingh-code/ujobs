import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import '../utils/l10n_extensions.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/skill.dart';

class UJobSkillAutocomplete extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isRequired;
  final List<Skill> availableSkills;
  final ValueChanged<Skill?>? onSkillSelected;
  final Future<Skill?> Function(String name)? onCreateSkill;
  final bool allowCreateWhenMissing;

  const UJobSkillAutocomplete({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.availableSkills,
    this.isRequired = false,
    this.onSkillSelected,
    this.onCreateSkill,
    this.allowCreateWhenMissing = false,
  });

  @override
  ConsumerState<UJobSkillAutocomplete> createState() =>
      _UJobSkillAutocompleteState();
}

class _UJobSkillAutocompleteState extends ConsumerState<UJobSkillAutocomplete> {
  final FocusNode _focusNode = FocusNode();
  bool _isCreatingSkill = false;

  Iterable<Skill> _search(String query) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return const Iterable<Skill>.empty();
    }
    final normalizedQuery = trimmedQuery.toLowerCase();
    final skills = widget.availableSkills
        .where((skill) => skill.name.toLowerCase().contains(normalizedQuery))
        .take(10)
        .toList();
    final hasExactMatch = widget.availableSkills.any(
      (skill) => skill.name.trim().toLowerCase() == normalizedQuery,
    );

    if (skills.isEmpty) {
      return [
        const Skill(id: -1, name: 'NO_SKILL_FOUND'),
        if (widget.allowCreateWhenMissing) Skill(id: -2, name: trimmedQuery),
      ];
    }

    if (widget.allowCreateWhenMissing && !hasExactMatch) {
      skills.add(Skill(id: -2, name: trimmedQuery));
    }

    return skills;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label,
              style: AppText.label.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.isRequired)
              Text(
                ' *',
                style: AppText.label.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        LayoutBuilder(
          builder: (context, constraints) {
            return RawAutocomplete<Skill>(
              textEditingController: widget.controller,
              focusNode: _focusNode,
              displayStringForOption: (Skill option) => option.name,
              fieldViewBuilder:
                  (
                    BuildContext context,
                    TextEditingController textEditingController,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted,
                  ) {
                    return TextFormField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      onFieldSubmitted: (String value) {
                        onFieldSubmitted();
                      },
                      textInputAction: TextInputAction.next,
                      style: AppText.body.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.hint,
                        hintStyle: AppText.body.copyWith(
                          color: AppColors.muted,
                          fontWeight: FontWeight.w400,
                        ),
                        filled: true,
                        fillColor: AppColors.bg,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        suffixIcon: _isCreatingSkill
                            ? UnconstrainedBox(
                                child: SizedBox(
                                  width: 16.r,
                                  height: 16.r,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primary,
                                    ),
                                  ),
                                ),
                              )
                            : null,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide(color: AppColors.error),
                        ),
                      ),
                    );
                  },
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (widget.onSkillSelected != null) {
                  widget.onSkillSelected!(null);
                }
                return _search(textEditingValue.text);
              },
              onSelected: (Skill selection) {
                if (widget.onSkillSelected != null) {
                  widget.onSkillSelected!(selection);
                }
              },
              optionsViewBuilder:
                  (
                    BuildContext context,
                    AutocompleteOnSelected<Skill> onSelected,
                    Iterable<Skill> options,
                  ) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4.0,
                        borderRadius: BorderRadius.circular(12.r),
                        color: AppColors.surface,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: 200.h,
                            maxWidth: constraints.maxWidth,
                          ),
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            separatorBuilder: (context, index) =>
                                Divider(height: 1, color: AppColors.border),
                            itemBuilder: (BuildContext context, int index) {
                              final Skill option = options.elementAt(index);

                              if (option.id == -1 &&
                                  option.name == 'NO_SKILL_FOUND') {
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 16.h,
                                  ),
                                  child: Text(
                                    context.l10n.skillsNotFound,
                                    style: AppText.body.copyWith(
                                      color: AppColors.muted,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                );
                              }

                              if (option.id == -2) {
                                return InkWell(
                                  onTap:
                                      _isCreatingSkill ||
                                          widget.onCreateSkill == null
                                      ? null
                                      : () async {
                                          setState(
                                            () => _isCreatingSkill = true,
                                          );
                                          try {
                                            final createdSkill = await widget
                                                .onCreateSkill!(option.name);
                                            if (createdSkill != null &&
                                                mounted) {
                                              widget.controller.text =
                                                  createdSkill.name;
                                              widget.onSkillSelected?.call(
                                                createdSkill,
                                              );
                                              _focusNode.unfocus();
                                            }
                                          } finally {
                                            if (mounted) {
                                              setState(
                                                () => _isCreatingSkill = false,
                                              );
                                            }
                                          }
                                        },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 12.h,
                                    ),
                                    child: Row(
                                      children: [
                                        HugeIcon(
                                          icon:
                                              HugeIcons.strokeRoundedAddCircle,
                                          size: 20.r,
                                          color: AppColors.primary,
                                        ),
                                        SizedBox(width: 12.w),
                                        Expanded(
                                          child: Text(
                                            context.l10n.addSkillOption(
                                              option.name,
                                            ),
                                            style: AppText.body.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        if (_isCreatingSkill)
                                          SizedBox(
                                            width: 16.r,
                                            height: 16.r,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
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
                                onTap: () {
                                  onSelected(option);
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 12.h,
                                  ),
                                  child: Row(
                                    children: [
                                      HugeIcon(
                                        icon:
                                            HugeIcons.strokeRoundedBriefcase01,
                                        size: 20.r,
                                        color: AppColors.muted,
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: Text(
                                          option.name,
                                          style: AppText.body.copyWith(
                                            color: AppColors.text,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
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
    );
  }
}
