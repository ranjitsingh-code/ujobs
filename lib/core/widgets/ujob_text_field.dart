import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class UJobTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final bool obscure;
  final bool isPassword;
  final bool readOnly;
  final int maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;

  const UJobTextField({
    required this.label,
    this.hint,
    this.controller,
    this.errorText,
    this.obscure = false,
    this.isPassword = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.keyboardType,
    this.onChanged,
    this.suffixIcon,
    this.prefixIcon,
    this.textInputAction,
    this.focusNode,
    this.validator,
    super.key,
  });

  @override
  State<UJobTextField> createState() => _UJobTextFieldState();
}

class _UJobTextFieldState extends State<UJobTextField> {
  late final FocusNode _internalFocusNode;
  bool _isFocused = false;
  bool _obscured = true;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscure || widget.isPassword;
    _internalFocusNode = widget.focusNode ?? FocusNode();
    _internalFocusNode.addListener(() {
      setState(() => _isFocused = _internalFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _internalFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    Widget? suffix = widget.suffixIcon;
    if (widget.isPassword && suffix == null) {
      suffix = GestureDetector(
        onTap: () => setState(() => _obscured = !_obscured),
        child: Padding(
          padding: EdgeInsets.all(12.r),
          child: HugeIcon(
            icon: _obscured ? HugeIcons.strokeRoundedViewOffSlash : HugeIcons.strokeRoundedView,
            size: 20.r,
            color: AppColors.muted,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 6.h),
          child: Text(
            widget.label,
            style: AppText.label.copyWith(
              color: _isFocused ? primaryColor : AppColors.text,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscured,
          readOnly: widget.readOnly,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          keyboardType: widget.keyboardType,
          onChanged: widget.onChanged,
          focusNode: _internalFocusNode,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          style: AppText.bodyMd,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppText.bodyMd.copyWith(color: AppColors.muted2),
            errorText: widget.errorText,
            suffixIcon: suffix,
            prefixIcon: widget.prefixIcon,
            filled: true,
            fillColor: AppColors.surface,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: primaryColor, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}
