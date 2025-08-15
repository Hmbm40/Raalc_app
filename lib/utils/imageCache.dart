import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Decode close to device target width to reduce upload bytes.
/// Use this with `Image.asset(..., cacheWidth: targetCacheWidth(context))`.
int targetCacheWidth(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  final dpr  = MediaQuery.devicePixelRatioOf(context);
  // If the image fills width (e.g., BoxFit.cover), width is the right target.
  return math.max(1, (size.width * dpr).round());
}

/// Precache current and neighbor images (bounds-checked).
Future<void> precacheAround(
  BuildContext context, {
  required int index,
  required List<String> assetPaths,
}) async {
  final candidates = <int>{index, index - 1, index + 1}
      .where((i) => i >= 0 && i < assetPaths.length);
  for (final i in candidates) {
    await precacheImage(AssetImage(assetPaths[i]), context);
  }
}
