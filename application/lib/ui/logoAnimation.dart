import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class HeaderAnimation extends HookWidget {
  final String assetPath;
  final double maxHeight;
  final double maxWidth;
  final double scale;

  const HeaderAnimation({
    super.key,
    required this.assetPath,
    this.maxHeight = 1000,
    this.maxWidth = 1000,
    this.scale = 7.0,
  });

  @override
  Widget build(BuildContext context) {
    final animationController = useAnimationController();

    useEffect(() {
      bool isDisposed = false;

      // Start animation after 1 second
      Future.delayed(const Duration(seconds: 1), () {
        if (!isDisposed) {
          animationController.forward();
        }
      });

      // Handle restart after 10 seconds post-completion
      void onStatusChanged(AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(const Duration(seconds: 6), () {
            if (!isDisposed &&
                !animationController.isAnimating &&
                animationController.status == AnimationStatus.completed) {
              animationController
                ..reset()
                ..forward();
            }
          });
        }
      }

      animationController.addStatusListener(onStatusChanged);

      return () {
        isDisposed = true;
        animationController.removeStatusListener(onStatusChanged);
        animationController.dispose(); 
      };
    }, [animationController]);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxHeight.h,
          maxWidth: maxWidth.w,
        ),
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.center,
          child: Lottie.asset(
            assetPath,
            controller: animationController,
            onLoaded: (composition) {
              animationController.duration = composition.duration;
              // Initial forward() is now handled after 1s delay
            },
            fit: BoxFit.contain,
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }
}
