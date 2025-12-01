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

    // Calculate a cache size to avoid decoding the full-resolution image on
    // the UI thread when a smaller display size is requested. This helps on
    // low-memory or resource-constrained devices where decoding a large PNG
    // can cause jank (skipped frames) or OOM errors.
    final double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    // Guard against infinite dimensions (e.g. width: double.infinity) which
    // would produce Infinity when multiplied by devicePixelRatio and throw
    // UnsupportedError when rounded/toInt is invoked. Only compute cache
    // sizes when the provided width/height are finite numbers.
    final int? cacheW = (width != null && width!.isFinite)
        ? (width! * devicePixelRatio).round()
        : null;
    final int? cacheH = (height != null && height!.isFinite)
        ? (height! * devicePixelRatio).round()
        : null;

    final img = Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      semanticLabel: semanticLabel,
      // Pass cacheWidth/cacheHeight so Flutter can decode a downscaled
      // image into memory which is much faster and far less memory-heavy.
      cacheWidth: cacheW,
      cacheHeight: cacheH,
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
