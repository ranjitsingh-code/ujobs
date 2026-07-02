import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class UJobOtpField extends StatefulWidget {
  final int length;
  final bool autofocus;
  final bool hasError;
  final bool enabled;
  final String? semanticLabel;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  const UJobOtpField({
    this.length = 6,
    this.autofocus = true,
    this.hasError = false,
    this.enabled = true,
    this.semanticLabel,
    this.onChanged,
    this.onCompleted,
    super.key,
  });

  @override
  State<UJobOtpField> createState() => _UJobOtpFieldState();
}

class _UJobOtpFieldState extends State<UJobOtpField>
    with SingleTickerProviderStateMixin {
  late final PinInputController _pinController;
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _pinController = PinInputController();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0, end: -8), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 8, end: -4), weight: 2),
          TweenSequenceItem(tween: Tween(begin: -4, end: 0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
        );

    if (widget.hasError) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _triggerError());
    }
  }

  @override
  void didUpdateWidget(covariant UJobOtpField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasError && !oldWidget.hasError) {
      _triggerError();
    }
  }

  void _triggerError() {
    if (mounted) {
      _shakeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PinInput(
    length: widget.length,
    pinController: _pinController,
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    autoFocus: widget.autofocus,
    enabled: widget.enabled,
    autoDismissKeyboard: false,
    enablePaste: true,
    enableAutofill: true,
    autofillHints: const [AutofillHints.oneTimeCode],
    semanticLabel: widget.semanticLabel,
    onChanged: widget.onChanged,
    onCompleted: widget.onCompleted,
    builder: (context, cells) => AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) => Transform.translate(
        offset: Offset(_shakeAnimation.value, 0),
        child: child,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: cells
            .map(
              (cell) => _OtpCell(
                character: cell.character,
                isFocused: cell.isFocused,
                hasError: widget.hasError,
              ),
            )
            .toList(),
      ),
    ),
  );
}

class _OtpCell extends StatelessWidget {
  final String? character;
  final bool isFocused;
  final bool hasError;

  const _OtpCell({
    required this.character,
    required this.isFocused,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = character?.isNotEmpty ?? false;

    return Container(
      width: 50.r,
      height: 60.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: hasError
            ? AppColors.errorBg
            : hasValue
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.bg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: hasError
              ? AppColors.error
              : isFocused
              ? AppColors.primary
              : AppColors.border,
          width: isFocused ? 2 : 1.5,
        ),
      ),
      child: hasValue
          ? Text(
              character!,
              style: AppText.heading2.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w700,
              ),
            )
          : isFocused
          ? CursorBlink(color: AppColors.primary, width: 2.r, height: 26.h)
          : null,
    );
  }
}
