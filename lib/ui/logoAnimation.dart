// lib/ui/headerAnimation.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class HeaderAnimation extends HookWidget {
  final String assetPath;

  /// Max logical size (scaled with ScreenUtil).
  final double maxHeight;
  final double maxWidth;

  /// Visual scale applied via Transform.scale.
  final double scale;

  /// Start the animation after this delay.
  final Duration delayBeforeStart;

  /// After completing, wait this long before replaying.
  final Duration restartDelay;

  /// If true, the animation replays after [restartDelay].
  final bool loopWithPause;

  /// Respect system "reduce motion" (turn animation off and show a still frame).
  final bool respectReducedMotion;

  /// Lottie layout controls (do not change defaults to preserve current look).
  final BoxFit fit;
  final AlignmentGeometry alignment;

  /// Accessibility label for screen readers.
  final String? semanticsLabel;

  const HeaderAnimation({
    super.key,
    required this.assetPath,
    this.maxHeight = 1000,
    this.maxWidth = 1000,
    this.scale = 7.0,
    this.delayBeforeStart = const Duration(seconds: 1),
    this.restartDelay = const Duration(seconds: 6),
    this.loopWithPause = true,
    this.respectReducedMotion = true,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.semanticsLabel,
  }) : assert(scale > 0, 'scale must be > 0');

  @override
  Widget build(BuildContext context) {
    // Hooks: controller is auto-disposed; don’t dispose manually.
    final controller = useAnimationController();

    // Stable timer refs to cancel on unmount.
    final startTimerRef = useRef<Timer?>(null);
    final restartTimerRef = useRef<Timer?>(null);

    // Reduced motion check
    final disableAnimations =
        respectReducedMotion && MediaQuery.maybeOf(context)?.disableAnimations == true;

    useEffect(() {
      if (disableAnimations) {
        // No timers, no listeners when animations are disabled.
        return null;
      }

      void scheduleStart() {
        startTimerRef.value?.cancel();
        startTimerRef.value = Timer(delayBeforeStart, () {
          if (controller.isAnimating) return;
          controller.forward();
        });
      }

      void onStatus(AnimationStatus status) {
        if (!loopWithPause) return;
        if (status == AnimationStatus.completed) {
          restartTimerRef.value?.cancel();
          restartTimerRef.value = Timer(restartDelay, () {
            if (!controller.isAnimating && controller.status == AnimationStatus.completed) {
              controller
                ..reset()
                ..forward();
            }
          });
        }
      }

      // Initial delayed start
      scheduleStart();

      // Replay after completion
      controller.addStatusListener(onStatus);

      // Cleanup
      return () {
        controller.removeStatusListener(onStatus);
        startTimerRef.value?.cancel();
        restartTimerRef.value?.cancel();
      };
    }, [
      controller,
      disableAnimations,
      delayBeforeStart,
      restartDelay,
      loopWithPause,
    ]);

    final lottie = Lottie.asset(
      assetPath,
      controller: disableAnimations ? null : controller,
      animate: !disableAnimations, // if reduced motion -> still frame
      fit: fit,
      alignment: alignment,
      onLoaded: (composition) {
        // Set duration once we know it; first forward is scheduled by timer above.
        controller.duration = composition.duration;
      },
    );

    // Keep your exact layout: centered, constrained, then scaled.
    final content = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxHeight.h,
          maxWidth: maxWidth.w,
        ),
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.center,
          child: lottie,
        ),
      ),
    );

    // Semantics wrapper for a11y; no visual changes.
    return Semantics(
      label: semanticsLabel,
      image: true,
      child: content,
    );
  }
}
