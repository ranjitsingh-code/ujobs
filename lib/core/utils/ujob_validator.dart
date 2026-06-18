import 'package:flutter/material.dart';
import 'l10n_extensions.dart';

class UJobValidator {
  static String? validate({
    required BuildContext context,
    required String? value,
    bool isEmail = false,
    bool isPhone = false,
    bool isPhoneOrEmail = false,
    bool isPassword = false, // strong password regex
    bool isConfirmPassword = false,
    String? matchValue, // for confirm password
    int? exactLength,
    int? minLength,
    bool isRequired = true,
  }) {
    final l10n = context.l10n;
    final val = value?.trim() ?? '';

    if (val.isEmpty) {
      if (isRequired) return l10n.errorRequiredField;
      return null;
    }

    if (isEmail) {
      if (!RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?").hasMatch(val.toLowerCase())) {
        return l10n.errorInvalidEmail;
      }
    }

    if (isPhone) {
      if (!RegExp(r"^[+]*(0|[1-9][0-9]*)$").hasMatch(val) || val.length < 8) {
        return l10n.errorInvalidPhone;
      }
    }

    if (isPhoneOrEmail) {
      final isEmailMatch = RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?").hasMatch(val.toLowerCase());
      final isPhoneMatch = RegExp(r"^[+]*(0|[1-9][0-9]*)$").hasMatch(val) && val.length >= 8;
      
      if (!isEmailMatch && !isPhoneMatch) {
        return l10n.errorInvalidPhoneOrEmail;
      }
    }

    if (isPassword) {
      // 6+ chars, 1 number, 1 uppercase, 1 lowercase, 1 special char
      if (!RegExp(r"^(?=.*[0-9])(?=.*[!@#$%^&*()_+=,.<>/?;:'\x22\x5B\x5D\x7B\x7D\x7C\x5C\x2D\x7E])(?=.*[a-z])(?=.*[A-Z]).{6,}$").hasMatch(val)) {
        return l10n.errorInvalidPassword;
      }
    }

    if (isConfirmPassword && matchValue != null) {
      if (val != matchValue) return l10n.errorPasswordMismatch;
    }

    if (exactLength != null && val.length != exactLength) {
      return 'Must be exactly $exactLength characters';
    }

    if (minLength != null && val.length < minLength) {
      return 'Must be at least $minLength characters';
    }

    return null;
  }
}
