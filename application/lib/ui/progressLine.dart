import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:application/ui/theme.dart';

class ProgressLine extends StatefulWidget {
  final int currentPage;
  final int totalPages;
  final double height;

  const ProgressLine({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.height = 4,
    required int pageCount,
  });

  @override
  State<ProgressLine> createState() => _ProgressLineState();
}

class _ProgressLineState extends State<ProgressLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Start fade-in after slight delay to sync with line movement
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didUpdateWidget(covariant ProgressLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPage != oldWidget.currentPage) {
      _controller.reset();
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Widget> buildDots(int count, {required bool isLeft}) {
    return List.generate(count, (i) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 2.w),
        width: 6.w,
        height: 6.w,
        decoration: const BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final fullWidth =
        ScreenUtil().screenWidth - 2 * AppTheme.pageHorizontalPadding;
    final segmentWidth = fullWidth / widget.totalPages;
    final barLeft = segmentWidth * widget.currentPage;
    final dotTop = 12.h + (widget.height.h / 2) - (6.w / 2);

    return SizedBox(
      width: fullWidth,
      height: widget.height.h + 24.h,
      child: Stack(
        children: [
          // Base track
          Positioned(
            top: 12.h,
            left: 0,
            child: Container(
              width: fullWidth,
              height: widget.height.h,
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
              height: widget.height.h,
              decoration: BoxDecoration(
                color: AppTheme.warmGold,
                borderRadius: BorderRadius.circular(100.r),
              ),
            ),
          ),

          // Left dots (fade in)
          Positioned(
            top: dotTop,
            left: barLeft - (widget.currentPage * 10.w),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children:
                    buildDots(widget.currentPage, isLeft: true),
              ),
            ),
          ),

          // Right dots (fade in)
          Positioned(
            top: dotTop,
            left: barLeft + segmentWidth + 2.w,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: buildDots(
                    widget.totalPages - widget.currentPage - 1,
                    isLeft: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
