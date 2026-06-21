import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/app_colors.dart';

class UJobImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const UJobImage({
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.color,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    super.key,
  });

  bool get _isNetwork => path.startsWith('http');
  bool get _isSvg => path.endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (_isSvg) {
      child = _buildSvg();
    } else if (_isNetwork) {
      child = _buildNetwork();
    } else {
      child = _buildAsset();
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }

  Widget _buildSvg() {
    if (_isNetwork) {
      return SvgPicture.network(
        path,
        width: width,
        height: height,
        fit: fit,
        colorFilter: color != null
            ? ColorFilter.mode(color!, BlendMode.srcIn)
            : null,
        placeholderBuilder: (_) => placeholder ?? _defaultPlaceholder(),
      );
    }
    return SvgPicture.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }

  Widget _buildNetwork() {
    return CachedNetworkImage(
      imageUrl: path,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, _) => placeholder ?? _defaultPlaceholder(),
      errorWidget: (_, _, _) => errorWidget ?? _defaultError(),
    );
  }

  Widget _buildAsset() {
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      color: color,
      errorBuilder: (_, _, _) => errorWidget ?? _defaultError(),
    );
  }

  Widget _defaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.borderLight,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Center(
        child: SizedBox(
          width: 20.r,
          height: 20.r,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.muted2,
          ),
        ),
      ),
    );
  }

  Widget _defaultError() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.borderLight,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: HugeIcon(
        icon: HugeIcons.strokeRoundedImageNotFound01,
        color: AppColors.muted2,
        size: 24.r,
      ),
    );
  }
}
