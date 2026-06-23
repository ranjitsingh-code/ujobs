import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/l10n_extensions.dart';
import 'ujob_text_field.dart';

class _Country {
  final String name;
  final String dialCode;
  final String flag;
  const _Country(this.name, this.dialCode, this.flag);
}

const _kCountries = [
  _Country('United Kingdom', '+44', '🇬🇧'),
  _Country('Ireland', '+353', '🇮🇪'),
  _Country('United States', '+1', '🇺🇸'),
  _Country('Canada', '+1', '🇨🇦'),
  _Country('United Arab Emirates', '+971', '🇦🇪'),
  _Country('Saudi Arabia', '+966', '🇸🇦'),
  _Country('Qatar', '+974', '🇶🇦'),
  _Country('Kuwait', '+965', '🇰🇼'),
  _Country('Bahrain', '+973', '🇧🇭'),
  _Country('Oman', '+968', '🇴🇲'),
  _Country('Egypt', '+20', '🇪🇬'),
  _Country('Jordan', '+962', '🇯🇴'),
  _Country('Lebanon', '+961', '🇱🇧'),
  _Country('Iraq', '+964', '🇮🇶'),
  _Country('Turkey', '+90', '🇹🇷'),
  _Country('India', '+91', '🇮🇳'),
  _Country('Pakistan', '+92', '🇵🇰'),
  _Country('Bangladesh', '+880', '🇧🇩'),
  _Country('Sri Lanka', '+94', '🇱🇰'),
  _Country('Philippines', '+63', '🇵🇭'),
  _Country('Singapore', '+65', '🇸🇬'),
  _Country('Malaysia', '+60', '🇲🇾'),
  _Country('Indonesia', '+62', '🇮🇩'),
  _Country('Australia', '+61', '🇦🇺'),
  _Country('New Zealand', '+64', '🇳🇿'),
  _Country('Nigeria', '+234', '🇳🇬'),
  _Country('Ghana', '+233', '🇬🇭'),
  _Country('Kenya', '+254', '🇰🇪'),
  _Country('South Africa', '+27', '🇿🇦'),
  _Country('Ethiopia', '+251', '🇪🇹'),
  _Country('Germany', '+49', '🇩🇪'),
  _Country('France', '+33', '🇫🇷'),
  _Country('Italy', '+39', '🇮🇹'),
  _Country('Spain', '+34', '🇪🇸'),
  _Country('Netherlands', '+31', '🇳🇱'),
  _Country('Belgium', '+32', '🇧🇪'),
  _Country('Portugal', '+351', '🇵🇹'),
  _Country('Poland', '+48', '🇵🇱'),
  _Country('Sweden', '+46', '🇸🇪'),
  _Country('Norway', '+47', '🇳🇴'),
  _Country('Denmark', '+45', '🇩🇰'),
  _Country('Finland', '+358', '🇫🇮'),
  _Country('Switzerland', '+41', '🇨🇭'),
  _Country('Brazil', '+55', '🇧🇷'),
  _Country('Mexico', '+52', '🇲🇽'),
  _Country('Argentina', '+54', '🇦🇷'),
  _Country('China', '+86', '🇨🇳'),
  _Country('Japan', '+81', '🇯🇵'),
  _Country('South Korea', '+82', '🇰🇷'),
];

class UJobPhoneNumberField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String initialDialCode;
  final ValueChanged<String?>? onCountryCodeChanged;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final String? hint;

  const UJobPhoneNumberField({
    required this.label,
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
  late _Country _selected;
  final _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _selected = _kCountries.firstWhere(
      (c) => c.dialCode == widget.initialDialCode,
      orElse: () => _kCountries.first,
    );
    _focusNode.addListener(() {
      if (mounted) setState(() => _focused = _focusNode.hasFocus);
    });
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
        selected: _selected,
        onSelect: (country) {
          setState(() => _selected = country);
          widget.onCountryCodeChanged?.call(country.dialCode);
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
          Text(widget.label, style: AppText.label.copyWith(color: AppColors.muted)),
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
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_selected.flag, style: TextStyle(fontSize: 18.sp)),
                      SizedBox(width: 6.w),
                      Text(
                        _selected.dialCode,
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
  final _Country selected;
  final ValueChanged<_Country> onSelect;

  const _CountryPickerSheet({
    required this.selected,
    required this.onSelect,
  });

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final _searchCtrl = TextEditingController();
  List<_Country> _filtered = _kCountries;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String q) {
    final query = q.toLowerCase();
    setState(() {
      _filtered = _kCountries
          .where((c) =>
              c.name.toLowerCase().contains(query) ||
              c.dialCode.contains(query))
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
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  trailing: Text(
                    c.dialCode,
                    style: AppText.body.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.muted,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
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
