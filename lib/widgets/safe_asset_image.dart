import 'package:flutter/material.dart';

/// SafeAssetImage loads an asset image but shows a graceful placeholder
/// (an icon on a dark background) when the asset can't be found.
class SafeAssetImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? semanticLabel;
  final bool circle;
  final BorderRadius? borderRadius;

  const SafeAssetImage(
    this.path, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.semanticLabel,
    this.circle = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF1F2130),
        borderRadius:
            borderRadius ?? (circle ? null : BorderRadius.circular(8)),
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
      ),
      child: const Icon(Icons.image_not_supported, color: Colors.white54),
    );

    final img = Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      semanticLabel: semanticLabel,
      errorBuilder: (context, error, stackTrace) => placeholder,
    );

    if (circle) {
      return ClipOval(child: img);
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: img);
    }

    return img;
  }
}
