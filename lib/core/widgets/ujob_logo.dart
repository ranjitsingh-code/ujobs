import 'package:flutter/material.dart';
import '../constants/app_assets.dart';
import 'ujob_image.dart';

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
      case LogoVariant.color:
        return AppAssets.logo;
      case LogoVariant.white:
        return AppAssets.logoWhite;
      case LogoVariant.mark:
        return AppAssets.logoMark;
    }
  }

  @override
  Widget build(BuildContext context) {
    return UJobImage(
      path: _path,
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }
}
