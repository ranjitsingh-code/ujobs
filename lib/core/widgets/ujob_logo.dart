import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_assets.dart';

enum LogoVariant { color, white, mark }

class UJobLogo extends StatelessWidget {
  final LogoVariant variant;
  final double? width;
  final double? height;

  const UJobLogo({
    this.variant = LogoVariant.color,
    this.width,
    this.height,
    super.key,
  });

  String get _path {
    switch (variant) {
      case LogoVariant.color:  return AppAssets.logo;
      case LogoVariant.white:  return AppAssets.logoWhite;
      case LogoVariant.mark:   return AppAssets.logoMark;
    }
  }

  bool get _isSvg => _path.endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    if (_isSvg) {
      return SvgPicture.asset(
        _path,
        width: width,
        height: height,
        fit: BoxFit.contain,
        placeholderBuilder: (_) => SizedBox(width: width, height: height, child: const Icon(Icons.broken_image)),
      );
    }

    return Image.asset(
      _path,
      width: width,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => SizedBox(width: width, height: height),
    );
  }
}
