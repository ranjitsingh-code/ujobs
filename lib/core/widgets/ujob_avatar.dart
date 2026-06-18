import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

class UJobAvatar extends StatelessWidget {
  final String? imageUrl;
  final String initials;
  final double size;

  const UJobAvatar({
    this.imageUrl,
    required this.initials,
    this.size = 40,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (_, _) => _placeholder(context),
          errorWidget: (_, _, _) => _placeholder(context),
        ),
      );
    }
    return _placeholder(context);
  }

  Widget _placeholder(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
      shape: BoxShape.circle,
    ),
    child: Center(
      child: Text(
        initials.isNotEmpty ? initials[0].toUpperCase() : '?',
        style: AppText.bodyBold.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontSize: size * 0.4,
        ),
      ),
    ),
  );
}
