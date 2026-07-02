import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/l10n_extensions.dart';
import 'ujob_text_field.dart';
import '../models/country.dart';

class UJobPhoneNumberField extends StatefulWidget {
  final String label;
  final bool isRequired;
  final List<Country>? countries;
  final TextEditingController controller;
  final String initialDialCode;
  final ValueChanged<String?>? onCountryCodeChanged;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final String? hint;

  const UJobPhoneNumberField({
    required this.label,
    this.isRequired = false,
    this.countries,
    required this.controller,
    this.initialDialCode = '+44',
    this.onCountryCodeChanged,
    this.onChanged,
    this.errorText,
    this.hint,
    super.key,
  });

  @override
  State<UJobPhoneNumberField> createState() => _UJobPhoneNumberFieldState();
}

class _UJobPhoneNumberFieldState extends State<UJobPhoneNumberField> {
  late Country _selected;
  final _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    final fallback = Country(
      id: 0,
      name: 'United Kingdom',
      iso2: 'GB',
      phoneCode: '44',
      flag: '🇬🇧',
    );
    final active = widget.countries != null && widget.countries!.isNotEmpty
        ? widget.countries!
        : [fallback];

    String norm = widget.initialDialCode;
    if (!norm.startsWith('+')) norm = '+$norm';

    _selected = active.firstWhere((c) {
      final cDial = c.phoneCode.startsWith('+')
          ? c.phoneCode
          : '+${c.phoneCode}';
      return cDial == norm;
    }, orElse: () => active.first);
    _focusNode.addListener(() {
      if (mounted) setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void didUpdateWidget(UJobPhoneNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDialCode != oldWidget.initialDialCode ||
        widget.countries != oldWidget.countries) {
      final fallback = Country(
        id: 0,
        name: 'United Kingdom',
        iso2: 'GB',
        phoneCode: '44',
        flag: '🇬🇧',
      );
      final active = widget.countries != null && widget.countries!.isNotEmpty
          ? widget.countries!
          : [fallback];

      String norm = widget.initialDialCode;
      if (!norm.startsWith('+')) norm = '+$norm';

      setState(() {
        _selected = active.firstWhere((c) {
          final cDial = c.phoneCode.startsWith('+')
              ? c.phoneCode
              : '+${c.phoneCode}';
          return cDial == norm;
        }, orElse: () => _selected);
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _showCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) => _CountryPickerSheet(
        countries: widget.countries != null && widget.countries!.isNotEmpty
            ? widget.countries!
            : [
                Country(
                  id: 0,
                  name: 'United Kingdom',
                  iso2: 'GB',
                  phoneCode: '44',
                  flag: '🇬🇧',
                ),
              ],
        selected: _selected,
        onSelect: (country) {
          setState(() => _selected = country);
          widget.onCountryCodeChanged?.call(
            (country.phoneCode.startsWith('+')
                ? country.phoneCode
                : '+${country.phoneCode}'),
          );
          Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty) ...[
          RichText(
            text: TextSpan(
              text: widget.label,
              style: AppText.label.copyWith(color: AppColors.muted),
              children: [
                if (widget.isRequired)
                  TextSpan(
                    text: ' *',
                    style: AppText.label.copyWith(color: AppColors.error),
                  ),
              ],
            ),
          ),
          SizedBox(height: 6.h),
        ],
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.md,
            border: Border.all(
              color: hasError
                  ? AppColors.error
                  : _focused
                  ? AppColors.primary
                  : AppColors.borderLight,
              width: _focused ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Country code prefix — tappable
              GestureDetector(
                onTap: () => _showCountryPicker(context),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 14.h,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        (_selected.phoneCode.startsWith('+')
                            ? _selected.phoneCode
                            : '+${_selected.phoneCode}'),
                        style: AppText.bodyBold.copyWith(color: AppColors.text),
                      ),
                      SizedBox(width: 4.w),
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowDown01,
                        color: AppColors.muted,
                        size: 16.r,
                      ),
                    ],
                  ),
                ),
              ),
              // Divider
              Container(width: 1, height: 24.h, color: AppColors.borderLight),
              // Number input
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: AppText.body.copyWith(color: AppColors.text),
                  onChanged: widget.onChanged,
                  decoration: InputDecoration(
                    hintText: widget.hint ?? l10n.localPhoneNumberHint,
                    hintStyle: AppText.body.copyWith(color: AppColors.muted2),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 14.h,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasError) ...[
          SizedBox(height: 4.h),
          Text(
            widget.errorText!,
            style: AppText.small.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }
}

class _CountryPickerSheet extends StatefulWidget {
  final List<Country> countries;
  final Country selected;
  final ValueChanged<Country> onSelect;

  const _CountryPickerSheet({
    required this.countries,
    required this.selected,
    required this.onSelect,
  });

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final _searchCtrl = TextEditingController();
  late List<Country> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = widget.countries;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String q) {
    final query = q.toLowerCase();
    setState(() {
      _filtered = widget.countries
          .where(
            (c) =>
                c.name.toLowerCase().contains(query) ||
                (c.phoneCode.startsWith('+') ? c.phoneCode : '+${c.phoneCode}')
                    .contains(query),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.countryCode, style: AppText.heading3),
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
          SizedBox(height: 12.h),
          UJobTextField(
            label: '',
            hint: l10n.search,
            controller: _searchCtrl,
            onChanged: _onSearch,
            prefix: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedSearch01,
                color: AppColors.muted,
                size: 20.r,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: ListView.separated(
              itemCount: _filtered.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 1, color: AppColors.borderLight),
              itemBuilder: (_, i) {
                final c = _filtered[i];
                final isSelected = c.name == widget.selected.name;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Text(c.flag, style: TextStyle(fontSize: 24.sp)),
                  title: Text(
                    c.name,
                    style: AppText.body.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.text,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                  trailing: Text(
                    (c.phoneCode.startsWith('+')
                        ? c.phoneCode
                        : '+${c.phoneCode}'),
                    style: AppText.body.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.muted,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                  onTap: () => widget.onSelect(c),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
