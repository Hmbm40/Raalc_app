import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:application/ui/theme.dart';

class ProgressLine extends HookWidget {
  final int currentPage;
  final int totalPages;
  final double height;

  const ProgressLine({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.height = 4,
  });

  List<Widget> buildDots(int count) {
    return List.generate(
      count,
      (_) => Container(
        margin: EdgeInsets.symmetric(horizontal: 2.w),
        width: 6.w,
        height: 6.w,
        decoration: const BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fullWidth = ScreenUtil().screenWidth - 2 * AppTheme.pageHorizontalPadding;
    final segmentWidth = fullWidth / totalPages;
    final barLeft = segmentWidth * currentPage;
    final dotTop = 12.h + (height.h / 2) - (6.w / 2);

    final prevPage = usePrevious(currentPage);
    final controller = useAnimationController(duration: const Duration(milliseconds: 300));

    final fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );

    final showNewDots = useState(false);
    final displayedPage = useState(prevPage ?? currentPage);

    useEffect(() {
      showNewDots.value = false;
      displayedPage.value = prevPage ?? currentPage;

      Future.delayed(const Duration(milliseconds: 200), () {
        showNewDots.value = true;
        displayedPage.value = currentPage;
        controller.forward(from: 0);
      });

      return null;
    }, [currentPage]);

    return SizedBox(
      width: fullWidth,
      height: height.h + 24.h,
      child: Stack(
        children: [
          // Background line
          Positioned(
            top: 12.h,
            left: 0,
            child: Container(
              width: fullWidth,
              height: height.h,
              decoration: BoxDecoration(
                color: AppTheme.ivoryWhite.withOpacity(0.2),
                borderRadius: BorderRadius.circular(100.r),
              ),
            ),
          ),

          // Progress bar
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: 12.h,
            left: barLeft,
            child: Container(
              width: segmentWidth,
              height: height.h,
              decoration: BoxDecoration(
                color: AppTheme.warmGold,
                borderRadius: BorderRadius.circular(100.r),
              ),
            ),
          ),

          // Delayed fade-in dots
          if (showNewDots.value) ...[
            Positioned(
              top: dotTop,
              left: barLeft - (currentPage * 10.w),
              child: FadeTransition(
                opacity: fadeIn,
                child: Row(children: buildDots(currentPage)),
              ),
            ),
            Positioned(
              top: dotTop,
              left: barLeft + segmentWidth + 2.w,
              child: FadeTransition(
                opacity: fadeIn,
                child: Row(children: buildDots(totalPages - currentPage - 1)),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
