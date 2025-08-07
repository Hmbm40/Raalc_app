// lib/ui/requirement_checker.dart
import 'package:application/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

  final TextStyle? satisfiedStyle;
  final TextStyle? unsatisfiedStyle;
  final double spacing;

  final Duration appearDuration;
  final Duration changeDuration;
  final Curve curve;
  final double initialSlideDy;

  const RequirementChecker({
    super.key,
    required this.controller,
    required this.requirements,
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
    useListenable(controller);

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

    final okStyle = satisfiedStyle ??
        TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.w700,
          fontSize: 13.sp,
          fontFamily: 'Montserrat',
        );

    final badStyle = unsatisfiedStyle ??
        TextStyle(
          color: AppTheme.gray,
          fontWeight: FontWeight.w700,
          fontSize: 13.sp,
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
