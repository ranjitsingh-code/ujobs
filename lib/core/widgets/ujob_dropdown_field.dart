import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/l10n_extensions.dart';
import 'ujob_text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/countries_provider.dart';

class UJobDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final String? hint;
  final List<(String label, T value)> options;
  final ValueChanged<T?> onChanged;
  final String? errorText;
  final bool isRequired;

  const UJobDropdownField({
    required this.label,
    required this.options,
    required this.onChanged,
    this.value,
    this.hint,
    this.errorText,
    this.isRequired = false,
    super.key,
  });

  /// Factory for backward compatibility
  factory UJobDropdownField.simple({
    required String label,
    required List<(String label, T value)> options,
    required ValueChanged<T?> onChanged,
    T? value,
    String? hint,
    String? errorText,
    Key? key,
  }) {
    return UJobDropdownField(
      key: key,
      label: label,
      options: options,
      onChanged: onChanged,
      value: value,
      hint: hint,
      errorText: errorText,
    );
  }

  void _showSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        return _SearchableDropdownSheet<T>(
          label: label,
          options: options,
          selectedValue: value,
          onSelected: (val) {
            onChanged(val);
            Navigator.pop(ctx);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedLabel = options.where((e) => e.$2 == value).firstOrNull?.$1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: AppText.label.copyWith(color: AppColors.muted),
            children: [
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: AppText.label.copyWith(color: AppColors.error),
                ),
            ],
          ),
        ),
        SizedBox(height: 6.h),
        GestureDetector(
          onTap: () => _showSelectionSheet(context),
          child: Container(
            height: 52.h,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: errorText != null
                    ? AppColors.error
                    : AppColors.borderLight,
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    selectedLabel ?? hint ?? context.l10n.selectPlaceholder,
                    style: AppText.body.copyWith(
                      color: selectedLabel != null
                          ? AppColors.text
                          : AppColors.muted2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowDown01,
                  color: AppColors.muted,
                  size: 20.r,
                ),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          SizedBox(height: 6.h),
          Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: Text(
              errorText!,
              style: AppText.small.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ],
    );
  }
}

class _SearchableDropdownSheet<T> extends StatefulWidget {
  final String label;
  final List<(String label, T value)> options;
  final T? selectedValue;
  final ValueChanged<T> onSelected;

  const _SearchableDropdownSheet({
    required this.label,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  State<_SearchableDropdownSheet<T>> createState() =>
      _SearchableDropdownSheetState<T>();
}

class _SearchableDropdownSheetState<T>
    extends State<_SearchableDropdownSheet<T>> {
  late TextEditingController _searchController;
  late List<(String label, T value)> _filteredOptions;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredOptions = widget.options;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filteredOptions = widget.options
          .where((e) => e.$1.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.label, style: AppText.heading3),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedCancel01,
                  color: AppColors.text,
                  size: 24.r,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          UJobTextField(
            label: '',
            hint: context.l10n.search,
            controller: _searchController,
            onChanged: _onSearchChanged,
            prefix: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedSearch01,
                color: AppColors.muted,
                size: 20.r,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: ListView.separated(
              itemCount: _filteredOptions.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 1, color: AppColors.borderLight),
              itemBuilder: (context, index) {
                final option = _filteredOptions[index];
                final isSelected = option.$2 == widget.selectedValue;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    option.$1,
                    style: AppText.body.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.text,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                  trailing: isSelected
                      ? HugeIcon(
                          icon: HugeIcons.strokeRoundedTick02,
                          color: AppColors.primary,
                          size: 20.r,
                        )
                      : null,
                  onTap: () => widget.onSelected(option.$2),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UJobCountryDropdown extends ConsumerWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  final String? errorText;
  final bool isRequired;

  const UJobCountryDropdown({
    required this.onChanged,
    this.value,
    this.errorText,
    this.isRequired = false,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final countriesAsync = ref.watch(countriesProvider);

    return countriesAsync.when(
      data: (countries) {
        return UJobDropdownField<String>(
          label: l10n.country,
          hint: l10n.countryHint,
          isRequired: isRequired,
          value: value,
          errorText: errorText,
          onChanged: onChanged,
          options: countries
              .map((c) => ('${c.flag} ${c.name}', c.iso2))
              .toList(),
        );
      },
      loading: () => UJobDropdownField<String>(
        label: l10n.country,
        hint: 'Loading countries...',
        value: value,
        errorText: errorText,
        onChanged: onChanged,
        options: const [],
      ),
      error: (_, _) => UJobDropdownField<String>(
        label: l10n.country,
        hint: 'Failed to load countries',
        value: value,
        errorText: errorText,
        onChanged: onChanged,
        options: const [],
      ),
    );
  }
}
