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

  @override
  Widget build(BuildContext context) {
    return UJobImage(
      path: AppAssets.logo,
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }
}
