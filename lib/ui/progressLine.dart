// lib/ui/progressLine.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:application/ui/theme.dart'; // for context.palette

class ProgressLine extends HookWidget {
  /// Zero-based current page index.
  final int currentPage;

  /// Total number of pages/segments. Must be > 0.
  final int totalPages;

  /// Logical bar height (scaled with .h).
  final double height;

  /// Horizontal padding on both sides of the bar (logical; scaled with .w).
  /// Use this to match your previous "page" padding if needed.
  final double horizontalPadding;

  /// (Kept for backward-compat; not used since track is removed.)
  final Color? backgroundLineColor;

  /// Active progress segment color (defaults to brand gold).
  final Color? progressColor;

  /// Dot color (inactive page markers).
  final Color? dotColor;

  /// Animation duration for progress slide and dot fade.
  final Duration animDuration;

  const ProgressLine({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.height = 4,
    this.horizontalPadding = 0,
    this.backgroundLineColor, // retained for API compatibility
    this.progressColor,
    this.dotColor,
    this.animDuration = const Duration(milliseconds: 300),
  })  : assert(totalPages > 0, 'totalPages must be > 0'),
        assert(currentPage >= 0, 'currentPage must be >= 0');

  @override
  Widget build(BuildContext context) {
    final int page = currentPage.clamp(0, totalPages - 1);

    // Anim pieces
    final prevPage = usePrevious(page);
    final controller = useAnimationController(duration: animDuration);

    final fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );

    final showNewDots = useState(false);
    final displayedPage = useState(prevPage ?? page);

    // Re-run fade when page changes (with 200ms dot delay to match original feel).
    useEffect(() {
      showNewDots.value = false;
      displayedPage.value = prevPage ?? page;

      final timer = Timer(const Duration(milliseconds: 200), () {
        showNewDots.value = true;
        displayedPage.value = page;
        controller.forward(from: 0);
      });

      return timer.cancel;
    }, [page]);

    // Colors
    final Color segColor = progressColor ?? context.palette.goldenTan; // GOLD ✔
    final Color dColor = dotColor ?? Palette.gray;

    // Dot builder
    List<Widget> buildDots(int count) => List.generate(
          count,
          (_) => Container(
            margin: EdgeInsets.symmetric(horizontal: 2.w),
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: dColor,
              shape: BoxShape.circle,
            ),
          ),
        );

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth =
            (constraints.maxWidth.isFinite ? constraints.maxWidth : MediaQuery.sizeOf(context).width) -
                2 * horizontalPadding.w;

        final double safeWidth = availableWidth > 0 ? availableWidth : 0;

        // Geometry
        final double segmentWidth = safeWidth / totalPages;
        final double barLeft = segmentWidth * page;
        final double barTop = 12.h;
        final double dotTop = barTop + (height.h / 2) - (6.w / 2);

        return SizedBox(
          height: height.h + 24.h, // same vertical footprint as before
          width: constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : safeWidth + 2 * horizontalPadding.w,
          child: Stack(
            children: [
              // 🔕 No background track/path (removed by design).

              // 🔶 Golden segment that slides between page slots.
              AnimatedPositioned(
                duration: animDuration,
                curve: Curves.easeInOut,
                top: barTop,
                left: horizontalPadding.w + barLeft,
                child: Container(
                  width: segmentWidth,
                  height: height.h,
                  decoration: BoxDecoration(
                    color: segColor,
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                ),
              ),

              // 🟢 Dots remain (fade in after 200ms).
              if (showNewDots.value) ...[
                // Left side dots = pages already passed
                Positioned(
                  top: dotTop,
                  left: horizontalPadding.w + barLeft - (page * 10.w),
                  child: FadeTransition(
                    opacity: fadeIn,
                    child: Row(children: buildDots(page)),
                  ),
                ),
                // Right side dots = pages yet to come
                Positioned(
                  top: dotTop,
                  left: horizontalPadding.w + barLeft + segmentWidth + 2.w,
                  child: FadeTransition(
                    opacity: fadeIn,
                    child: Row(children: buildDots(totalPages - page - 1)),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
