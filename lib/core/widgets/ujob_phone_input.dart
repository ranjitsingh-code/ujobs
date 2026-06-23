import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../providers/countries_provider.dart';
import '../models/country.dart';

class UJobPhoneInput extends ConsumerStatefulWidget {
  final String label;
  final String hint;
  final TextEditingController phoneController;
  final Function(Country?) onCountryCodeChanged;
  final Country? initialCountry;
  final bool isRequired;

  const UJobPhoneInput({
    Key? key,
    required this.label,
    required this.hint,
    required this.phoneController,
    required this.onCountryCodeChanged,
    this.initialCountry,
    this.isRequired = false,
  }) : super(key: key);

  @override
  ConsumerState<UJobPhoneInput> createState() => _UJobPhoneInputState();
}

class _UJobPhoneInputState extends ConsumerState<UJobPhoneInput> {
  Country? _selectedCountry;

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.initialCountry;
  }

  @override
  Widget build(BuildContext context) {
    final countriesAsync = ref.watch(countriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label,
              style: AppText.bodyBold.copyWith(color: AppColors.text),
            ),
            if (widget.isRequired)
              Text(
                ' *',
                style: AppText.bodyBold.copyWith(color: AppColors.error),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Country Code Dropdown
            Container(
              height: 52.h,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border),
              ),
              child: countriesAsync.when(
                data: (countries) {
                  // Fallback to first if none selected
                  if (_selectedCountry == null && countries.isNotEmpty) {
                    _selectedCountry = countries.firstWhere(
                      (c) => c.iso2 == 'GB',
                      orElse: () => countries.first,
                    );
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      widget.onCountryCodeChanged(_selectedCountry);
                    });
                  }
                  
                  return DropdownButtonHideUnderline(
                    child: DropdownButton<Country>(
                      value: _selectedCountry,
                      icon: Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowDown01,
                          color: AppColors.muted,
                          size: 16.r,
                        ),
                      ),
                      dropdownColor: AppColors.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      items: countries.map((c) {
                        return DropdownMenuItem<Country>(
                          value: c,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: Row(
                              children: [
                                Text(c.flag, style: TextStyle(fontSize: 16.sp)),
                                SizedBox(width: 8.w),
                                Text(c.phoneCode, style: AppText.body),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => _selectedCountry = val);
                        widget.onCountryCodeChanged(val);
                      },
                    ),
                  );
                },
                loading: () => Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: SizedBox(
                      width: 16.r,
                      height: 16.r,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.seekPrimary),
                    ),
                  ),
                ),
                error: (_, __) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Center(child: Text('Err')),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            // Phone Number Input
            Expanded(
              child: TextFormField(
                controller: widget.phoneController,
                keyboardType: TextInputType.phone,
                style: AppText.body.copyWith(color: AppColors.text),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: AppText.body.copyWith(color: AppColors.muted),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.seekPrimary),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
