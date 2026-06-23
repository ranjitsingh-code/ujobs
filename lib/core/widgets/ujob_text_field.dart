import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/ujob_validator.dart';

class UJobTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? errorText; // Manual error override
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final Widget? prefix;
  final Widget? suffix;
  final int maxLines;
  final int minLines;
  final bool readOnly;
  final Widget? labelTrailing;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;

  // Auto-validation parameters
  final bool isRequired;
  final bool isEmail;
  final bool isPhone;
  final bool isPhoneOrEmail;
  final bool isSecurePassword;
  final bool isConfirmPassword;
  final String? matchValue;
  final int? minLength;
  final int? exactLength;

  const UJobTextField({
    this.label = '',
    this.hint,
    this.errorText,
    this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.prefix,
    this.suffix,
    this.maxLines = 1,
    this.minLines = 1,
    this.readOnly = false,
    this.labelTrailing,
    this.onChanged,
    this.onTap,
    this.inputFormatters,
    this.isRequired = false,
    this.isEmail = false,
    this.isPhone = false,
    this.isPhoneOrEmail = false,
    this.isSecurePassword = false,
    this.isConfirmPassword = false,
    this.matchValue,
    this.minLength,
    this.exactLength,
    super.key,
  });

  @override
  State<UJobTextField> createState() => _UJobTextFieldState();
}

class _UJobTextFieldState extends State<UJobTextField> {
  bool _obscureText = true;
  String? _autoError;
  VoidCallback? _controllerListener;

  String? get _currentError => widget.errorText ?? _autoError;

  void _validate(String value) {
    if (!widget.isRequired &&
        !widget.isEmail &&
        !widget.isPhone &&
        !widget.isPhoneOrEmail &&
        !widget.isSecurePassword &&
        !widget.isConfirmPassword &&
        widget.minLength == null &&
        widget.exactLength == null) {
      return;
    }

    // Do not show errors immediately on empty fields while typing.
    // Let the parent form handle "required" checks on submit.
    if (value.isEmpty) {
      if (_autoError != null) setState(() => _autoError = null);
      return;
    }

    final err = UJobValidator.validate(
      context: context,
      value: value,
      isRequired:
          false, // Override to false here so empty doesn't trigger error mid-type
      isEmail: widget.isEmail,
      isPhone: widget.isPhone,
      isPhoneOrEmail: widget.isPhoneOrEmail,
      isPassword: widget.isSecurePassword,
      isConfirmPassword: widget.isConfirmPassword,
      matchValue: widget.matchValue,
      minLength: widget.minLength,
      exactLength: widget.exactLength,
    );

    if (_autoError != err) {
      setState(() => _autoError = err);
    }
  }

  @override
  void initState() {
    super.initState();
    _attachControllerListener();
  }

  @override
  void didUpdateWidget(covariant UJobTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _detachControllerListener(oldWidget.controller);
      _attachControllerListener();
    }
    if (widget.errorText != oldWidget.errorText ||
        widget.matchValue != oldWidget.matchValue) {
      _validate(widget.controller?.text ?? '');
    }
  }

  @override
  void dispose() {
    _detachControllerListener(widget.controller);
    super.dispose();
  }

  void _attachControllerListener() {
    final controller = widget.controller;
    if (controller == null) return;
    _controllerListener = () {
      if (!mounted) return;
      _validate(controller.text);
    };
    controller.addListener(_controllerListener!);
  }

  void _detachControllerListener(TextEditingController? controller) {
    final listener = _controllerListener;
    if (controller != null && listener != null) {
      controller.removeListener(listener);
    }
    _controllerListener = null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label,
                style: AppText.label.copyWith(color: AppColors.muted),
              ),
              if (widget.labelTrailing != null) widget.labelTrailing!,
            ],
          ),
          SizedBox(height: 6.h),
        ],
        TextField(
          controller: widget.controller,
          obscureText: widget.isPassword && _obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          minLines: widget.minLines,
          readOnly: widget.readOnly,
          onChanged: (v) {
            _validate(v);
            widget.onChanged?.call(v);
          },
          onTap: widget.onTap,
          inputFormatters: widget.inputFormatters,
          style: AppText.body.copyWith(
            color: widget.readOnly ? AppColors.muted : AppColors.text,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppText.body.copyWith(color: AppColors.muted2),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            prefixIcon: widget.prefix,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: HugeIcon(
                      icon: _obscureText
                          ? HugeIcons.strokeRoundedView
                          : HugeIcons.strokeRoundedViewOffSlash,
                      color: AppColors.muted,
                      size: 20.r,
                    ),
                    onPressed: () =>
                        setState(() => _obscureText = !_obscureText),
                  )
                : widget.suffix,
            border: OutlineInputBorder(
              borderRadius: AppRadius.md,
              borderSide: BorderSide(
                color: _currentError != null
                    ? AppColors.error
                    : AppColors.borderLight,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.md,
              borderSide: BorderSide(
                color: _currentError != null
                    ? AppColors.error
                    : AppColors.borderLight,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.md,
              borderSide: BorderSide(
                color: _currentError != null
                    ? AppColors.error
                    : AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
        if (_currentError != null) ...[
          SizedBox(height: 4.h),
          Text(
            _currentError!,
            style: AppText.small.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }
}
