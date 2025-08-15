// lib/ui/requirement_checker.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:application/ui/theme.dart'; // for ThemeX: context.palette

class Requirement {
  final String label;
  final bool Function(String value) validator;

  const Requirement({
    required this.label,
    required this.validator,
  });
}

class RequirementChecker extends HookWidget {
  final TextEditingController controller;
  final List<Requirement> requirements;

  /// If provided, overrides the default satisfied/unsatisfied colors.
  final Color? satisfiedColor;   // default: green (keeps legacy look)
  final Color? unsatisfiedColor; // default: palette.lightGray

  /// Full style overrides (take precedence over colors above).
  final TextStyle? satisfiedStyle;
  final TextStyle? unsatisfiedStyle;

  /// Vertical space between rows (logical; scaled with .h)
  final double spacing;

  /// Animations
  final Duration appearDuration;
  final Duration changeDuration;
  final Curve curve;
  final double initialSlideDy;

  const RequirementChecker({
    super.key,
    required this.controller,
    required this.requirements,
    this.satisfiedColor,
    this.unsatisfiedColor,
    this.satisfiedStyle,
    this.unsatisfiedStyle,
    this.spacing = 4,
    this.appearDuration = const Duration(milliseconds: 220),
    this.changeDuration = const Duration(milliseconds: 160),
    this.curve = Curves.easeInOut,
    this.initialSlideDy = 0.06,
  });

  @override
  Widget build(BuildContext context) {
    // Rebuild when text changes
    useListenable(controller);

    // Entrance animation
    final appearCtrl = useAnimationController(duration: appearDuration);
    final appearAnim = useMemoized(
      () => CurvedAnimation(parent: appearCtrl, curve: curve),
      [appearCtrl, curve],
    );
    useEffect(() {
      appearCtrl.forward();
      return null;
    }, [appearCtrl]);

    final value = controller.text;
    final textScale = MediaQuery.textScaleFactorOf(context);
    final palette = context.palette;

    // Defaults keep legacy look: green for OK, gray for not met
    final Color okColor = satisfiedColor ?? Colors.green;
    final Color badColor = unsatisfiedColor ?? palette.lightGray;

    final TextStyle okStyle = satisfiedStyle ??
        TextStyle(
          color: okColor,
          fontWeight: FontWeight.w700,
          fontSize: 13.sp * textScale,
          fontFamily: 'Montserrat',
        );

    final TextStyle badStyle = unsatisfiedStyle ??
        TextStyle(
          color: badColor,
          fontWeight: FontWeight.w700,
          fontSize: 13.sp * textScale,
          fontFamily: 'Montserrat',
        );

    return FadeTransition(
      opacity: appearAnim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, initialSlideDy),
          end: Offset.zero,
        ).animate(appearAnim),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final r in requirements) ...[
              AnimatedDefaultTextStyle(
                duration: changeDuration,
                curve: curve,
                style: r.validator(value) ? okStyle : badStyle,
                child: Text(r.label),
              ),
              SizedBox(height: spacing.h),
            ],
          ],
        ),
      ),
    );
  }
}
